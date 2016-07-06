function lapLog = lapSimulator(parcours, etat_course, cellModel, contraintes, eclipse9, constantes)

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

for k=2:nbPoints
    % Calcul des focres appliquées sur le véhicule
    force_g(k) = sin(atan(parcours.slope(k)/100))*eclipse9.masse_totale*constantes.const_grav; % fg = sin(pente)*m*g
    force_aero(k) = 0.5*constantes.mv_air*eclipse9.coef_trainee*eclipse9.aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
    force_drag_roues(k) = eclipse9.nb_roue * 0.5 * constantes.mv_air * profil_vitesse(k-1).^2 * ((eclipse9.largeur_pneu*eclipse9.hauteur_roue^3)/(2 * eclipse9.rayon_roue^2));     % ****** À VÉRIFIER **********
    force_friction(k) = eclipse9.frottement; % ****** À VÉRIFIER **********       **********       **********        **********     **********       % ****** À VÉRIFIER **********
    force_opposition_tot(k) = force_g(k)+force_aero(k)+force_friction(k); % +force_drag_roues(k) ********** Drag des roues inclus dans la trainée aéro totale
    profil_force_tot(k) = force_opposition_tot(k);
    
    if (profil_vitesse(k-1) < contraintes.vitesse_min)   % Si la vitesse actuelle est plus basse que la vitesse de croisière minimale (Typiquement au départ)
        profil_accel(k) = contraintes.accel_max;   % Pédale au plancher (Départ)
    else
        profil_accel(k) = contraintes.accel_nom;   % Accélération légère (En route)
    end
    
    if (profil_vitesse(k-1) < contraintes.vitesse_moy)     % Si la vitesse actuelle est inférieure à la vitesse de croisière alors accélération
        %temps_interval(k) = sqrt(2.*parcours.distance_interval(k-1)./accel_max);
        %profil_vitesse(k) = profil_vitesse(k-1)+accel_max.*temps_interval(k);
        %force_consigne_accel(k) = masse_totale * accel_max;
        
        if force_opposition_tot(k) >= 0  % On accèlere seulement si la somme des forces d'opposition est positive sinon on lâche le gaz et on se laisse descendre la pente
            profil_force_tot(k) = force_opposition_tot(k) + eclipse9.masse_totale*profil_accel(k);
        end
    else                                      % TODO : Ajouter une condition pour effectuer un freinage si la vitesse devient trop élevée (ie. descente de pente)
        %profil_vitesse(k) = profil_vitesse(k-1);    % Si la vitesse actuelle est inférieure à la vitesse de croisière alors pas d'accélération
        %temps_interval(k) = parcours.distance_interval(k)/profil_vitesse(k);
        %force_consigne_accel(k) = 0;
        profil_force_tot(k) = force_opposition_tot(k) + eclipse9.masse_totale*contraintes.decel_nom;
    end
    
    
    profil_force_traction(k) = min(profil_force_tot(k), eclipse9.couple_max*eclipse9.nb_moteur/eclipse9.rayon_roue);
    profil_accel(k) = (profil_force_traction(k)-force_opposition_tot(k))/eclipse9.masse_totale;
    
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
    puissancePV(k) = solarArrayModel(parcours.latitude(k), parcours.longitude(k), parcours.altitude(k), parcours.slope(k), heure, constantes.densite_de_puissance_incidente);
    %energie_recuperee(k) = puissancePV(k) .* temps_interval(k); % J
    
    
    % Calcul la force de traction appliquée par les moteurs (ne considère pas le freinage ni le regen)  % TODO : Ajouter le regen
    if profil_force_traction(k) > 0 % Si les moteurs fournissent un couple de traction
        profil_force_moteurs(k) = profil_force_traction(k);
    end
    
    profil_couple_moteurs(k) = profil_force_moteurs(k).*eclipse9.rayon_roue;
    profil_radSpeed(k) = profil_vitesse(k)./eclipse9.rayon_roue;
    
    [motorsLosses, drivesLosses, batteryLosses, outTempWinding, Ibatt(k)] = powerElecLosses(profil_couple_moteurs(k)/2, profil_radSpeed(k), constantes.tempAmbiant, tempWinding(k), SoC(k-1), cellModel);
    tempWinding(k) = outTempWinding;
    
    puissance_moteurs(k) = profil_force_moteurs(k).*parcours.distance_interval(k)./temps_interval(k); % W
    puissance_elec_totale(k) = (puissance_moteurs(k) + motorsLosses + drivesLosses + batteryLosses - puissancePV(k)) ; % W
    
    energie_mec_moteur(k) = sum(profil_force_moteurs(1:k).*parcours.distance_interval(1:k))/3.6e6; % kWh
    energie_depensee_totale(k) = puissance_elec_totale(k).* temps_interval(k) / 3600; % Wh
    
    
    SoC_Ah = 3.35 * (1-SoC(k-1));    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    Ebatt = 38 * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
    new_SoC_Ah = SoC_Ah + (energie_depensee_totale(k)/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
    newEbatt = 38 * polyval(cellModel.decharge0C2, new_SoC_Ah);
    new2_SoC_Ah = SoC_Ah + energie_depensee_totale(k)/newEbatt/11;
    newEbatt2 = 38 * polyval(cellModel.decharge0C2, new2_SoC_Ah);
    
    SoC(k) = (3.35 - new_SoC_Ah) / 3.35;
    
    if SoC(k) < contraintes.SoC_min
        SoC(k) = contraintes.SoC_min;
        outOfFuel = 1;
        %disp('OUT OF FUEL')
        %fprintf('Distance raced : %5.2d (km) \n', round(parcours.distance(k)));
        %fprintf('Percentage covered : %3.2f%%\n\n', parcours.distance(k)/parcours.distance(end)*100);
        %break;
    end
end
fprintf('Lap : %3d \n', etat_course.nbLap);
fprintf('SoC : %3.2d START\n', SoC(1));
fprintf('SoC : %3.2d END\n', SoC(end));
% SoC(1) = SoC(end);
% SoC(2) = SoC(end);

%% Valeurs de sortie de la fonction lapSimulator
lapLog.temps_cumulatif = temps_cumulatif;   % (s)
lapLog.SoC = SoC; % (%)
lapLog.Ibatt = Ibatt;   % Adc
lapLog.Vbatt = batteryModel(SoC, Ibatt); % Vdc
lapLog.profil_force_traction = profil_force_traction; % N
lapLog.profil_vitesse = profil_vitesse; % rad/s
lapLog.puissance_moteurs = puissance_moteurs; % W
lapLog.puissance_elec_totale = puissance_elec_totale; % W
lapLog.energie_fournie_totale = energie_depensee_totale; % Wh
lapLog.outOfFuel = outOfFuel;   % boolean
lapLog.heure_finale = heure; % datenum
end

