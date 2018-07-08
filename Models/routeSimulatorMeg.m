function routeLog = routeSimulatorMeg(newParcours, etat_course, cellModel, contraintes, Eclipse, constantes, reglement, meteo)

%% �clipse 9
%  La fonction routeSimulator permet de simuler un trajet routier.
%  Cette fonction peut �tre utilis�e pour reproduire une �tape de la ASC ou de la WSC.
%
%  Entr�es :
%    * parcours -> Propri�t�s du parcours obtenues � partir du fichier "traitementDonneesGPS.m"
%    * etat_initial -> Etat_initial de la voiture au d�but du tour
%    * cellModel -> Mod�les de la batterie
%    * contraintes ->
%    * Eclipse ->
%    * contraintes ->
%
%
%  Sorties :
%    * routeLog -> Mesures enregistr�es
%
%  Auteur : Julien Longchamp
%  Date de cr�ation : 07-07-2016
%  Derni�re modification :
%%

%distance_totale = parcours.distance(end);   % km
nbPoints = length(newParcours.distance);        % nombre d'intervals pour la simulation
outOfFuel = 0;

% flagCheckPoint = 0;

% surSupport = 1;  % Panneaux solaires sur le support inclinable
sansSupport = 0; % Panneaux solaire sur la voiture
index_meteo = 1;
heure = etat_course.heure_depart; % Date et heure au d�but de la course

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
profil_force_tot = zeros(nbPoints,1);
profil_force_traction = zeros(nbPoints,1);
profil_radSpeed = zeros(nbPoints,1);
profil_couple_moteurs = zeros(nbPoints,1);
profil_force_moteurs = zeros(nbPoints,1);
puissance_moteurs = zeros(nbPoints,1);
puissance_elec_totale = zeros(nbPoints,1);
% energie_mec_moteur = zeros(nbPoints,1);
energie_depensee_totale = zeros(nbPoints,1);
SoC = etat_course.SoC_start*ones(nbPoints,1);
tempWinding = 300*ones(nbPoints,1);  % Temp�rature ambiante (Kelvin)
Ibatt = zeros(nbPoints,1);
puissancePV = zeros(nbPoints,1);
direction = zeros(nbPoints,1);

for k=etat_course.index_depart:nbPoints
    if mod(heure,1) > (reglement.heure_arret-reglement.heure_depart)*(index_meteo/length(meteo.vitesse_vent)) && index_meteo < length(meteo.vitesse_vent)
        index_meteo = index_meteo+1;
    end
    direction(k) = azimuth(newParcours.latitude(k), newParcours.longitude(k), newParcours.latitude(k-1), newParcours.longitude(k-1));
    vitesse_ecoulement_air = profil_vitesse(k-1) + meteo.vitesse_vent(index_meteo) * cosd(meteo.direction_vent(index_meteo) - direction(k));

    % Calcul des focres appliqu�es sur le v�hicule
    force_g(k) = sin(atan(newParcours.slope(k)/100))*Eclipse.masse_totale*constantes.const_grav; % fg = sin(pente)*m*g
    force_aero(k) = 0.5*meteo.mv_air(index_meteo)*Eclipse.coef_trainee*Eclipse.aire_frontale*vitesse_ecoulement_air.^2; % fa = 1/2*rho*Cx*S*V^2
%     force_aero(k) = 0.5*meteo.mv_air*Eclipse.coef_trainee*Eclipse.aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
    %     force_aero(k) = 0.5*constantes.mv_air*Eclipse.coef_trainee*Eclipse.aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
