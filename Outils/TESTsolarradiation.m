clc, close all, clear all

addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\solarradiation');
addpath('solarradiation')

dem = zeros(2);
lat = [40 40];
cs = 1;
r = 0.2;

[srad rad] = solarradiation(dem,lat,cs,r);

date = datenum(2016,07,12,0,0,0);
[radiance, sunrise, sunset] = solarradiationInstant(zeros(2),lat,1,0.2,date); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m  
radiance

ete = datenum(2016,06,21,0,0,0);
automne = datenum(2016,09,22,0,0,0);
hiver = datenum(2016,12,21,0,0,0);
printemps = datenum(2016,03,21,0,0,0);
for k =1:24
    [radianceEte(k), sunriseE(k), sunsetE(k)] = solarradiationInstant(zeros(2),lat,1,0.2,ete+k/24); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m  
    [radianceAutomne(k), sunriseA(k), sunsetA(k)] = solarradiationInstant(zeros(2),lat,1,0.2,automne+k/24); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
    [radianceHiver(k), sunriseH(k), sunsetH(k)] = solarradiationInstant(zeros(2),lat,1,0.2,hiver+k/24); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
    [radiancePrintemps(k), sunriseP(k), sunsetP(k)] = solarradiationInstant(zeros(2),lat,1,0.2,printemps+k/24); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
end

le_18_juillet = 199;
le_2_aout = 214;
le_6_aout = 218;

le_21_mars = 80;        % Équinoxe de printemps
le_21_juin = 172;       % Solstice d'été
le_22_septembre = 265;  % Équinoxe d'automne
le_21_decembre = 355;   % Solstive d'hiver


% t = 2.5+(1:length(rad(1,:)));
t = (1:length(rad(1,:)));
figure, hold on, grid on
for k = le_18_juillet:le_2_aout
    plot(t, rad(k,:))
end

x = 0:0.1:24;
irrandiance_coef = polyfit(t, rad(le_18_juillet,:), 5)
%pf(3) = pf(3) + 65;
y = polyval(irrandiance_coef, x);

plot(t, rad(le_18_juillet,:), 'x')
% plot(x,y, '--')
xlabel('Heure du jour (24h)')
ylabel('Irradiance (W/m^2)');
title('Évolution de l''ensoleillement au cours de la journée')
title('Évolution de l''ensoleillement le 18 juillet')
% for k = 1:length(rad(:,1))
%     plot(rad(k,:))
% end

figure, hold on, title('Évolution de l''ensoleillement au 41e parallèle nord')
xlabel('Heure du jour (24h)')
ylabel('Irradiance (W/m^2)');
plot(t, rad(le_21_mars, :), '-o')
plot(t, rad(le_21_juin, :), '-^')
plot(t, rad(le_22_septembre, :), '-x')
plot(t, rad(le_21_decembre, :), '-v')
legend('Équinoxe de printemps', 'Solstice d''été', 'Équinoxe d''automne', 'Solstice d''hiver')

figure, hold on, title('Évolution de l''ensoleillement au 41e parallèle nord')
xlabel('Heure du jour (24h)')
ylabel('Irradiance (W/m^2)');
plot(1:24, radiancePrintemps, '-o')
plot(1:24, radianceEte, '-^')
plot(1:24, radianceAutomne, '-x')
plot(1:24, radianceHiver, '-v')
legend('Équinoxe de printemps', 'Solstice d''été', 'Équinoxe d''automne', 'Solstice d''hiver')
set(gca,'XMinorTick','on') % Display minor tick
% save('SolarIrradianceLat41N.mat', 'irrandiance_coef');

fprintf('Équinoxe de printemps : %3.2f kWh\n', sum(rad(le_21_mars, :))/1000)
fprintf('Solstice d''été : %3.2f kWh\n', sum(rad(le_21_juin, :))/1000)
fprintf('Équinoxe d''automne : %3.2f kWh\n', sum(rad(le_22_septembre, :))/1000)
fprintf('Solstice d''hiver : %3.2f kWh\n', sum(rad(le_21_decembre, :))/1000)

