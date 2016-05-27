%% Éclipse 9
%  Optimisation d'une étape de l'ASC2016
%  
%  Permet de trouver un profil de vitesse optimal pour la voiture en
%  fonction d'un parcours prédéterminé.
%  
%  Auteur : Julien Longchamp
%  Date de création : 02-03-2016
%  Dernière modification : 01-04-2016 (JL)
%%

clc, clear all, close all

%% IMPORTATION DES DONNÉES EN FORMAT .MAT DE L'ASC2016
load('etapesASC2016_continuous.mat')

parcours = etape1;

distance_totale = parcours.distance(end);   % km
nbPoints = length(parcours.distance);       % nombre d'intervals pour la simulation

% Calcul manuel de la pente puisque la parcours.slope semble contenir n'importe quoi
deniveles = [0; diff(parcours.altitude)];           % TODO : Inclure dans le fichier 'importGPSfromCSV.m'
parcours.pente = 100*deniveles./parcours.distance_interval;
for k=1:length(nbPoints)
    parcours.pente(k) = mean(parcours.pente(max([1 k-20]):k));
end

% Contraintes du parcours
vitesse_min = 60/3.6;   % m/s (60 km/h)
vitesse_moy = 80/3.6;   % m/s (80 km/h) *** VITESSE CIBLE ***
vitesse_max = 100/3.5;   % m/s (105 km/h)
vitesse_ini = 0;        % m/s
accel_max = 1.3;        % m/s^2
decel_nom = -0.1;      % m/s^2
SoC_ini = 1.00;          % Initial State of Charge (%)
SoC_final = 0.10;        % Final State of Charge (%)

% Paramètres du véhicule Éclipse 9
masse_totale = 225;     % kg
aire_frontale = 1.14;   % m^2
coef_trainee = 0.135;   % coefficient de trainée aérodynamique
rayon_roue = 0.2575;    % m
surface_solaire = 6;    % m^2
nb_roue = 4;            % Nombre de roues
largeur_pneu = 0.03;    % m                                 ****** À VÉRIFIER **********
hauteur_roue = 0.3;    % m                                 ****** À VÉRIFIER **********

% Constantes physiques
const_grav = 9.81;      % m/s^2
mv_air = 1.15;     % kg/m^3

% Paramètres des moteurs
nb_moteur = 2;
vitesse_nom = 111;  % rad/s
couple_nom = 16.2;  % Nm
couple_max = 42;    % Nm
Kv = 0.45;          % V/rad/s (Constante EMF)
Ka = 0.44;          % Nm/A (Constante de couple)
puissance_max = 1800; % W



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
SoC = zeros(nbPoints,1);
for k=2:nbPoints    
    % Calcul des focres appliquées sur le véhicule
    force_g(k) = sin(atan(parcours.pente(k)/100))*masse_totale*const_grav; % fg = sin(pente)*m*g
    force_aero(k) = 0.5*mv_air*coef_trainee*aire_frontale*profil_vitesse(k-1).^2; % fa = 1/2*rho*Cx*S*V^2
    force_drag_roues(k) = nb_roue * 0.5 * mv_air * profil_vitesse(k-1).^2 * ((largeur_pneu*hauteur_roue^3)/(2 * rayon_roue^2));     % ****** À VÉRIFIER **********
    force_friction(k) = 10; % ****** À VÉRIFIER **********                                                                          % ****** À VÉRIFIER **********  
    force_opposition_tot(k) = force_g(k)+force_aero(k)+force_drag_roues(k);
    profil_force_tot(k) = force_opposition_tot(k);
    
    if(profil_vitesse(k-1) < vitesse_moy)     % Si la vitesse actuelle est inférieure à la vitesse de croisière alors accélération
        %temps_interval(k) = sqrt(2.*parcours.distance_interval(k-1)./accel_max);
        %profil_vitesse(k) = profil_vitesse(k-1)+accel_max.*temps_interval(k);
        %force_consigne_accel(k) = masse_totale * accel_max;
        
        if force_opposition_tot(k) > 0  % On accèlere seulement si la somme des forces d'opposition est positive sinon on lâche le gaz et on se laisse descendre la pente
            profil_force_tot(k) = force_opposition_tot(k) + masse_totale*accel_max;
        end
    else                                      % TODO : Ajouter une condition pour effectuer un freinage si la vitesse devient trop élevée (ie. descente de pente) 
        %profil_vitesse(k) = profil_vitesse(k-1);    % Si la vitesse actuelle est inférieure à la vitesse de croisière alors pas d'accélération
        %temps_interval(k) = parcours.distance_interval(k)/profil_vitesse(k);
        %force_consigne_accel(k) = 0;
        profil_force_tot(k) = force_opposition_tot(k) + masse_totale*decel_nom;
    end
       
  
    profil_force_traction(k) = min(profil_force_tot(k), couple_max*nb_moteur/rayon_roue);    
    profil_accel(k) = (profil_force_traction(k)-force_opposition_tot(k))/masse_totale;
    
    if (profil_accel(k) > 0)
        temps_interval(k) = sqrt(2.*parcours.distance_interval(k)./abs(profil_accel(k)));
    else
        temps_interval(k) = parcours.distance_interval(k)/profil_vitesse(k-1);
    end
    profil_vitesse(k) = profil_vitesse(k-1)+profil_accel(k).*temps_interval(k);
    temps_cumulatif(k) = temps_cumulatif(k-1) + temps_interval(k);    
    
