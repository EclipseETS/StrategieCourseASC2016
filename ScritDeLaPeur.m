%% INFORMATION CONFIDENTIELLE
%% ECLIPSE IX

%  Auteur : Julien Longchamp
%  Date de création : 01-08-2016
%  Dernière modification : 
%%

clc, clear all, close all

realGPS = csvread('C:\Users\Strategy\Documents\LogTelemetry\DonnesMatlabTraitees01\GPS.csv');
realtime = datenum( realGPS(:,3), realGPS(:,2), realGPS(:,1), realGPS(:,4), realGPS(:,5), realGPS(:,6));    %DateNumber = datenum(Y,M,D,H,MN,S)
realLatitude = realGPS(:,7);
realLongitude = realGPS(:,8);
realAltitude = realGPS(:,9);
realSpeed = realGPS(:,10);

%% Importation des données du circuit à réaliser (Voir "traitementDonneesGPS.m")
load('ASC2016_stage1_plus_speed.mat')
stage1 = newParcours;
load('ASC2016_stage2_plus_speed.mat')
stage2 = newParcours;
load('ASC2016_stage3_plus_speed.mat')
stage3 = newParcours;
load('ASC2016_stage4_plus_speed.mat')
stage4 = newParcours;

asc.latitude = [stage1.latitude; stage2.latitude; stage3.latitude; stage4.latitude];
asc.longitude = [stage1.longitude; stage2.longitude; stage3.longitude; stage4.longitude];
asc.altitude = [stage1.altitude; stage2.altitude; stage3.altitude; stage4.altitude];
asc.slope = [stage1.slope; stage2.slope; stage3.slope; stage4.slope];
asc.distance = [stage1.distance; stage1.distance(end)+stage2.distance; stage1.distance(end)+stage2.distance(end)+stage3.distance; stage1.distance(end)+stage2.distance(end)+stage3.distance(end)+stage4.distance];


figure, hold on, grid on
title('ASC : 3160 km en 8 jours')
% plot(asc.distance, asc.altitude)
plot(stage1.distance, stage1.altitude, 'b')
plot(349, 10, 'sb')
plot(stage1.distance(end)+stage2.distance, stage2.altitude, 'r')
plot(stage1.distance(end)+296, 10, 'sr')
plot(stage1.distance(end)+stage2.distance(end)+stage3.distance, stage3.altitude, 'm')
plot(stage1.distance(end)+stage2.distance(end)+403, 10, 'sm')
plot(stage1.distance(end)+stage2.distance(end)+403+228, 10, 'sm')
plot(stage1.distance(end)+stage2.distance(end)+stage3.distance(end)+stage4.distance, stage4.altitude, 'g')
xlabel('Distance (km)')
ylabel('Altitude (m)')
axis([0 asc.distance(end) 0 max(asc.altitude)])


figure, hold on, grid on
title('Stage 1 : 727 km en 2 jours')
plot(stage1.distance, stage1.altitude)
xlabel('Distance (km)')
ylabel('Altitude (m)')
axis([0 stage1.distance(end) 0 max(stage1.altitude)])

figure, hold on, grid on
title('Stage 2 : 817 km en 2 jours')
plot(stage2.distance, stage2.altitude)
xlabel('Distance (km)')
ylabel('Altitude (m)')
axis([0 stage2.distance(end) 0 max(stage2.altitude)])

figure, hold on, grid on
title('Stage 3 : 1362 km en 3 jours')
plot(stage3.distance, stage3.altitude)
xlabel('Distance (km)')
ylabel('Altitude (m)')
axis([0 stage3.distance(end) 0 max(stage3.altitude)])

figure, hold on, grid on
title('Stage 1 : 252 km en 1 jour')
plot(stage4.distance, stage4.altitude)
xlabel('Distance (km)')
ylabel('Altitude (m)')
axis([0 stage4.distance(end) 0 max(stage4.altitude)])

figure, hold on, grid on
title('Carte 3D de la ASC')
plot3(asc.longitude, asc.latitude, asc.altitude)
plot3(realLongitude, realLatitude, realAltitude, 'r')
xlabel('longitude')
ylabel('latitude')
zlabel('altitude (m)')

figure, hold on, grid on
title('Carte 3D du stage 2')
plot3(stage2.longitude, stage2.latitude, stage2.altitude)

