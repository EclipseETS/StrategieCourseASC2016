%% Éclipse 9
%  analyseTelemetryFSPG.m
%  Permet de caractériser la voiture solaire Éclipse 9 à partir des
%  fichiers de log des essais réalisés à la FSPG 2016
%  
%
%  Auteur : Julien Longchamp
%  Date de création : 25-07-2016
%  Dernière modification :
%%
clc, clear all, close all

load('PittRaceNorthTrack10m.mat')
parcours = newParcours;

realGPS = csvread('R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\PittRaceNorthTrackREAL.csv');
realLatitude = realGPS(:,7);
realLongitude = realGPS(:,8);
realAltitude = realGPS(:,9);
realSlope = realGPS(:,10);

%% Choisir le dossier contenant le log
dir_path = ('C:\Users\Strategy\Documents\LogTelemetry\DonneesMatlabTraitees')

addpath(dir_path);
log_list = dir(dir_path);
filename = log_list(4).name

data = xlsread(filename);
heure = data(:,1);
vitesse = data(:,2);
rpm = data(:,3);
VbusDC = data(:,4);
IbusDC = data(:,5);
Odometre = data(:,6);
Ah = data(:,7);
dt = diff(heure)./min(diff(heure));
ts = [0; cumsum(dt)]; % En secondes
tm = ts/60; % En minutes
th = tm/60; % En heures

puissance = VbusDC.*IbusDC;


figure, grid on, hold on
plot3(parcours.latitude, parcours.longitude, parcours.altitude)
plot3(realLatitude, realLongitude, realAltitude, 'r')