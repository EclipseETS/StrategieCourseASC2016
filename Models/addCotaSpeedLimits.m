%% addCotaSpeedLimits.m

clc, clear all, close all

% addpath('C:\Git\StrategieCourseASC2016'); % Temporary
load('../Data/FSGP2017_CircuitOfTheAmericas10m.mat') % Octave
targetFile = '../Data/FSGP2017_CircuitOfTheAmericas10mLimited.mat';

parcours = newParcours;

% G�n�re des figures 2D et 3D du parcours.
figure, hold on, title('Carte 2D du parcours')
plot(parcours.latitude, parcours.longitude, '*')
plot(newParcours.latitude, newParcours.longitude, '.r')
legend('Donn�es brutes', 'Donn�es trait�es', 'location', 'southeast')
xlabel('Longitude')
ylabel('Latitude')

figure, hold on, title('Carte 3D du parcours (Bonne orientation)'), grid on
plot3(parcours.longitude, parcours.latitude, parcours.altitude, '*')
plot3(newParcours.longitude, newParcours.latitude, newParcours.altitude, 'r.')
legend('Donn�es brutes', 'Donn�es trait�es', 'location', 'southeast')
xlabel('Longitude')
ylabel('Latitude')
zlabel('Altitude (m)')

figure, hold on, title('Altitude')
plot(parcours.distance, parcours.altitude, '.')
plot(newParcours.distance, newParcours.altitude, 'r.')
legend('Donn�es brutes', 'Donn�es trait�es')
xlabel('Distance (km')
ylabel('Altitude (m)')

figure, hold on, title('Pente filtr�e')
plot(newParcours.distance, newParcours.slope)
xlabel('Distance (km')
ylabel('Pente (%)')


figure, hold on, title('Altitude')
plot(parcours.altitude, '.')
legend('Donn�es brutes', 'Donn�es trait�es')
xlabel('Points')
ylabel('Altitude (m)')


%% D�finition des bornes des zones de limite de vitesse
% L'objectif du pilote est d'atteindre la limite � l'entr�e du virage situ� � la fin de la zone.
zA_start = 180;%201; % Virages 9-10-11
zA_stop = 266;
zB_start = 347; % Virages 11D - 12
zB_stop = 390;
zC_start = 477; % Virages 17-18-19
zC_stop = 543;

figure, hold on, title('Carte 2D du parcours avec limites de vitesse')
plot(parcours.longitude, parcours.latitude, 'og')
plot(parcours.longitude(zA_start:zA_stop), parcours.latitude(zA_start:zA_stop), '*r') 
plot(parcours.longitude(zB_start:zB_stop), parcours.latitude(zB_start:zB_stop), '*m') 
plot(parcours.longitude(zC_start:zC_stop), parcours.latitude(zC_start:zC_stop), '*m') 
legend('Pas de limite', '20 km/h', '30 km/h', '30 km/h', 'location', 'southeast')
xlabel('Longitude')
ylabel('Latitude')


%% Ajout de l'information sur la vitesse maximale du parcours
% Les limites de vitesses ont �t� fix�es par l'�quipe de la strat�gie de course FSGP2017.
newParcours.speedLimit = 150*ones(size(newParcours.latitude)); % Vitesse maximale par d�faut de 150 km/h
newParcours.speedLimit(zA_start:zA_stop) = 20; % km/h
newParcours.speedLimit(zB_start:zB_stop) = 30; % km/h
newParcours.speedLimit(zC_start:zC_stop) = 30; % km/h

save(targetFile, 'newParcours');