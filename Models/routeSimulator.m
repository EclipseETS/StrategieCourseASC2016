function routeLog = routeSimulator(parcours, etat_course, cellModel, contraintes, eclipse9, constantes, reglement, meteo)

%% Éclipse 9
%  La fonction routeSimulator permet de simuler un trajet routier.
%  Cette fonction peut être utilisée pour reproduire une étape de la ASC ou de la WSC.
%
%  Entrées :
%    * parcours -> Propriétés du parcours obtenues à partir du fichier "traitementDonneesGPS.m"
%    * etat_initial -> Etat_initial de la voiture au début du tour
%    * cellModel -> Modèles de la batterie
%    * contraintes ->
%    * eclipse9 ->
%    * contraintes ->
%
%
%  Sorties :
%    * routeLog -> Mesures enregistrées lors d'un tour
%
%  Auteur : Julien Longchamp
%  Date de création : 07-07-2016
%  Dernière modification :
%%

%distance_totale = parcours.distance(end);   % km
nbPoints = length(parcours.distance);        % nombre d'intervals pour la simulation
outOfFuel = 0;

flagCheckPoint = 0;

surSupport = 1;  % Panneaux solaires sur le support inclinable
sansSupport = 0; % Panneaux solaire sur la voiture
index_meteo = 1;
heure = etat_course.heure_depart; % Date et heure au début de la course

%% Initialisation des vecteurs pour la simulation
profil_vitesse = etat_course.vitesse_ini*ones(nbPoints,1);
temps_interval = zeros(nbPoints,1);
temps_cumulatif = zeros(nbPoints,1);
force_g = zeros(nbPoints,1);
force_aero = zeros(nbPoints,1);
force_drag_roues = zeros(nbPoints,1);
force_friction = zeros(nbPoints,1);
force_opposition_tot = zeros(nbPoints,1);
profil_accel = zeros(nbPoints,1);
profil_force_tot = zeros(nbPoints,1);
profil_force_traction = zeros(nbPoints,1);
profil_radSpeed = zeros(nbPoints,1);
profil_couple_moteurs = zeros(nbPoints,1);
profil_force_moteurs = zeros(nbPoints,1);
puissance_moteurs = zeros(nbPoints,1);
puissance_elec_totale = zeros(nbPoints,1);
energie_mec_moteur = zeros(nbPoints,1);
energie_depensee_totale = zeros(nbPoints,1);
SoC = etat_course.SoC_start*ones(nbPoints,1);
tempWinding = 300*ones(nbPoints,1);  % Température ambiante (Kelvin)
Ibatt = zeros(nbPoints,1);
puissancePV = zeros(nbPoints,1);
direction = zeros(nbPoints,1);

for k=etat_course.index_depart:nbPoints
    if mod(heure,1) > (reglement.heure_arret-reglement.heure_depart)*(index_meteo/length(meteo.vitesse_vent)) && index_meteo < length(meteo.vitesse_vent)
        index_meteo = index_meteo+1;
    end
    direction(k) = azimuth(parcours.latitude(k), parcours.longitude(k), parcours.latitude(k-1), parcours.longitude(k-1));
    vitesse_ecoulement_air = profil_vitesse(k-1) + meteo.vitesse_vent(index_meteo) * cosd(meteo.direction_vent(index_meteo) - direction(k));

    % Calcul des focres appliquées sur le véhicule
    force_g(k) = sin(atan(parcours.slope(k)/100))*eclipse9.masse_totale*constantes.const_grav; % fg = sin(pente)*m*g
    force_aero(k) = 0.5*meteo.mv_air(index_meteo)*eclipse9.coef_trainee*eclipse9.aire_frontale*vitesse_ecoulement_air.^2; % fa = 1/2*rho*Cx*S*V^2
%     force_aero(k) = 0.5*meteo.mv_air*eclipse9.coef_trainee*eclipse9.aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
    %     force_aero(k) = 0.5*constantes.mv_air*eclipse9.coef_trainee*eclipse9.aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
