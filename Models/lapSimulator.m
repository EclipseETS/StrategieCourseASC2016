function lapLog = lapSimulator(parcours, etat_course, cellModel, strategy, Eclipse, constantes, reglement, meteo)

%% Éclipse 9
%  La fonction lapSimulator permet de simuler un tour de piste sur circuit.
%  Cette fonction peut être utilisée pour reproduire la FSGP ou encore des essais chez PMG Technologies
%
%  Entrées :
%    * parcours -> Propriétés du parcours obtenues à partir du fichier "traitementDonneesGPS.m"
%    * etat_course -> État de la voiture au début du tour
%    * cellModel -> Coefficients des courbes de décharge de la batterie
%    * strategy -> Paramètres de la stratégie de course
%    * Eclipse -> Paramètres de la voiture solaire
%    * constantes -> Constantes physiques
%    * reglement -> Contraintes liés aux règlements de la compétition
%    * meteo -> Prévisions météorologiques
%
%
%  Sorties :
%    * lapLog -> Mesures enregistrées lors d'un tour
%
%  Auteur : Julien Longchamp
%  Date de création : 17-06-2016
%  Dernière modification : 17-01-2017 (JL) Changement de nom de variable : contraintes -> strategy
%                          04-07-2017 Mégane Lavallee
%%

%distance_totale = parcours.distance(end);   % km
nbPoints = length(parcours.distance);       % nombre d'intervals pour la simulation
outOfFuel = 0;
% sansSupport = 0; % Les panneaux solaires sont considérées à plat sur le sol

index_meteo = 1;
heure = etat_course.heure_depart; % Date et heure au début de la course

%% Initialisation des vecteurs pour la simulation
profil_vitesse = etat_course.vitesse_ini*ones(nbPoints,1);
temps_interval = zeros(nbPoints,1);
temps_cumulatif = zeros(nbPoints,1);
force_g = zeros(nbPoints,1);
force_aero = zeros(nbPoints,1);
% force_drag_roues = zeros(nbPoints,1);
force_friction = zeros(nbPoints,1);
force_opposition_tot = zeros(nbPoints,1);
profil_accel = zeros(nbPoints,1);
% profil_force_tot = zeros(nbPoints,1);
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
Moyenne_Soleil = zeros(nbPoints, 1);


