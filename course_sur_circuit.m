%% Éclipse 9
%  Le script course_sur_circuit.m permet de simuler la performance d'une
%  voiture solaire sur un parcours sur circuit. L'objectif est de connaître
%  le nombre de tours que le véhicule peut réaliser en respectant la
%  capacité de la batterie.
%  
%  Auteur : Julien Longchamp
%  Date de création : 17-06-2016
%  Dernière modification : 
%%

clc, clear all, close all

% Ajout du chemin vers les outils nécessaires au fonctionnement du simulateur
addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils');
addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\SolarAzEl');

%% Importation des données du circuit à réaliser (Voir "traitementDonneesGPS.m")
%load('etapesASC2016_continuous.mat')
% load('TrackPMGInner10m.mat')
load('C:\Users\club\Git\StrategieCourseASC2016\PittRaceNorthTrack10m.mat')
parcours = newParcours;

%% Importation des modèles statiques
% Importation des courbes de décharge des cellules NCR18650BF
cellModel = load('Eclipse9_cells_discharge.mat');
% Charge les coefficients de la courbe de l'irradiance du 41e parallèle Nord.  **** Voir le fichier TESTsolarradiation.m pour plus de détails. ****
load('SolarIrradianceLat41N.mat', 'irrandiance_coef');


%% Contraintes du parcours
contraintes.vitesse_min = 60/3.6;   % m/s (60 km/h)
contraintes.vitesse_moy = 73/3.6;   % m/s (80 km/h) *** VITESSE CIBLE ***
contraintes.vitesse_max = 120/3.5;   % m/s (105 km/h)
contraintes.vitesse_ini = 0;        % m/s
contraintes.accel_nom = 0.1;        % m/s^2
contraintes.accel_max = 1;          % m/s^2
contraintes.decel_nom = -0.03;      % m/s^2
contraintes.SoC_ini = 1;          % Initial State of Charge (%)
contraintes.SoC_min = 0.30;         % Final State of Charge (%)

%% Paramètres du véhicule Éclipse 9
eclipse9.masse_totale = 275;     % kg % ÉCLIPSE 9 SANS COQUE
eclipse9.aire_frontale = 1.25;   % m^2
eclipse9.coef_trainee = 0.135;   % coefficient de trainée aérodynamique           ****** À VÉRIFIER **********
%eclipse9.coef_trainee = 0.25;      % ÉCLIPSE 9 SANS COQUE
eclipse9.frottement = 58;       % N
eclipse9.rayon_roue = 0.271;    % m                                           ****** À VÉRIFIER **********
eclipse9.surface_solaire = 5.994;    % m^2
eclipse9.nb_roue = 4;            % Nombre de roues
eclipse9.largeur_pneu = 0.03;    % m                                 ****** À VÉRIFIER **********
eclipse9.hauteur_roue = 2*eclipse9.rayon_roue;     % m               ****** À VÉRIFIER **********
eclipse9.nb_moteur = 2;
eclipse9.vitesse_nom = 111;    % rad/s (Pour un moteur)
eclipse9.couple_nom = 16.2;    % Nm    (Pour un moteur)
eclipse9.couple_max = 42;      % Nm    (Pour un moteur)
eclipse9.puissance_max = 1800; % W     (Pour un moteur)

%% Constantes physiques     % TODO : À remplacer par des vecteurs fournies par le module Eagle Tree
constantes.const_grav = 9.81;      % m/s^2
constantes.tempAmbiant = 273.15+20;  % Température ambiante (Kelvin)
constantes.absolutePressure = 102.4; % Pa
constantes.specificAirConstant = 287.058; % J/(kg*K)
constantes.mv_air = 1000*constantes.absolutePressure/(constantes.specificAirConstant*constantes.tempAmbiant);     % kg/m^3         % TODO : Transformer en équation en fonction de la pression atmosphérique et de la température
constantes.vitesse_vent = 20/3.6; % m/s
constantes.direction_vent = 220; % degrés
constantes.irrandiance_coef = irrandiance_coef; % Coefficients du polinôme représentant la densité de puissance incidente du soleil
constantes.densite_de_puissance_incidente = 800; % W/m^2                ******* TODO : À changer *******

%% Valeurs initiales au départ
etat_course.SoC_start = 1.00;
etat_course.nbLap = 0;
etat_course.vitesse_ini = 0; % m/s
etat_course.heure_depart = datenum([2016,07,03,8,30,0]); % Format de l'heure : [yyyy, mm, jj, hh, mm, ss]

outOfFuel = 0;
while outOfFuel == 0
    etat_course.nbLap = etat_course.nbLap+1;
    lapLog(etat_course.nbLap) = lapSimulator(parcours, etat_course, cellModel, contraintes, eclipse9, constantes);
    
    etat_course.SoC_start = lapLog(etat_course.nbLap).SoC(end);    
    etat_course.vitesse_ini = lapLog(etat_course.nbLap).profil_vitesse(end);
    
    if mod(lapLog(etat_course.nbLap).heure_finale,1) > 0.7292
        disp('Fin de la journée')
        etat_course.heure_depart = datenum([2016,07,04,8,30,0]);
    else
        etat_course.heure_depart = lapLog(etat_course.nbLap).heure_finale;
    end
    outOfFuel = lapLog(etat_course.nbLap).outOfFuel;    
end

for k = 1:length(lapLog)
    vitesse_moyenne(k) = mean(lapLog(k).profil_vitesse);
    puissance_moyenne(k) = mean(lapLog(k).puissance_elec_traction);
end
vitesse_moyenne_totale = mean(vitesse_moyenne);
puissance_moyenne_totale = mean(puissance_moyenne);

fprintf('\nLa voiture s''est arrêtée après %3d tours \n', etat_course.nbLap);
fprintf('Distance parcourue %3.2f km \n', etat_course.nbLap*parcours.distance(end));
fprintf('Vitesse moyenne %3.2f km/h \n', vitesse_moyenne_totale*3.6);
fprintf('Puissance moyenne %3.2f W \n', puissance_moyenne_totale);

figure, hold on, grid on
title('FSGP 2016')
for k = 1:length(lapLog)
%plot3(parcours.latitude, parcours.longitude, lapLog(k).profil_vitesse*3.6);
%plot3(parcours.latitude, parcours.longitude, lapLog(k).energie_fournie_totale);

plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissance_elec_totale, 'b')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissancePV, 'r')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissance_moteurs, 'k')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).SoC*1000, '--m')
end
% xlabel('Longitude')
% ylabel('Latitude')
%zlabel('Speed (kph)')
%zlabel('Energy consumption (Wh)')

xlabel('distance (km)')
ylabel('puissance (W)')
legend('ELE', 'PV', 'MEC', 'SoC');



A = parcours.latitude;
B = parcours.longitude;
C = lapLog(1).puissance_elec_totale;
D = lapLog(1).energie_fournie_totale ./ lapLog(1).Vbatt;
E = lapLog(1).temps_cumulatif;
save('dataTour50kmh.mat', 'A', 'B', 'C', 'D', 'E')