%     force_drag_roues(k) = eclipse9.nb_roue * 0.5 * constantes.mv_air * profil_vitesse(k-1).^2 * ((eclipse9.largeur_pneu*eclipse9.hauteur_roue^3)/(2 * eclipse9.rayon_roue^2));     % ****** À VÉRIFIER **********
    force_friction(k) = eclipse9.frottement; % ****** À VÉRIFIER **********       **********       **********        **********     **********       % ****** À VÉRIFIER **********
    force_opposition_tot(k) = force_g(k)+force_aero(k)+force_friction(k); % +force_drag_roues(k) ********** Drag des roues inclus dans la trainée aéro totale
    profil_force_tot(k) = force_opposition_tot(k);
    
    if ((profil_vitesse(k-1) < contraintes.vitesse_moy) && (profil_vitesse(k-1) < parcours.speed_limit(k)))     % Si la vitesse actuelle est inférieure à la vitesse de croisière et à la vitesse limite alors accélération
        if (profil_vitesse(k-1) < contraintes.vitesse_min)   % Si la vitesse actuelle est plus basse que la vitesse de croisière minimale (Typiquement au départ)
            profil_accel(k) = contraintes.accel_max;   % Accélération forte (Départ)
        else
            profil_accel(k) = contraintes.accel_nom;   % Accélération légère (En route)
        end
        force_traction_cible = force_opposition_tot(k) + (eclipse9.masse_totale * profil_accel(k)); % Force de traction nécessaire pour obtenir l'accélération désirée.
    elseif (profil_vitesse(k-1) > contraintes.vitesse_max) || (profil_vitesse(k-1) < parcours.speed_limit(k))
        profil_accel(k) = contraintes.decel_nom;
        force_traction_cible = force_opposition_tot(k) + (eclipse9.masse_totale * profil_accel(k)); % Force de traction nécessaire pour obtenir l'accélération désirée.
