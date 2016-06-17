%% Éclipse 9
%  Optimisation d'un tour de piste chez PMG Technologies
%  
%  Permet de trouver un profil de vitesse optimal pour la voiture en
%  fonction d'un parcours prédéterminé.
%  
%  Auteur : Julien Longchamp
%  Date de création : 02-03-2016
%  Dernière modification : 01-04-2016 (JL)
%%

clc, clear all, close all

%% Importation du modèle des cellules NCR18650BF
cellModel = load('Eclipse9_cells_discharge.mat'); % Importation des courbes de décharge des batteries

%% IMPORTATION DES DONNÉES EN FORMAT .MAT DE L'ASC2016
%load('etapesASC2016_continuous.mat')
load('TrackPMGInner.mat')
% Choix du parcours (etape1, etape2, etape3 ou etape4)
%parcours = [etape1 etape2];
parcours = newParcours;

distance_totale = parcours.distance(end);   % km
nbPoints = length(parcours.distance);       % nombre d'intervals pour la simulation

% Nouvellement inclus dans le fichier interpolationGPSdata.m
% % Calcul manuel de la pente puisque la parcours.slope semble contenir n'importe quoi
% deniveles = [0; diff(parcours.altitude)];           % TODO : Inclure dans le fichier 'importGPSfromCSV.m'
% parcours.slope = 100*deniveles./parcours.distance_interval;
% for k=1:length(nbPoints)
%     parcours.slope(k) = mean(parcours.slope(max([1 k-20]):k));
% end

% Contraintes du parcours
vitesse_min = 60/3.6;   % m/s (60 km/h)
vitesse_moy = 80/3.6;   % m/s (80 km/h) *** VITESSE CIBLE ***
vitesse_max = 100/3.5;   % m/s (105 km/h)
vitesse_ini = 0;        % m/s
accel_nom = 0.03;       % m/s^2
accel_max = 1;          % m/s^2
decel_nom = -0.03;       % m/s^2
SoC_ini = 1.00;         % Initial State of Charge (%)
SoC_min = 0.25;       % Final State of Charge (%)

% Paramètres du véhicule Éclipse 9
masse_totale = 225;     % kg
aire_frontale = 1.25;   % m^2
coef_trainee = 0.135;   % coefficient de trainée aérodynamique
rayon_roue = 0.2575;    % m
surface_solaire = 6;    % m^2
nb_roue = 4;            % Nombre de roues
largeur_pneu = 0.03;    % m                                 ****** À VÉRIFIER **********
hauteur_roue = 0.3;    % m                                 ****** À VÉRIFIER **********

% Constantes physiques
const_grav = 9.81;      % m/s^2
mv_air = 1.15;     % kg/m^3
tempAmbiant = 300;  % Température ambiante (Kelvin)


% Paramètres des moteurs
nb_moteur = 2;
vitesse_nom = 111;  % rad/s
couple_nom = 16.2;  % Nm
couple_max = 42;    % Nm
Kv = 0.45;          % V/rad/s (Constante EMF)
Ka = 0.44;          % Nm/A (Constante de couple)
puissance_max = 1800; % W
Battery_full_capacity = 4.861;


% Initialisation des vecteurs pour la simulation
profil_vitesse = zeros(nbPoints,1);
temps_interval = zeros(nbPoints,1);
temps_cumulatif = zeros(nbPoints,1);
force_g = zeros(nbPoints,1);
force_aero = zeros(nbPoints,1);
force_drag_roues = zeros(nbPoints,1);
force_friction = zeros(nbPoints,1);
force_opposition_tot = zeros(nbPoints,1);
profil_force_tot = zeros(nbPoints,1);
profil_force_traction = zeros(nbPoints,1);
profil_radSpeed = zeros(nbPoints,1);
profil_accel = zeros(nbPoints,1);
profil_couple_moteurs = zeros(nbPoints,1);
profil_force_moteurs = zeros(nbPoints,1);
SoC = SoC_ini*ones(nbPoints,1);
tempWinding = 300*ones(nbPoints,1);  % Température ambiante (Kelvin)
% efficacite_moteurs = zeros(nbPoints,1);
% efficacite_drive = zeros(nbPoints,1);
% efficacite_battery = zeros(nbPoints,1);

