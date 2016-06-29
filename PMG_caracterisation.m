%% Éclipse 9
%  PMG_caracterisation.m
%  Permet de caractériser la voiture solaire Éclipse 9 à partir des
%  fichiers de log des essais réalisés chez PMG
%  
%
%  Auteur : Julien Longchamp
%  Date de création : 18-06-2016
%  Dernière modification :
%%
%clc, clear all, close all
%addpath('C:\Users\club\Git\log-PMG\log-PMG\log 2016-06-19\DonneesMatlabTraitees')
%filename = 'MathLab_2016_06_18_01_10_24 premiers tours-julien B.xlsx';
%filename = 'MathLab_2016_06_18_01_38_14 lap 50 kmh - julien B.xlsx';
%filename = 'MathLab_2016_06_18_02_52_04 premier tour max power-Remi.xlsx';
%filename = ['MathLab_2016_06_18_12_41_22 tour - JF' '.xlsx'];

load('TrackPMGInner.mat')
parcours = newParcours;

dir_path = ('C:\Users\club\Git\log-PMG\log-PMG\log 2016-06-19\DonneesMatlabTraitees');
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

mv_air = 1000*102.1/(287.058*(273.15+30.9));
aire_frontale = 1.25;

vitesse_vent = ones(size(vitesse)).*20.38; % km/h0
direction = 252.29; % angle en degrés

directionSud = 60;
directionNord = 240;

v_vehicule_x = [vitesse(1:599).*cosd(60); vitesse(600:end).*cosd(240)];
v_vehicule_y = [vitesse(1:599).*sind(60); vitesse(600:end).*sind(240)];

v_vent_x = vitesse_vent.*cosd(252.27);
v_vent_y = vitesse_vent.*sind(252.27);

v_relatif_x = v_vehicule_x+v_vent_x;
v_relatif_y = v_vehicule_y+v_vent_y;

v_relatif = sqrt(v_relatif_x.^2 + v_relatif_y.^2);

v_relatifA = 50/3.6; % m/s
v_relatifB = 60/3.6; % m/s

rendement = .90; % Rendement de la chaîne de traction
powerA = 2200/rendement; % W
powerB = 3200/rendement; % W

forceA = powerA/v_relatifA; % N
forceB = rendement*powerB/v_relatifB; % N

Cx = (forceA - forceB) / (.5*mv_air*aire_frontale*v_relatifA^2-0.5*mv_air*aire_frontale*v_relatifB^2)
frottement = forceA - 0.5*mv_air*aire_frontale*Cx*v_relatifA^2
frottement2 = forceB - 0.5*mv_air*aire_frontale*Cx*v_relatifB^2
forceA2 = 0.5*mv_air*aire_frontale*Cx*v_relatifA^2 + frottement

dt = diff(heure)./min(diff(heure));
t = [0; cumsum(dt)]; % En secondes

figure, hold on, title('Aperçu de l''essai')
plot(t,VbusDC)
plot(t, IbusDC, 'r')
plot(t, vitesse, 'g-')
plot(t, v_relatif, 'm-')
legend('VbusDC', 'IbusDC', 'Vitesse (km/h)')

figure, hold on
plot(Odometre/1000, vitesse)
plot(Odometre/1000, IbusDC)


%% Ajoute les nouvelles donnes sur le circuit de PMG
dist = zeros(size(Odometre));
lat = zeros(size(Odometre));
lon = zeros(size(Odometre));
cutPoint = 0;
for k = 1:length(Odometre)
    if(Odometre(k)/1000 > parcours.distance(end) && cutPoint == 0)
        cutPoint = k;
    end
    odo = mod(Odometre(k)/1000, parcours.distance(end));
    dummy = abs(parcours.distance - odo);
    [val idx] = min(dummy); %index of closest value
    dist(k) = parcours.distance(idx); 
    lat(k) = parcours.latitude(idx);
    lon(k) = parcours.longitude(idx);
end

figure, hold on, title('Les deux tours d''Hadi')
plot3(lat(1:cutPoint), lon(1:cutPoint), vitesse(1:cutPoint), 'b')
plot3(lat(cutPoint:end), lon(cutPoint:end), vitesse(cutPoint:end), 'r')
plot3(lat(1:cutPoint), lon(1:cutPoint), IbusDC(1:cutPoint), '*m')
plot3(lat(cutPoint:end), lon(cutPoint:end), IbusDC(cutPoint:end), 'sk')
xlabel('longitude')
ylabel('latitude')
quiver3(mean(lat), mean(lon), 55, v_vent_x(1)/5000, v_vent_y(1)/5000,0, 0)
legend('Vitesse tour 1', 'Vitesse tour 2', 'Courant tour 1', 'Courant tour 2', 'Vent', 'location', 'SouthEast')

figure, hold on, title('Puissance'), grid on
plot3(lat(1:cutPoint), lon(1:cutPoint), VbusDC(1:cutPoint).*IbusDC(1:cutPoint), 'or')
%plot3(lat(cutPoint:end), lon(cutPoint:end),  VbusDC(cutPoint:end).*IbusDC(cutPoint:end), 'sk')
%plot3(lat, lon, VbusDC.*IbusDC, 'r')

load('dataTour50kmh.mat', 'A', 'B', 'C')
plot3(A,B,C, '-')
legend('Données expérimentales', 'Résulats de simulation')