%     force_drag_roues(k) = Eclipse.nb_roue * 0.5 * constantes.mv_air * profil_vitesse(k-1).^2 * ((Eclipse.largeur_pneu*Eclipse.hauteur_roue^3)/(2 * Eclipse.rayon_roue^2));     % ****** � V�RIFIER **********
    force_friction(k) = Eclipse.frottement; % ****** � V�RIFIER **********       **********       **********        **********     **********       % ****** � V�RIFIER **********
    force_opposition_tot(k) = force_g(k)+force_aero(k)+force_friction(k); % +force_drag_roues(k) ********** Drag des roues inclus dans la train�e a�ro totale
    profil_force_tot(k) = force_opposition_tot(k);
    
    if ((profil_vitesse(k-1) < newParcours.SpeedLimit(k)) || (profil_vitesse(k-1) < contraintes.vitesse_moy))    % Si la vitesse actuelle est inf�rieure � la vitesse de croisi�re et � la vitesse limite alors acc�l�ration
        if (profil_vitesse(k-1) < contraintes.vitesse_min)   % Si la vitesse actuelle est plus basse que la vitesse de croisi�re minimale (Typiquement au d�part)
            profil_accel(k) = contraintes.accel_max;   % Acc�l�ration forte (D�part)
        elseif (profil_vitesse(k-1) < contraintes.vitesse_moy)
            profil_accel(k) = contraintes.accel_nom;   % Acc�l�ration l�g�re (En route)
        end
        force_traction_cible = force_opposition_tot(k) + (Eclipse.masse_totale * profil_accel(k)); % Force de traction n�cessaire pour obtenir l'acc�l�ration d�sir�e.
    elseif (profil_vitesse(k-1) > contraintes.vitesse_max) || (profil_vitesse(k-1) > newParcours.SpeedLimit(k))
        profil_accel(k) = contraintes.decel_nom;
        force_traction_cible = force_opposition_tot(k) + (Eclipse.masse_totale * profil_accel(k)); % Force de traction n�cessaire pour obtenir l'acc�l�ration d�sir�e.
%         disp('Alerte : freinage')
    else
        force_traction_cible = 0;
    end
    
    profil_force_traction(k) = min(force_traction_cible, Eclipse.couple_max*Eclipse.nb_moteur/Eclipse.rayon_roue); % La force de traction est plafonn�e selon le couple max des deux moteurs d'�clipse 9
    profil_accel(k) = (profil_force_traction(k)-force_opposition_tot(k))/Eclipse.masse_totale; % Le profil d'acc�l�ration r�el est recalcul�
    
    if (profil_accel(k)> 0)
        if (profil_vitesse(k-1) == 0)
            temps_interval(k) = sqrt(2.*newParcours.distance_interval(k)./abs(profil_accel(k)));
        else
            temps_interval(k) = newParcours.distance_interval(k) / (profil_vitesse(k-1)+ profil_accel(k)/2 );
            %temps_interval(k) = sqrt(2.*newParcours.distance_interval(k)./abs(profil_accel(k)));
        end
    else
        temps_interval(k) = newParcours.distance_interval(k)/profil_vitesse(k-1);
    end
    profil_vitesse(k) = profil_vitesse(k-1)+profil_accel(k).*temps_interval(k);
    temps_cumulatif(k) = temps_cumulatif(k-1) + temps_interval(k); % s
    
    heure = etat_course.heure_depart + temps_cumulatif(k)/(24*3600);   % On converti le temps (secondes) en fraction de journ�e de 24 heures

        
    if mod(heure, 1) > reglement.heure_arret %% V�rifie si on a atteint la limite de la journ�e (18h00)   
        outOfFuel = 1;
    end

%%  
    warning ('off')
    heureArrondieVec = datevec(heure);
    heureArrondie = ceil(heureArrondieVec(4)/.5)*.5 ; % Heure arrondie aux 30 minutes
    heureArrondieVec = [floor(heureArrondie)  (mod(heureArrondie, 1))*60 0];
    