% h = waitbar(0, 'Lap en cours');
for nb_iterations=2:nbPoints
%     waitbar(nb_iterations / nbPoints)
    if mod(heure,1) > (reglement.heure_arret-reglement.heure_depart)*(index_meteo/length(meteo.vitesse_vent)) && index_meteo < length(meteo.vitesse_vent)
        index_meteo = index_meteo+1;
    end
    direction(nb_iterations) = azimuth(parcours.latitude(nb_iterations), parcours.longitude(nb_iterations), parcours.latitude(nb_iterations-1), parcours.longitude(nb_iterations-1));
    vitesse_ecoulement_air = profil_vitesse(nb_iterations-1) + meteo.vitesse_vent(index_meteo) * cosd(meteo.direction_vent(index_meteo) - direction(nb_iterations));
   
    % Calcul des focres appliquées sur le véhicule
    force_g(nb_iterations) = sin(atan(parcours.slope(nb_iterations)/100))*Eclipse.masse_totale*constantes.const_grav; % fg = sin(pente)*m*g    
    force_aero(nb_iterations) = 0.5*meteo.mv_air(index_meteo)*Eclipse.coef_trainee*Eclipse.aire_frontale*vitesse_ecoulement_air.^2; % fa = 1/2*rho*Cx*S*V^2
    force_friction(nb_iterations) = Eclipse.frottement; % ****** À VÉRIFIER **********       **********       **********        **********     **********       % ****** À VÉRIFIER **********
    force_opposition_tot(nb_iterations) = force_g(nb_iterations)+force_aero(nb_iterations)+force_friction(nb_iterations); % +force_drag_roues(nb_iterations) ********** Drag des roues inclus dans la trainée aéro totale
    
    if (profil_vitesse(nb_iterations-1) < strategy.vitesse_moy)     % Si la vitesse actuelle est inférieure à la vitesse de croisière alors accélération
        if (profil_vitesse(nb_iterations-1) < strategy.vitesse_min)   % Si la vitesse actuelle est plus basse que la vitesse de croisière minimale (Typiquement au départ)
            profil_accel(nb_iterations) = strategy.accel_max;   % Accélération forte (Départ)
        else
            profil_accel(nb_iterations) = strategy.accel_nom;   % Accélération légère (En route)
        end        
        force_traction_cible = force_opposition_tot(nb_iterations) + (Eclipse.masse_totale * profil_accel(nb_iterations)); % Force de traction nécessaire pour obtenir l'accélération désirée.
    elseif (profil_vitesse(nb_iterations-1) > strategy.vitesse_max)                                      % TODO : Ajouter une condition pour effectuer un freinage si la vitesse devient trop élevée (ie. descente de pente)
       profil_accel(nb_iterations) = strategy.decel_nom;
       force_traction_cible = force_opposition_tot(nb_iterations) + (Eclipse.masse_totale * profil_accel(nb_iterations)); % Force de traction nécessaire pour obtenir l'accélération désirée.
       disp('Alerte : freinage')
    else
        force_traction_cible = 0;
    end
    
    profil_force_traction(nb_iterations) = min(force_traction_cible, Eclipse.couple_max*Eclipse.nb_moteur/Eclipse.rayon_roue); % La force de traction est plafonnée selon le couple max des deux moteurs d'Éclipse 9
    profil_accel(nb_iterations) = (profil_force_traction(nb_iterations)-force_opposition_tot(nb_iterations))/Eclipse.masse_totale; % Le profil d'accélération réel est recalculé
       
    if (profil_accel(nb_iterations)> 0)
        if (profil_vitesse(nb_iterations-1) == 0)
            temps_interval(nb_iterations) = sqrt(2.*parcours.distance_interval(nb_iterations)./abs(profil_accel(nb_iterations)));
        else
            temps_interval(nb_iterations) = parcours.distance_interval(nb_iterations) / (profil_vitesse(nb_iterations-1)+ profil_accel(nb_iterations)/2 );
        end
    else
        temps_interval(nb_iterations) = parcours.distance_interval(nb_iterations)/profil_vitesse(nb_iterations-1);
    end
    profil_vitesse(nb_iterations) = profil_vitesse(nb_iterations-1)+profil_accel(nb_iterations).*temps_interval(nb_iterations);
    temps_cumulatif(nb_iterations) = temps_cumulatif(nb_iterations-1) + temps_interval(nb_iterations); % s
    heure = etat_course.heure_depart + temps_cumulatif(nb_iterations)/(24*3600);   % On converti le temps (secondes) en fraction de journée de 24 heures
%%  
    warning ('off')
    heureArrondieVec = datevec(heure);
    heureArrondie = ceil(heureArrondieVec(4)/.5)*.5 ; % Heure arrondie aux 30 minutes
    heureArrondieVec = [floor(heureArrondie)  (mod(heureArrondie, 1))*60 0];
    
    lapDateVec = datevec(etat_course.heure_depart, 'yyyy-mm-dd HH:MM:SS');
    lapTimeVec = datevec(datenum([lapDateVec(1:3) heureArrondieVec]), 'yyyy-mm-dd HH:SS:MM');
    
    lapDateVec = datevec(etat_course.heure_depart, 'yyyy-mm-dd HH:MM:SS');
    lapTimeVec = datevec(datenum([lapDateVec(1:3) heureArrondieVec]), 'yyyy-mm-dd HH:SS:MM');
   
    indexPV = find(ismember (meteo.dateVec_irradiance, lapTimeVec, 'rows'));
    
    if isempty (indexPV) == 1
        error ('etat_course.heure_depart est invalide, la date ne corresponds pas avec le fichier sunForecast, a changer dans parameterGeneratorEclipseIX.')
    end

    irrandiance = meteo.global_horizontal_irradiance(1 , indexPV);
    puissancePV(nb_iterations) = irrandiance * Eclipse.SurfaceTotalePV * Eclipse.EfficaciteSunPowerBinH;

    warning ('on')