end

figure, hold on, title('Force de traction'), plot(temps_cumulatif, profil_force_traction)
figure, hold on, title('Profil de vitesse'), plot(temps_cumulatif, profil_vitesse*3.6);
figure, hold on, title('Profil de vitesse'), plot(parcours.distance, profil_vitesse*3.6);
figure, hold on, title('Forces opposées au mouvement')
plot(force_g, 'r')
plot(force_aero)
plot(force_drag_roues, 'g')
plot(force_friction, 'm')
plot(ones(size(force_drag_roues)).*masse_totale*accel_max, '--k')

% Calcul la force de traction appliquée par les moteurs (ne considère pas
% le freinage ni le regen)
profil_force_moteurs = profil_force_traction';
profil_force_moteurs(profil_force_moteurs<0) = 0;
profil_couple_moteurs = profil_force_moteurs.*rayon_roue;
radSpeed = profil_vitesse./rayon_roue;
tempAmbiant = 300;
tempWinding = 300;
[efficacite_moteur, efficacite_drive, efficacite_battery, outTempWinding] = powerElecEfficiency(profil_couple_moteurs/2, radSpeed, tempAmbiant, tempWinding, SoC);
puissance_moteur = profil_force_moteurs.*parcours.distance_interval./temps_interval;
puissance_fournie = profil_force_moteurs.*parcours.distance_interval./efficacite_moteur./efficacite_drive;
puissance_fournie(isnan(puissance_fournie)) = [];
energie_mec_moteur = sum(profil_force_moteurs.*parcours.distance_interval)/3.6e6; % kWh
energie_fournie_traction = sum(puissance_fournie)/3.6e6;   % kWh

efficacite_moteur_disp = efficacite_moteur(efficacite_moteur>0);
efficacite_drive_disp = efficacite_drive(efficacite_moteur>0);
figure,
subplot(2,1,1), plot(efficacite_moteur_disp*100), hold on, title('Efficacité des moteurs')
subplot(2,1,2), plot(efficacite_drive_disp*100, 'r'), hold on, title('Efficacité de la drive')

figure, hold on, title('Puissance des moteurs'), plot(temps_cumulatif, puissance_moteur)

minutes_total = temps_cumulatif(end)/60/60
distance_totale = parcours.distance(end)




% parcours.profil_force_traction = profil_force_traction;
% parcours.force_opposition_tot = force_opposition_tot;
% parcours.profil_force_tot = profil_force_tot;
% parcours.profil_vitesse = profil_vitesse;
% parcours.temps_cumulatif = temps_cumulatif;
% parcours.temps_interval = temps_interval;
% 
% save('parcoursX.mat', 'parcours');
