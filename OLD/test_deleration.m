%% test_deleration.m
% Scrpit permettant de valider les paramètres de la voiture en fonction de
% la décélération observée lors des essais chez PMG

clc, clear all, close all

load('TrackPMGInner10m.mat')

%% Ajustement du parcours pour tenir compte du point d'entrée d'Éclipse sur la piste
entry_point = 230; % Point correspondant à l'entrée sur la piste Bravo en face de la caserne de PMG
for subfield = fieldnames(newParcours)'
    subfield
    parcours.(subfield{1}) = [newParcours.(subfield{1})(230:end); newParcours.(subfield{1})(1:229)]; 
end

%% Select data file
dir_path = ('C:\Users\club\Git\log-PMG\log-PMG\log 2016-06-26\DonneesMatlabTraitees');
addpath(dir_path);
log_list = dir(dir_path);
filename = log_list(9).name

%% Load data from telemetry
data = xlsread(filename);
heure = data(:,1);
vitesse = data(:,2);
rpm = data(:,3);
VbusDC = data(:,4);
IbusDC = data(:,5);
Odometre = data(:,6);
Ah = data(:,7);
dt = diff(heure)./min(diff(heure));
t = [0; cumsum(dt)]; % En secondes

%% Display data
figure, hold on, grid on, title(filename)
plot(Odometre/1000, vitesse)
plot(Odometre/1000, IbusDC)
legend('Vitesse (kmh)', 'IbusDC')
xlabel('Distance (km)')

figure, hold on, grid on, title(filename)
plot(t, vitesse)
plot(t, IbusDC)
legend('Vitesse (kmh)', 'IbusDC')
xlabel('Temps (s)');