%%      
    % Calcul la force de traction appliquée par les moteurs (ne considère pas le freinage ni le regen)  % TODO : Ajouter le regen
    if profil_force_traction(nb_iterations) > 0 % Si les moteurs fournissent un couple de traction
        profil_force_moteurs(nb_iterations) = profil_force_traction(nb_iterations);
    end
    
    profil_couple_moteurs(nb_iterations) = profil_force_moteurs(nb_iterations).*Eclipse.rayon_roue;
    profil_radSpeed(nb_iterations) = profil_vitesse(nb_iterations)./Eclipse.rayon_roue;
    
    [motorsLosses, drivesLosses, batteryLosses, outTempWinding, Ibatt(nb_iterations)] = powerElecLosses(profil_couple_moteurs(nb_iterations)/2, profil_radSpeed(nb_iterations), meteo.temperature(index_meteo), tempWinding(nb_iterations), SoC(nb_iterations-1), cellModel, Eclipse);
    tempWinding(nb_iterations) = outTempWinding;
    
    puissance_moteurs(nb_iterations) = profil_force_moteurs(nb_iterations).*parcours.distance_interval(nb_iterations)./temps_interval(nb_iterations); % W
    puissance_elec_traction(nb_iterations) = puissance_moteurs(nb_iterations) + motorsLosses + drivesLosses + batteryLosses; % W
    puissance_elec_totale(nb_iterations) = (puissance_moteurs(nb_iterations) + motorsLosses + drivesLosses + batteryLosses - puissancePV(nb_iterations) ); % W
    energie_mec_moteur(nb_iterations) = sum(profil_force_moteurs(1:nb_iterations).*parcours.distance_interval(1:nb_iterations))/3.6e6; % kWh
    energie_depensee_totale(nb_iterations) = puissance_elec_totale(nb_iterations).* temps_interval(nb_iterations) / 3600; % Wh
        
    SoC_Ah = Eclipse.Ccell * (1-SoC(nb_iterations-1));    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    Ebatt = Eclipse.nb_cell_serie * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
      
    new_SoC_Ah = SoC_Ah + (energie_depensee_totale(nb_iterations)/Ebatt/Eclipse.nb_cell_para); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    new_SoC_Ah = max([new_SoC_Ah, 0]);        
%     newEbatt = Eclipse.nb_cell_serie * polyval(cellModel.decharge0C2, new_SoC_Ah);
%     new2_SoC_Ah = SoC_Ah + energie_depensee_totale(nb_iterations)/newEbatt/Eclipse.nb_cell_para;
%     newEbatt2 = Eclipse.nb_cell_serie * polyval(cellModel.decharge0C2, new2_SoC_Ah);
    
    SoC(nb_iterations) = (Eclipse.Ccell - new_SoC_Ah) / Eclipse.Ccell;
    
%     if SoC(nb_iterations) > SoC(nb_iterations-1)
%         disp('RECHARGE')
%     end
    
    if SoC(nb_iterations) < strategy.SoC_min
        SoC(nb_iterations) = strategy.SoC_min;
        outOfFuel = 1;
        %disp('OUT OF FUEL')
        %fprintf('Distance raced : %5.2d (km) \n', round(parcours.distance(nb_iterations)));
        %fprintf('Percentage covered : %3.2f%%\n\n', parcours.distance(nb_iterations)/parcours.distance(end)*100);
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
LapLog.Moyenne_Soleil = Moyenne_Soleil; %Wh
%lapLog.elevation = Elevation; % degrés
end