outOfFuel = 0;
nbLaps = 0;
while outOfFuel == 0
    nbLaps = nbLaps + 1;
    %outOfFuel = 1;
    for k=2:nbPoints
        % Calcul des focres appliquées sur le véhicule
        force_g(k) = sin(atan(parcours.slope(k)/100))*masse_totale*const_grav; % fg = sin(pente)*m*g
        force_aero(k) = 0.5*mv_air*coef_trainee*aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
        force_drag_roues(k) = nb_roue * 0.5 * mv_air * profil_vitesse(k-1).^2 * ((largeur_pneu*hauteur_roue^3)/(2 * rayon_roue^2));     % ****** À VÉRIFIER **********
        force_friction(k) = 10; % ****** À VÉRIFIER **********       **********       **********        **********     **********       % ****** À VÉRIFIER **********
        force_opposition_tot(k) = force_g(k)+force_aero(k)+force_drag_roues(k);
        profil_force_tot(k) = force_opposition_tot(k);
        
        if (profil_vitesse(k-1) < vitesse_min)   % Si la vitesse actuelle est plus basse que la vitesse de croisière minimale (Typiquement au départ)
            accel(k) = accel_max;   % Pédale au plancher (Départ)
        else
            accel(k) = accel_nom;   % Accélération légère (En route)
        end
        
        if (profil_vitesse(k-1) < vitesse_moy)     % Si la vitesse actuelle est inférieure à la vitesse de croisière alors accélération
            %temps_interval(k) = sqrt(2.*parcours.distance_interval(k-1)./accel_max);
            %profil_vitesse(k) = profil_vitesse(k-1)+accel_max.*temps_interval(k);
            %force_consigne_accel(k) = masse_totale * accel_max;
            
            if force_opposition_tot(k) >= 0  % On accèlere seulement si la somme des forces d'opposition est positive sinon on lâche le gaz et on se laisse descendre la pente
                profil_force_tot(k) = force_opposition_tot(k) + masse_totale*accel(k);
            end
        else                                      % TODO : Ajouter une condition pour effectuer un freinage si la vitesse devient trop élevée (ie. descente de pente)
            %profil_vitesse(k) = profil_vitesse(k-1);    % Si la vitesse actuelle est inférieure à la vitesse de croisière alors pas d'accélération
            %temps_interval(k) = parcours.distance_interval(k)/profil_vitesse(k);
            %force_consigne_accel(k) = 0;
            profil_force_tot(k) = force_opposition_tot(k) + masse_totale*decel_nom;
        end
        
        
        profil_force_traction(k) = min(profil_force_tot(k), couple_max*nb_moteur/rayon_roue);
        profil_accel(k) = (profil_force_traction(k)-force_opposition_tot(k))/masse_totale;
        
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
        temps_cumulatif(k) = temps_cumulatif(k-1) + temps_interval(k);
        
        % Calcul la force de traction appliquée par les moteurs (ne considère pas le freinage ni le regen)  % TODO : Ajouter le regen
        if profil_force_traction(k) > 0 % Si les moteurs fournissent un couple de traction
            profil_force_moteurs(k) = profil_force_traction(k);
        end
        
        profil_couple_moteurs(k) = profil_force_moteurs(k).*rayon_roue;
        profil_radSpeed(k) = profil_vitesse(k)./rayon_roue;
        [motorsLosses, drivesLosses, batteryLosses, outTempWinding] = powerElecLosses(profil_couple_moteurs(k)/2, profil_radSpeed(k), tempAmbiant, tempWinding(k), SoC(k-1), cellModel);
        tempWinding(k) = outTempWinding;
        
        puissance_moteurs(k) = profil_force_moteurs(k).*parcours.distance_interval(k)./temps_interval(k); % W
        puissance_elec_totale(k) = (puissance_moteurs(k) + motorsLosses + drivesLosses + batteryLosses); % W

        energie_mec_moteur(k) = sum(profil_force_moteurs(1:k).*parcours.distance_interval(1:k))/3.6e6; % kWh
        %energie_fournie_traction(k) = sum(puissance_elec_totale(1:k))/3.6e6;   % kWh %% PAS BON PANTOUTE
        energie_fournie_totale(k) = puissance_elec_totale(k).* temps_interval(k) / 3600; % Wh
        
        
        SoC_Ah = 3.35 * (1-SoC(k-1));    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
        Ebatt = 38 * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
        new_SoC_Ah = SoC_Ah + (energie_fournie_totale(k)/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
        newEbatt = 38 * polyval(cellModel.decharge0C2, new_SoC_Ah);
        new2_SoC_Ah = SoC_Ah + energie_fournie_totale(k)/newEbatt/11;
        newEbatt2 = 38 * polyval(cellModel.decharge0C2, new2_SoC_Ah);
        
        SoC(k) = (3.35 - new_SoC_Ah) / 3.35;
                
        if SoC(k) < SoC_min
            SoC(k) = SoC_min;
            outOfFuel = 1;
            disp('OUT OF FUEL')
            fprintf('Distance raced : %5.2d (km) \n', round(parcours.distance(k)));
            fprintf('Percentage covered : %3.2f%%\n\n', parcours.distance(k)/parcours.distance(end)*100);
            %break;
        end
    end
    fprintf('Lap : %3d \n', nbLaps);
    fprintf('SoC : %3.2d START\n', SoC(1));
    fprintf('SoC : %3.2d END\n', SoC(end));
    SoC(1) = SoC(end);
    SoC(2) = SoC(end);
end


fprintf('Distance totale : %4.2d km\n', nbLaps.*parcours.distance(end));

figure, hold on, title('Force de traction totale excercée par les deux moteurs'), plot(temps_cumulatif, profil_force_traction), xlabel('Temps (s)')
figure, hold on, title('Profil de vitesse'), plot(temps_cumulatif, profil_vitesse*3.6), xlabel('Temps (s)')
%figure, hold on, title('Profil de vitesse'), plot(parcours.distance, profil_vitesse*3.6), xlabel('Distance (km)')
figure, hold on, title('Forces opposées au mouvement')
plot(force_g, 'r'),
plot(force_aero, 'b'),
plot(force_drag_roues, 'g'),
plot(force_friction, 'm'),
plot(ones(size(force_drag_roues)).*masse_totale*accel_max, '--k')
plot(ones(size(force_drag_roues)).*nb_moteur.*couple_max./rayon_roue, '--r')
legend('Force G', 'Drag aéro', 'Drag roue', 'Force friction', 'Force disponible', 'Force totale max')

% profil_force_moteurs = profil_force_traction';
% profil_force_moteurs(profil_force_moteurs<0) = 0;
% profil_couple_moteurs = profil_force_moteurs.*rayon_roue;
% profil_radSpeed = profil_vitesse./rayon_roue;
% tempAmbiant = 300;  % Température ambiante (Kelvin)
% tempWinding = 300;  % Température bobinage (Kelvin)
% [efficacite_moteurs, efficacite_drive, efficacite_battery, outTempWinding] = powerElecEfficiency(profil_couple_moteurs/2, profil_radSpeed, tempAmbiant, tempWinding, SoC);
% puissance_moteur = profil_force_moteurs.*parcours.distance_interval./temps_interval;
% puissance_fournie = profil_force_moteurs.*parcours.distance_interval./efficacite_moteurs./efficacite_drive;
% puissance_fournie(isnan(puissance_fournie)) = [];
% energie_mec_moteur = sum(profil_force_moteurs.*parcours.distance_interval)/3.6e6; % kWh
% energie_fournie_traction = sum(puissance_fournie)/3.6e6;   % kWh


% efficacite_moteur_disp = efficacite_moteurs(efficacite_moteurs>0);
% efficacite_drive_disp = efficacite_drive(efficacite_moteurs>0);
% figure, hold on
% subplot(2,1,1), plot(efficacite_moteur_disp*100), hold on, title('Efficacité des moteurs'), grid on
% subplot(2,1,2), plot(efficacite_drive_disp*100, 'r'), hold on, title('Efficacité de la drive'), grid on

figure, hold on, title('Puissance des moteurs'), plot(temps_cumulatif, puissance_moteurs)

heures_total = temps_cumulatif(end)/60/60
distance_totale = parcours.distance(end)
vitesse_moyenne = mean(profil_vitesse)*3.6 % Vitesse moyenne en km/h    %TODO : La vitesse moyenne n'est pas égale à la distance_totale/heures_total

figure, hold on, title('État de charge de la batterie'), plot(parcours.distance, SoC)

Pourcentage_batt_consommee = energie_fournie_totale(end)/Battery_full_capacity(end)
% parcours.profil_force_traction = profil_force_traction;
% parcours.force_opposition_tot = force_opposition_tot;
% parcours.profil_force_tot = profil_force_tot;
% parcours.profil_vitesse = profil_vitesse;
% parcours.temps_cumulatif = temps_cumulatif;
% parcours.temps_interval = temps_interval;
% 
% save('parcoursX.mat', 'parcours');
