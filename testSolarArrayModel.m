% testSolarArrayModel.m
clc, clear all, close all

addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils');
load('SolarIrradianceLat41N.mat', 'irrandiance_coef');


%% Coordonnées approx. de l'ÉTS
latitude = 45.495122;
longitude = -73.553607;
altitude = 10; % mètres
pente = 0;

heure_ini = datenum([2016,07,05,0,0,0]);
densite_de_puissance_incidente = 800;

t = linspace(0,1, 24*5);
puissancePV = zeros(size(t));

date = datenum([2016,07,05]);
[rs,time,d,z,a,r] = suncycle(latitude/360,longitude/360,date,12.5)

for k=1:length(t)
    heure = heure_ini+t(k);
    densite_de_puissance_incidente = polyval(irrandiance_coef, mod(heure,1)*24);
    puissancePV(k) = solarArrayModel(latitude, longitude, altitude, pente, heure, densite_de_puissance_incidente);
    [Az(k) El(k)] = SolarAzEl(heure,latitude,longitude,altitude);
end

figure, grid on
plot(t, puissancePV)

% figure, grid on
% plot(t, El)