% %% Éclipse 9
% %  analyseTelemetryASC.m
% %  Permet de caractériser la voiture solaire Éclipse 9 à partir des
% %  fichiers de log des essais réalisés à la ASC 2016
% %  
% %
% %  Auteur : Julien Longchamp
% %  Date de création : 30-07-2016
% %  Dernière modification :
% %%
clc, clear all, close all

flagRealGPS = 1;
flagLog = 0;

% Ajout du chemin vers les outils nécessaires au fonctionnement du simulateur
addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils');

% %% Importation des données du circuit à réaliser (Voir "traitementDonneesGPS.m")
% %load('etapesASC2016_continuous.mat')
% % load('ASC2016_stage1_plus_speed.mat')
% % parcours = newParcours;
% 
% 
% % % % realGPS = csvread('R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\PittRaceNorthTrackREAL.csv');
% realGPS = csvread('R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_route_stage1_REAL.CSV');
% realLatitude = realGPS(:,7);
% realLongitude = realGPS(:,8);
% realAltitude = realGPS(:,9);
% realSlope = realGPS(:,10);

if flagRealGPS
% % realGPS = xlsread('R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_route_stage1_REAL.CSV');
% realGPS = xlsread('C:\Users\Strategy\Documents\LogTelemetry\NewLogs\DonneesMatlabTraitees\gps_2016_07_30_17_00_04.xlsx');
% realGPS = csvread('R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_route_stage1_REAL.CSV');
% realGPS = csvread('C:\Users\Strategy\Documents\LogTelemetry\DonneesMatlabTraitees31\GPS.csv');
realGPS = csvread('C:\Users\Strategy\Documents\LogTelemetry\GPS\GPS.csv');
realtime = datenum( realGPS(:,3), realGPS(:,2), realGPS(:,1), realGPS(:,4), realGPS(:,5), realGPS(:,6));    %DateNumber = datenum(Y,M,D,H,MN,S)
realLatitude = realGPS(:,7);
realLongitude = realGPS(:,8);
realAltitude = realGPS(:,9);
realSpeed = realGPS(:,10);
calcDistance = zeros(size(realAltitude));
for k = 2:length(realLatitude)
    calcDistance(k) =lldistkm([realLatitude(k) realLongitude(k)],[realLatitude(k-1) realLongitude(k-1)]);
end
real_tm = [0; diff(realtime)*60*60];%mod(realtime,1)*60;
calcSpeed = calcDistance./(real_tm*60);
calcSpeed(isnan(calcSpeed)) = 0;

load('ASC2016_stage2_plus_speed.mat')
parcours = newParcours;

figure, grid on, hold on
plot3(parcours.latitude, parcours.longitude, parcours.altitude)
plot3(realLatitude, realLongitude, realAltitude, 'r')

figure, grid on, hold on
plot(cumsum(real_tm), cumsum(calcDistance))
plot(real_tm, calcSpeed, 'r')
end

if flagLog
%% Choisir le dossier contenant le log
% dir_path = ('C:\Users\Strategy\Documents\LogTelemetry\DonneesMatlabTraitees31')
dir_path = ('C:\Users\Strategy\Documents\LogTelemetry\DonnesMatlabTraitees01')
% dir_path = ('C:\Users\Strategy\Documents\LogTelemetry\NewLogs\DonneesMatlabTraitees')
addpath(dir_path);
log_list = dir(dir_path);
filename = log_list(5).name

data = xlsread(filename);
heure = data(:,1);
mppt1current = data(:,2);
mppt2current = data(:,3);
mppt3current = data(:,4);
mppt1tension = data(:,5);
mppt2tension = data(:,6);
mppt3tension = data(:,7);
battCurrent = data(:,8)/100;
avgCellVoltage = data(:,9)/1000;
dt = diff(heure)./min(diff(heure));
ts = [0; cumsum(dt)]; % En secondes
tm = ts/60; % En minutes
th = tm/60; % En heures

battVoltage = 38*avgCellVoltage;
puissancePV = (mppt1current.*mppt1tension)+(mppt2current.*mppt2tension)+(mppt3current.*mppt3tension);
puissanceBatt = battCurrent.*battVoltage;
puissanceElec = puissanceBatt-puissancePV;

FIRsize = 60; % Largeur de la fenêtre du filtre passe-bas de type FIR ordre 1
for k=1:length(puissanceElec)
    puissanceElec2(k) = mean(puissanceElec(max([1 k-FIRsize]):k));
end
% Les donnees sont décalées pour compenser le retard introduit par le filtre
puissanceElec2 = [puissanceElec2(FIRsize+1:end)  puissanceElec2(1:FIRsize) ];


figure, grid on, hold on
plot(tm, battVoltage, '--b')
plot(tm, battCurrent, '.b')
plot(tm, mppt1tension, '--r')
plot(tm, mppt1current, '.r')

figure, grid on, hold on
plot(tm, puissancePV, 'g')
plot(tm, puissanceBatt, 'b')
plot(tm, puissanceElec, 'r')
% plot(tm, puissanceElec2, 'dm')
 legend('PV', 'Batterie', 'Elec')
end 
% 
% 
% mv_air = 1000*102.1/(287.058*(273.15+30.9));
% aire_frontale = 1.25;
% % Cx = (forceA - forceB) / (.5*mv_air*aire_frontale*v_relatifA^2-0.5*mv_air*aire_frontale*v_relatifB^2)
% 
% v50 = 50/3.6;
% v60 = 60/3.6;
% puissance50 = 1200; % W
% puissance60 = 1600; % W
% force50 = puissance50/v50; % N
% force60 = puissance60/v60; % N
% 
% Cx = (force60 - force50) / (.5*mv_air*aire_frontale*v60^2-0.5*mv_air*aire_frontale*v50^2) 
% 
% Fr50 = force50 - (0.5*mv_air*aire_frontale*Cx*v50^2)
% Fr60 = force60 - (0.5*mv_air*aire_frontale*Cx*v60^2) 


mv_air = 1000*102.1/(287.058*(273.15+30.9));
aire_frontale = 1.25;
% Cx = (forceA - forceB) / (.5*mv_air*aire_frontale*v_relatifA^2-0.5*mv_air*aire_frontale*v_relatifB^2)

v50 = 50/3.6;
v60 = 60/3.6;
puissance50 = 1200; % W
puissance60 = 1600; % W
force50 = puissance50/v50; % N
force60 = puissance60/v60; % N

Cx = (force60 - force50) / (.5*mv_air*aire_frontale*v60^2-0.5*mv_air*aire_frontale*v50^2) 

Fr50 = force50 - (0.5*mv_air*aire_frontale*Cx*v50^2)
Fr60 = force60 - (0.5*mv_air*aire_frontale*Cx*v60^2) 


