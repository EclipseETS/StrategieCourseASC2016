% % test.m
% clc, clear all, close all
% 
% load('ASC2016_stage2_plus_speed.mat')
% parcours = newParcours;
% 
% az = zeros(size(parcours.latitude));
% azi = zeros(size(parcours.latitude));
% arc = zeros(size(parcours.latitude));
% 
% for k = 2:length(parcours.latitude)
%     az(k) = azimuth(parcours.latitude(k), parcours.longitude(k), parcours.latitude(k-1), parcours.longitude(k-1));
% %     [arc(k), azi(k)] = distance(parcours.latitude(k), parcours.longitude(k), parcours.latitude(k-1), parcours.longitude(k-1));
% end
% 
% plot(parcours.latitude, parcours.longitude)
% 
% max(azi)
% figure, quiver(parcours.latitude, parcours.longitude, arc, azi)
% 
% lat = diff(parcours.latitude);
% lon = diff(parcours.longitude);
% figure, plot(lat, lon, '.')
% 
% figure, plot(az, '*')
% hold on, plot(azi, 'o')
% 
clc, clear all, close all


latitude = 45.6966; % PittRace
longitude = -73.8736; % PittRace
altitude = 0/1000; % km
pente = 0; % Degrés
heure_debut = datenum([2016,07,24,0,0,0]);
heure_fin = datenum([2016,07,25,0,0,0]);
journee = linspace(heure_debut, heure_fin, 24);
sansSupport = 0;
avecSupport = 1;

for k = 1:length(journee)
       densite_de_puissance_incidente(k) = solarradiationInstant(zeros(2), ones(1,2)*latitude,1,0.2,journee(k)); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
       puissancePVsansSupport(k) = solarArrayModel(latitude, longitude, altitude, 0, journee(k), densite_de_puissance_incidente(k), sansSupport);
       puissancePVavecSupport(k) = solarArrayModel(latitude, longitude, altitude, 0, journee(k), densite_de_puissance_incidente(k), avecSupport);
       [Az(k) El(k)] = SolarAzEl(journee(k),latitude,longitude,altitude);
end


figure, hold on, grid on, title('Radiation solaire')
plot(mod(journee,1)*24, densite_de_puissance_incidente, '--')
plot(mod(journee,1)*24, puissancePVsansSupport, 'r')
plot(mod(journee,1)*24, puissancePVavecSupport, 'g')
plot(mod(journee,1)*24, El*10, '*')
xlabel('Heure')
ylabel('Puissance Watts')
legend('Puissance incidente (W/m^2)', 'Puissance sans support (W)', 'Puissance avec support (W)')

figure, hold on, grid on, title('Radiation solaire')
plot(El, densite_de_puissance_incidente)
xlabel('Angle (degrés)')
ylabel('Puissance Watts')

%% Test de recharge 
% 23 juillet 2016 - PittRace - 19h54
% Angle d'inclinaison du paneau = (35' - 24.5')  48'
theta = atand((35-24.5)/48)


    