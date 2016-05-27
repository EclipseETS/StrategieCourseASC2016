%% Éclipse 9
%  Simulateur de la dynamique du véhicule
%  
%  Auteur : Julien Longchamp
%  Date de création : 24-02-2016
%%

clc
clear all
close all

% %% IMPORTATION DES DONNÉES GPS PROVENANT DE FICHIERS CSV
% % Charge un parcours dont le format est [Type Latitude Longitude Altitude(m) Distance(km) Interval(m)]
% etape1 = importGPSfromCSV('R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape1.csv');
% etape2 = importGPSfromCSV('R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape2.csv');
% etape3 = importGPSfromCSV('R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape3.csv');
% etape4 = importGPSfromCSV('R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape4.csv');
% 
% % etape1 = importGPSfromCSV('donnees_gps\ASC2016_etape1.csv');
% % etape2 = importGPSfromCSV('donnees_gps\ASC2016_etape2.csv');
% % etape3 = importGPSfromCSV('donnees_gps\ASC2016_etape3.csv');
% % etape4 = importGPSfromCSV('donnees_gps\ASC2016_etape4.csv');
% 
% % Sauvegarde des données en format .mat
% save('etapesASC2016.mat', 'etape1', 'etape2', 'etape3', 'etape4');
% % FIN IMPORTATION DES DONNÉES GPS PROVENANT DE FICHIERS CSV

%% IMPORTATION DES DONNÉES EN FORMAT .MAT DE L'ASC2016
load('etapesASC2016_continuous.mat')
%load('etapesASC2016.mat')



% Concaténation des 4 étapes pour constituer le parcours complet
trajet_complet.latitude = [etape1.latitude; etape2.latitude; etape3.latitude; etape4.latitude];
trajet_complet.longitude = [etape1.longitude; etape2.longitude; etape3.longitude; etape4.longitude];
trajet_complet.altitude = [etape1.altitude; etape2.altitude; etape3.altitude; etape4.altitude];
trajet_complet.slope = [etape1.slope; etape2.slope; etape3.slope; etape4.slope];
trajet_complet.distance = [etape1.distance; etape1.distance(end)+etape2.distance; etape1.distance(end)+etape2.distance(end)+etape3.distance; etape1.distance(end)+etape2.distance(end)+etape3.distance(end)+etape4.distance];
trajet_complet.distance_interval = [etape1.distance_interval; etape2.distance_interval; etape3.distance_interval; etape4.distance_interval];

parcours = trajet_complet;

% Prétraitement de la pente (parcours.slope) à l'aide d'un FIR rectangulaire
for k=1:length(parcours.slope)
    parcours.slope(k) = mean(parcours.slope(max([1 k-100]):k));
    parcours.altitude(k) = mean(parcours.altitude(max([1 k-30]):k));
end

grade = zeros(size(parcours.slope));
for k=2:length(grade)
    grade(k) = 100*(parcours.altitude(k)-parcours.altitude(k-1))/(parcours.distance_interval(k));
end

% Calcul de la pente avec une moyenne sur 20 points
deniveles = [0; diff(parcours.altitude)];
pente = 100*deniveles./parcours.distance_interval;
for k=1:length(pente)
    pente(k) = mean(pente(max([1 k-20]):k));
end
ascention_tot = sum(deniveles.*(sign(deniveles)+1)/2)
descente_tot= sum(deniveles.*(sign(deniveles)-1)/-2)

figure, hold on, title('Carte 2D du parcours');
plot(parcours.longitude, parcours.latitude);

figure, hold on,  title('Carte 3D du parcours');
grid on
plot3(parcours.longitude, parcours.latitude, parcours.altitude);

figure, hold on,  title('Élévation du parcours');
subplot(2,1,1), plot(parcours.distance, parcours.altitude)
ylabel('Altitude (m)')
subplot(2,1,2), plot(parcours.distance, parcours.slope)
hold on, plot(parcours.distance, pente, 'r')
plot(parcours.distance, grade, 'g')
ylabel('Pente (%)')
xlabel('Distance (km)')


figure, hold on,  title('Élévation du parcours');
subplot(2,1,1), plot(parcours.distance, parcours.altitude)
ylabel('Altitude (m)')
subplot(2,1,2), plot(parcours.distance, parcours.slope)
hold on, plot(parcours.distance, pente, 'r')
ylabel('Pente (%)')
xlabel('Distance (km)')

% Paramètres du véhicule Éclipse 9
masse_totale = 225;     % kg
aire_frontale = 1.14;   % m^2
coef_trainee = 0.135;   % coefficient de trainée aérodynamique
rayon_roue = 0.2575;    % m
surface_solaire = 6;    % m^2

% Constantes physiques
const_grav = 9.81;      % m/s^2
densite_air = 1.15;     % kg/m^3

% Paramètres des moteurs
nb_moteur = 2;
vitesse_nom = 111;  % rad/s
couple_nom = 16.2;  % Nm
Kv = 0.45;          % V/rad/s (Constante EMF)
Ka = 0.44;          % Nm/A (Constante de couple)
puissance_max = 1800; % W



figure, hold on, title('distance interval')
plot3(etape1.longitude, etape1.latitude, etape1.distance_interval);
plot3(etape1.longitude, etape1.latitude, [diff(etape1.distance)*1000; 0]);

figure, hold on
plot(etape1.distance_interval)
plot([0; diff(etape1.distance)*1000], 'r')
plot(etape1.distance_interval-[0; diff(etape1.distance)*1000], 'm')


