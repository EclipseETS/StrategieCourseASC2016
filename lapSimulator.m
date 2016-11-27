function lapLog = lapSimulator(parcours, etat_course, cellModel, contraintes, eclipse9, constantes, reglement, meteo)

%% Éclipse 9
%  La fonction lapSimulator permet de simuler un tour de piste sur circuit.
%  Cette fonction peut être utilisée pour reproduire la FSGP ou encore des essais chez PMG Technologies
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
%    * lapLog -> Mesures enregistrées lors d'un tour
%
%  Auteur : Julien Longchamp
%  Date de création : 17-06-2016
%  Dernière modification :
%%

%distance_totale = parcours.distance(end);   % km
nbPoints = length(parcours.distance);       % nombre d'intervals pour la simulation
outOfFuel = 0;
sansSupport = 0; % Les panneaux solaires sont considérées à plat sur le sol

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
direction = zeros(nbPoints, 1);

% h = waitbar(0, 'Lap en cours');
for k=2:nbPoints
%     waitbar(k / nbPoints)
    if mod(heure,1) > (reglement.heure_arret-reglement.heure_depart)*(index_meteo/length(meteo.vitesse_vent)) && index_meteo < length(meteo.vitesse_vent)
        index_meteo = index_meteo+1;
    end
    direction(k) = azimuth(parcours.latitude(k), parcours.longitude(k), parcours.latitude(k-1), parcours.longitude(k-1));
    vitesse_ecoulement_air = profil_vitesse(k-1) + meteo.vitesse_vent(index_meteo) * cosd(meteo.direction_vent(index_meteo) - direction(k));
    
    % Calcul des focres appliquées sur le véhicule
    force_g(k) = sin(atan(parcours.slope(k)/100))*eclipse9.masse_totale*constantes.const_grav; % fg = sin(pente)*m*g    
    force_aero(k) = 0.5*meteo.mv_air(index_meteo)*eclipse9.coef_trainee*eclipse9.aire_frontale*vitesse_ecoulement_air.^2; % fa = 1/2*rho*Cx*S*V^2
%     force_aero(k) = 0.5*meteo.mv_air*eclipse9.coef_trainee*eclipse9.aire_frontale*profil_vitesse(k-1).^2; 
%     force_aero(k) = 0.5*constantes.mv_air*eclipse9.coef_trainee*eclipse9.aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
%     force_drag_roues(k) = eclipse9.nb_roue * 0.5 * constantes.mv_air * profil_vitesse(k-1).^2 * ((eclipse9.largeur_pneu*eclipse9.hauteur_roue^3)/(2 * eclipse9.rayon_roue^2));     % ****** À VÉRIFIER **********
    force_friction(k) = eclipse9.frottement; % ****** À VÉRIFIER **********       **********       **********        **********     **********       % ****** À VÉRIFIER **********
    force_opposition_tot(k) = force_g(k)+force_aero(k)+force_friction(k); % +force_drag_roues(k) ********** Drag des roues inclus dans la trainée aéro totale
    
    if (profil_vitesse(k-1) < contraintes.vitesse_moy)     % Si la vitesse actuelle est inférieure à la vitesse de croisière alors accélération
        if (profil_vitesse(k-1) < contraintes.vitesse_min)   % Si la vitesse actuelle est plus basse que la vitesse de croisière minimale (Typiquement au départ)
            profil_accel(k) = contraintes.accel_max;   % Accélération forte (Départ)
        else
            profil_accel(k) = contraintes.accel_nom;   % Accélération légère (En route)
        end        
        force_traction_cible = force_opposition_tot(k) + (eclipse9.masse_totale * profil_accel(k)); % Force de traction nécessaire pour obtenir l'accélération désirée.
    elseif (profil_vitesse(k-1) > contraintes.vitesse_max)                                      % TODO : Ajouter une condition pour effectuer un freinage si la vitesse devient trop élevée (ie. descente de pente)
       profil_accel(k) = contraintes.decel_nom;
       force_traction_cible = force_opposition_tot(k) + (eclipse9.masse_totale * profil_accel(k)); % Force de traction nécessaire pour obtenir l'accélération désirée.
       disp('Alerte : freinage')
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

    densite_de_puissance_incidente = solarradiationInstant(zeros(2), ones(1,2)*parcours.latitude(k),1,0.2,heure); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
    [puissancePV_sansNuages Elevation(k)] = solarArrayModel(heure, densite_de_puissance_incidente, sansSupport, meteo.sun_cycle_coef);
    puissancePV(k) = meteo.couverture_ciel(index_meteo) .* puissancePV_sansNuages;
%     puissancePV(k) = meteo.couverture_ciel(index_meteo) .* solarArrayModel(parcours.latitude(k), parcours.longitude(k), parcours.altitude(k), parcours.slope(k), heure, densite_de_puissance_incidente, sansSupport, meteo.sun_cycle_coef);
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


% close(h) % Close the waitbar


%% Valeurs de sortie de la fonction lapSimulator
lapLog.temps_cumulatif = temps_cumulatif;   % (s)
lapLog.SoC = SoC; % (%)
lapLog.Ibatt = Ibatt;   % Adc
lapLog.Vbatt = batteryModel(SoC, Ibatt); % Vdc
lapLog.profil_force_traction = profil_force_traction; % N
lapLog.profil_vitesse = profil_vitesse; % rad/s
lapLog.profil_accel = profil_accel; % m/s^2
lapLog.puissance_moteurs = puissance_moteurs; % W
lapLog.puissance_elec_totale = puissance_elec_totale; % W
lapLog.energie_fournie_totale = energie_depensee_totale; % Wh
lapLog.outOfFuel = outOfFuel;   % boolean
lapLog.heure_finale = heure; % datenum
lapLog.puissance_elec_totale = puissance_elec_totale; % W
lapLog.puissancePV = puissancePV; % W
lapLog.puissance_elec_traction = puissance_elec_traction; % W
lapLog.elevation = Elevation; % degrés
end

