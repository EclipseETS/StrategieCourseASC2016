%% �clipse 9
%  Le script course_sur_circuit.m permet de simuler la performance d'une
%  voiture solaire sur un parcours sur circuit. L'objectif est de conna�tre
%  le nombre de tours que le v�hicule peut r�aliser en respectant la
%  capacit� de la batterie.
%  
%  Auteur : Julien Longchamp
%  Date de cr�ation : 17-06-2016
%  Derni�re modification : 
%%

clc, clear all, close all

%% Importation des donn�es du circuit � r�aliser (Voir "traitementDonneesGPS.m")
%load('etapesASC2016_continuous.mat')
load('TrackPMGInner10m.mat')
%load('C:\Users\club\Git\StrategieCourseASC2016\PittRaceNorthTrack10m.mat')
parcours = newParcours;

%% Importation du mod�le des cellules NCR18650BF
cellModel = load('Eclipse9_cells_discharge.mat'); % Importation des courbes de d�charge des batteries

%% Contraintes du parcours
contraintes.vitesse_min = 40/3.6;   % m/s (60 km/h)
contraintes.vitesse_moy = 50/3.6;   % m/s (80 km/h) *** VITESSE CIBLE ***
contraintes.vitesse_max = 70/3.5;   % m/s (105 km/h)
contraintes.vitesse_ini = 0;        % m/s
contraintes.accel_nom = 0.5;       % m/s^2
contraintes.accel_max = 1;          % m/s^2
contraintes.decel_nom = -0.03;       % m/s^2
contraintes.SoC_ini = .95;         % Initial State of Charge (%)
contraintes.SoC_min = 0.30;       % Final State of Charge (%)

%% Param�tres du v�hicule �clipse 9
eclipse9.masse_totale = 225;     % kg % �CLIPSE 9 SANS COQUE
eclipse9.aire_frontale = 1.25;   % m^2
%eclipse9.coef_trainee = 0.135;   % coefficient de train�e a�rodynamique           ****** � V�RIFIER **********
eclipse9.coef_trainee = 0.25;      % �CLIPSE 9 SANS COQUE
eclipse9.frottement = 100;       % N
eclipse9.rayon_roue = 0.2775;    % m                                           ****** � V�RIFIER **********
eclipse9.surface_solaire = 6;    % m^2
eclipse9.nb_roue = 4;            % Nombre de roues
eclipse9.largeur_pneu = 0.03;    % m                                 ****** � V�RIFIER **********
eclipse9.hauteur_roue = 2*eclipse9.rayon_roue;     % m               ****** � V�RIFIER **********
eclipse9.nb_moteur = 2;
eclipse9.vitesse_nom = 111;    % rad/s (Pour un moteur)
eclipse9.couple_nom = 16.2;    % Nm    (Pour un moteur)
eclipse9.couple_max = 42;      % Nm    (Pour un moteur)
eclipse9.puissance_max = 1800; % W     (Pour un moteur)

%% Constantes physiques     % TODO : � remplacer par des vecteurs fournies par le module Eagle Tree
constantes.const_grav = 9.81;      % m/s^2
constantes.tempAmbiant = 273.15+20;  % Temp�rature ambiante (Kelvin)
constantes.absolutePressure = 102.4; % Pa
constantes.specificAirConstant = 287.058; % J/(kg*K)
constantes.mv_air = 1000*constantes.absolutePressure/(constantes.specificAirConstant*constantes.tempAmbiant);     % kg/m^3         % TODO : Transformer en �quation en fonction de la pression atmosph�rique et de la temp�rature
constantes.vitesse_vent = 20/3.6; % m/s
constantes.direction_vent = 220; % degr�s
constantes.densite_de_puissance_incidente = 800; % W/m^2                ******* TODO : � changer *******

%% Valeurs initiales au d�part
etat_course.SoC_start = 1.00;
etat_course.nbLap = 0;
etat_course.vitesse_ini = 0; % m/s
etat_course.heure_depart = datenum([2016,07,03,13,0,0]); % Format de l'heure : [yyyy, mm, jj, hh, mm, ss]

outOfFuel = 0;
while outOfFuel == 0
    etat_course.nbLap = etat_course.nbLap+1;
    lapLog(etat_course.nbLap) = lapSimulator(parcours, etat_course, cellModel, contraintes, eclipse9, constantes);
    
    etat_course.SoC_start = lapLog(etat_course.nbLap).SoC(end);    
    etat_course.vitesse_ini = lapLog(etat_course.nbLap).profil_vitesse(end);
    etat_course.heure_depart = lapLog(etat_course.nbLap).heure_finale;
    outOfFuel = lapLog(etat_course.nbLap).outOfFuel;    
end

for k = 1:length(lapLog)
    vitesse_moyenne(k) = mean(lapLog(k).profil_vitesse);
    puissance_moyenne(k) = mean(lapLog(k).puissance_elec_totale);
end
vitesse_moyenne_totale = mean(vitesse_moyenne);
puissance_moyenne_totale = mean(puissance_moyenne);

fprintf('\nLa voiture s''est arr�t�e apr�s %3d tours \n', etat_course.nbLap);
fprintf('Distance parcourue %3.2f km \n', etat_course.nbLap*parcours.distance(end));
fprintf('Vitesse moyenne %3.2f km/h \n', vitesse_moyenne_totale*3.6);
fprintf('Puissance moyenne %3.2f W \n', puissance_moyenne_totale);

figure, hold on, grid on
title('FSGP 2016')
for k = 1:length(lapLog)
plot3(parcours.latitude, parcours.longitude, lapLog(k).profil_vitesse*3.6);
%plot3(parcours.latitude, parcours.longitude, lapLog(k).energie_fournie_totale);
end
xlabel('Longitude')
ylabel('Latitude')

zlabel('Speed (kph)')
%zlabel('Energy consumption (Wh)')


A = parcours.latitude;
B = parcours.longitude;
C = lapLog(1).puissance_elec_totale;
D = lapLog(1).energie_fournie_totale ./ lapLog(1).Vbatt;
E = lapLog(1).temps_cumulatif;
save('dataTour50kmh.mat', 'A', 'B', 'C', 'D', 'E')