%   heureArrondieVec = [hour(heureArrondie) (mod(heureArrondie, 1))*60 0];
    lapDateVec = datevec(etat_course.heure_depart, 'yyyy-mm-dd HH:MM:SS');
    lapTimeVec = datevec(datenum([lapDateVec(1:3) heureArrondieVec]), 'yyyy-mm-dd HH:SS:MM');
    
    
    indexPV = find(ismember (meteo.dateVec_irradiance, lapTimeVec, 'rows'));
    
    if isempty (indexPV) == 1
        error ('etat_course.heure_depart est invalide, la date ne corresponds pas avec le fichier sunForecast, a changer dans parameterGeneratorEclipseIX.')
    end

    irrandiance = meteo.global_horizontal_irradiance(1 , indexPV);
    puissancePV(k) = irrandiance * Eclipse.SurfaceTotalePV * Eclipse.EfficaciteSunPowerBinH;

    warning ('on')
    %energie_recuperee(k) = puissancePV(k) .* temps_interval(k); % J
    
    % Calcul la force de traction appliqu�e par les moteurs (ne consid�re pas le freinage ni le regen)  % TODO : Ajouter le regen
    if profil_force_traction(k) > 0 % Si les moteurs fournissent un couple de traction
        profil_force_moteurs(k) = profil_force_traction(k);
    end
    
    profil_couple_moteurs(k) = profil_force_moteurs(k).*Eclipse.rayon_roue;
    profil_radSpeed(k) = profil_vitesse(k)./Eclipse.rayon_roue;
    
    [motorsLosses, drivesLosses, batteryLosses, outTempWinding, Ibatt(k)] = powerElecLosses(profil_couple_moteurs(k)/2, profil_radSpeed(k), meteo.temperature(index_meteo), tempWinding(k), SoC(k-1), cellModel, Eclipse);
    tempWinding(k) = outTempWinding;
    
    puissance_moteurs(k) = profil_force_moteurs(k).*newParcours.distance_interval(k)./temps_interval(k); % W
    puissance_elec_traction(k) = puissance_moteurs(k) + motorsLosses + drivesLosses + batteryLosses; % W
    puissance_elec_totale(k) = (puissance_moteurs(k) + motorsLosses + drivesLosses + batteryLosses - puissancePV(k)) ; % W
%     energie_mec_moteur(k) = sum(profil_force_moteurs(1:k).*newParcours.distance_interval(1:k))/3.6e6; % kWh
    energie_depensee_totale(k) = puissance_elec_totale(k).* temps_interval(k) / 3600; % Wh
    
    
    SoC_Ah = Eclipse.Ccell * (1-SoC(k-1));    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    Ebatt = Eclipse.nb_cell_serie * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantan�e du batterie pack obtenue sur la courbe 0,2C
      
    new_SoC_Ah = SoC_Ah + (energie_depensee_totale(k)/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    new_SoC_Ah = max([new_SoC_Ah, 0]);        
%     newEbatt = 38 * polyval(cellModel.decharge0C2, new_SoC_Ah);
%     new2_SoC_Ah = SoC_Ah + energie_depensee_totale(k)/newEbatt/11;
%     newEbatt2 = 38 * polyval(cellModel.decharge0C2, new2_SoC_Ah);
    
    SoC(k) = (Eclipse.Ccell - new_SoC_Ah) / Eclipse.Ccell;
  
    if SoC(k) < contraintes.SoC_min
        SoC(k) = contraintes.SoC_min;
        outOfFuel = 1;
    end
end
% fprintf('Lap : %3d \n', etat_course.nbLap);
% fprintf('SoC : %3.2d START\n', SoC(1));
% fprintf('SoC : %3.2d END\n', SoC(end));
% SoC(1) = SoC(end);
% SoC(2) = SoC(end);

%% Valeurs de sortie de la fonction lapSimulator
routeLog.temps_cumulatif = temps_cumulatif;   % (s)
routeLog.SoC = SoC; % (%)
routeLog.Ibatt = Ibatt;   % Adc
routeLog.Vbatt = batteryModel(SoC, Ibatt); % Vdc
routeLog.profil_force_traction = profil_force_traction; % N
routeLog.profil_vitesse = profil_vitesse; % rad/s
routeLog.puissance_moteurs = puissance_moteurs; % W
routeLog.puissance_elec_totale = puissance_elec_totale; % W
routeLog.energie_fournie_totale = energie_depensee_totale; % Wh
routeLog.outOfFuel = outOfFuel;   % boolean
routeLog.heure_finale = heure; % datenum
routeLog.puissance_elec_totale = puissance_elec_totale; % W
routeLog.puissancePV = puissancePV; % W
routeLog.puissance_elec_traction = puissance_elec_traction; % W
end