%         disp('Alerte : freinage')
    else
        force_traction_cible = 0;
    end
    
    profil_force_traction(k) = min(force_traction_cible, eclipse9.couple_max*eclipse9.nb_moteur/eclipse9.rayon_roue); % La force de traction est plafonnée selon le couple max des deux moteurs d'Éclipse 9
    profil_accel(k) = (profil_force_traction(k)-force_opposition_tot(k))/eclipse9.masse_totale; % Le profil d'accélération réel est recalculé
    
    if (profil_accel(k)> 0)
        if (profil_vitesse(k-1) == 0)
            temps_interval(k) = sqrt(2.*parcours.distance_interval(k)./abs(profil_accel(k)));
        else
            temps_interval(k) = parcours.distance_interval(k) / (profil_vitesse(k-1)+ profil_accel(k)/2 );
            %temps_interval(k) = sqrt(2.*parcours.distance_interval(k)./abs(profil_accel(k)));
        end
    else
        temps_interval(k) = parcours.distance_interval(k)/profil_vitesse(k-1);
    end
    profil_vitesse(k) = profil_vitesse(k-1)+profil_accel(k).*temps_interval(k);
    temps_cumulatif(k) = temps_cumulatif(k-1) + temps_interval(k); % s
    
    heure = etat_course.heure_depart + temps_cumulatif(k)/(24*3600);   % On converti le temps (secondes) en fraction de journée de 24 heures
    
    if parcours.distance(k) > 632 && flagCheckPoint == 1% Checkpoint du Kansas hardcodé *************** TO BE REMOVED ***************
        flagCheckPoint = 0;
        % Début de la recharge du soir jusqu'à ce que la batterie soit retirée de la voiture
        temps_recharge_checkpoint = linspace(heure, heure+0.75/24, 120); % Sépare la durée de la recharge en 100 points
        delta_t_checkpoint = (temps_recharge_checkpoint(2) - temps_recharge_checkpoint(1)) * (24*60*60); % secondes Résolution temporelle pour la recharge de fin de journée (fraction de jour /(24*60*60) = secondes)
        energie_recuperee_checkpoint = 0; % J
        for r = 1:length(temps_recharge_checkpoint)
            %             densite_de_puissance_incidente2 = polyval(constantes.irrandiance_coef, mod(temps_recharge_soir(r),1)*24); % Calcul de la densite de puissance incidente
            densite_de_puissance_incidente= solarradiationInstant(zeros(2), ones(1,2)*parcours.latitude(k),1,0.2,temps_recharge_checkpoint(r)); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
            [puissancePVcheckpoint_sansNuages Elevation(k)] = solarArrayModel(heure, densite_de_puissance_incidente, sansSupport, meteo.sun_cycle_coef);
            puissancePV_checkpoint(r) = meteo.couverture_ciel(index_meteo) .* puissancePVcheckpoint_sansNuages;
            energie_recuperee_checkpoint = energie_recuperee_checkpoint + puissancePV_checkpoint(r) * delta_t_checkpoint; % Joules
            
            %             [Az El(r)] = SolarAzEl(temps_recharge_soir(r),parcours.latitude(k), parcours.longitude(k), parcours.altitude(k));
        end
        
        heure = heure+0.75/24;
        temps_cumulatif(k) = temps_cumulatif(k-1)+0.75/24;
        
        energie_recuperee_wh = (energie_recuperee_checkpoint)/3600; % Wh Énergie récupérée totale durant l'arrêt
        
        SoC_Ah = 3.35 * (1-SoC(k-1));    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
        Ebatt = 38 * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
        new_SoC_Ah = SoC_Ah - (energie_recuperee_wh/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
        new_SoC_Ah = max([new_SoC_Ah, 0]);
        SoC(k-1) = (3.35 - new_SoC_Ah) / 3.35;
        
        % Réinitialisation de la vitesse pour repartir à zéro après l'arrêt
        profil_vitesse(k-1) = 0;
        
        fprintf('\nenergie_recuperee_checkpoint : %f3.2 Wh\n', energie_recuperee_checkpoint/3600)
        
    end
        
    if mod(heure, 1) > reglement.heure_arret %% Vérifie si on a atteint la limite de la journée (18h00)
        % Début de la recharge du soir jusqu'à ce que la batterie soit retirée de la voiture
        temps_recharge_soir = linspace(heure, floor(heure)+reglement.impound_in, 120); % Sépare la durée de la recharge en 100 points
        delta_t_soir = (temps_recharge_soir(2) - temps_recharge_soir(1)) * (24*60*60); % secondes Résolution temporelle pour la recharge de fin de journée (fraction de jour /(24*60*60) = secondes)
        energie_recuperee_soir = 0; % J
        for r = 1:length(temps_recharge_soir)
            %             densite_de_puissance_incidente2 = polyval(constantes.irrandiance_coef, mod(temps_recharge_soir(r),1)*24); % Calcul de la densite de puissance incidente
            densite_de_puissance_incidente= solarradiationInstant(zeros(2), ones(1,2)*parcours.latitude(k),1,0.2,temps_recharge_soir(r)); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
            [puissancePVsoir_sansNuages Elevation(k)] = solarArrayModel(heure, densite_de_puissance_incidente, sansSupport, meteo.sun_cycle_coef);
            puissancePV_soir(r) = meteo.couverture_ciel(index_meteo) .* puissancePVsoir_sansNuages;
            energie_recuperee_soir = energie_recuperee_soir + puissancePV_soir(r) * delta_t_soir; % Joules
            
            %             [Az El(r)]ùaùaùx = SolarAzEl(temps_recharge_soir(r),parcours.latitude(k), parcours.longitude(k), parcours.altitude(k));
        end
        
        % Début de la recharge du matin jusqu'à ce que la voiture reprenne la route
        temps_recharge_matin = linspace(heure, floor(heure)+reglement.impound_in, 100); % Sépare la durée de la recharge en 100 points
        delta_t_matin = (temps_recharge_matin(2) - temps_recharge_matin(1)) * (24*60*60); % secondes Résolution temporelle pour la recharge de fin de journée (fraction de jour /(24*60*60) = secondes)
        energie_recuperee_matin = 0; % J
        for r = 1:length(temps_recharge_matin)
            %             densite_de_puissance_incidente = polyval(constantes.irrandiance_coef, mod(temps_recharge_matin(r),1)*24); % Calcul de la densite de puissance incidente
            densite_de_puissance_incidente = solarradiationInstant(zeros(2), ones(1,2)*parcours.latitude(k),1,0.2,temps_recharge_soir(r)); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
            [puissancePVmatin_sansNuages Elevation(k)] = solarArrayModel(heure, densite_de_puissance_incidente, sansSupport, meteo.sun_cycle_coef);
            puissancePV_matin(r) = meteo.couverture_ciel(index_meteo) .* puissancePVmatin_sansNuages;
%             puissancePV_matin(r) = meteo.couverture_ciel(index_meteo) * solarArrayModel(parcours.latitude(k), parcours.longitude(k), parcours.altitude(k), parcours.slope(k), temps_recharge_matin(r), densite_de_puissance_incidente, surSupport); % W
%             energie_matin(r) = puissancePV_matin(r) * delta_t_matin; % Joules
            energie_recuperee_matin = energie_recuperee_matin + puissancePV_matin(r) * delta_t_matin; % Joules
        end
        
        fprintf('\nenergie_recuperee_soir : %f3.2 Wh\n', energie_recuperee_soir/3600)
        fprintf('\nenergie_recuperee_matin : %f3.2 Wh\n', energie_recuperee_matin/3600)
        
        heure = floor(heure) + 1 + reglement.heure_depart;
        temps_cumulatif(k) = 0;
        
        energie_recuperee_wh = (energie_recuperee_matin + energie_recuperee_soir)/3600; % Wh Énergie récupérée totale durant l'arrêt
        
        SoC_Ah = 3.35 * (1-SoC(k-1));    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
        Ebatt = 38 * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
        new_SoC_Ah = SoC_Ah - (energie_recuperee_wh/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
        new_SoC_Ah = max([new_SoC_Ah, 0]);
        SoC(k-1) = (3.35 - new_SoC_Ah) / 3.35;
        
        % Réinitialisation de la vitesse pour repartir à zéro après l'arrêt
        profil_vitesse(k-1) = 0;
    end
    
    %     densite_de_puissance_incidente = polyval(constantes.irrandiance_coef, mod(heure,1)*24);
    densite_de_puissance_incidente = solarradiationInstant(zeros(2), ones(1,2)*parcours.latitude(k),1,0.2,heure); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
    %     puissancePV(k) = meteo.couverture_ciel(index_meteo) * solarArrayModel(parcours.latitude(k), parcours.longitude(k), parcours.altitude(k), parcours.slope(k), heure, densite_de_puissance_incidente, sansSupport);
    [puissancePV_sansNuages Elevation(k)] = solarArrayModel(heure, densite_de_puissance_incidente, sansSupport, meteo.sun_cycle_coef);
    puissancePV(k) = meteo.couverture_ciel(index_meteo) .* puissancePV_sansNuages;
    
    %energie_recuperee(k) = puissancePV(k) .* temps_interval(k); % J
    
    % Calcul la force de traction appliquée par les moteurs (ne considère pas le freinage ni le regen)  % TODO : Ajouter le regen
    if profil_force_traction(k) > 0 % Si les moteurs fournissent un couple de traction
        profil_force_moteurs(k) = profil_force_traction(k);
    end
    
    profil_couple_moteurs(k) = profil_force_moteurs(k).*eclipse9.rayon_roue;
    profil_radSpeed(k) = profil_vitesse(k)./eclipse9.rayon_roue;
    
    [motorsLosses, drivesLosses, batteryLosses, outTempWinding, Ibatt(k)] = powerElecLosses(profil_couple_moteurs(k)/2, profil_radSpeed(k), meteo.temperature(index_meteo), tempWinding(k), SoC(k-1), cellModel);
    tempWinding(k) = outTempWinding;
    
    puissance_moteurs(k) = profil_force_moteurs(k).*parcours.distance_interval(k)./temps_interval(k); % W
    puissance_elec_traction(k) = puissance_moteurs(k) + motorsLosses + drivesLosses + batteryLosses; % W
    puissance_elec_totale(k) = (puissance_moteurs(k) + motorsLosses + drivesLosses + batteryLosses - puissancePV(k)) ; % W
    energie_mec_moteur(k) = sum(profil_force_moteurs(1:k).*parcours.distance_interval(1:k))/3.6e6; % kWh
    energie_depensee_totale(k) = puissance_elec_totale(k).* temps_interval(k) / 3600; % Wh
    
    
    SoC_Ah = 3.35 * (1-SoC(k-1));    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    Ebatt = 38 * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
      
    new_SoC_Ah = SoC_Ah + (energie_depensee_totale(k)/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    new_SoC_Ah = max([new_SoC_Ah, 0]);        
    newEbatt = 38 * polyval(cellModel.decharge0C2, new_SoC_Ah);
    new2_SoC_Ah = SoC_Ah + energie_depensee_totale(k)/newEbatt/11;
    newEbatt2 = 38 * polyval(cellModel.decharge0C2, new2_SoC_Ah);
    
    SoC(k) = (3.35 - new_SoC_Ah) / 3.35;
    
%     if SoC(k) > SoC(k-1)
%         disp('RECHARGE')
%     end
    
    if SoC(k) < contraintes.SoC_min
        SoC(k) = contraintes.SoC_min;
        outOfFuel = 1;
        %disp('OUT OF FUEL')
        %fprintf('Distance raced : %5.2d (km) \n', round(parcours.distance(k)));
        %fprintf('Percentage covered : %3.2f%%\n\n', parcours.distance(k)/parcours.distance(end)*100);
        %break;
    end
end
% fprintf('Lap : %3d \n', etat_course.nbLap);
% fprintf('SoC : %3.2d START\n', SoC(1));
% fprintf('SoC : %3.2d END\n', SoC(end));
% SoC(1) = SoC(end);
% SoC(2) = SoC(end);

% %% Valeurs de sortie de la fonction lapSimulator
% routeLog.temps_cumulatif = temps_cumulatif;   % (s)
% routeLog.SoC = SoC; % (%)
% routeLog.Ibatt = Ibatt;   % Adc
% routeLog.Vbatt = batteryModel(SoC, Ibatt); % Vdc
% routeLog.profil_force_traction = profil_force_traction; % N
% routeLog.profil_vitesse = profil_vitesse; % rad/s
% routeLog.puissance_moteurs = puissance_moteurs; % W
% routeLog.puissance_elec_totale = puissance_elec_totale; % W
% routeLog.energie_fournie_totale = energie_depensee_totale; % Wh
% routeLog.outOfFuel = outOfFuel;   % boolean
% routeLog.heure_finale = heure; % datenum
% routeLog.puissance_elec_totale = puissance_elec_totale; % W
% routeLog.puissancePV = puissancePV; % W
% % routeLog.puissance_elec_traction = puissance_elec_traction; % W
routeLog.temps_cumulatif = temps_cumulatif;   % (s)
routeLog.SoC = SoC; % (%)
routeLog.Ibatt = Ibatt;   % Adc
routeLog.Vbatt = batteryModel(SoC, Ibatt); % Vdc
routeLog.profil_force_traction = profil_force_traction; % N
routeLog.profil_vitesse = profil_vitesse; % rad/s
routeLog.profil_accel = profil_accel; % m/s^2
routeLog.puissance_moteurs = puissance_moteurs; % W
routeLog.puissance_elec_totale = puissance_elec_totale; % W
routeLog.energie_fournie_totale = energie_depensee_totale; % Wh
routeLog.outOfFuel = outOfFuel;   % boolean
routeLog.heure_finale = heure; % datenum
routeLog.puissance_elec_totale = puissance_elec_totale; % W
routeLog.puissancePV = puissancePV; % W
routeLog.puissance_elec_traction = puissance_elec_traction; % W
routeLog.elevation = Elevation; % degrés
end

