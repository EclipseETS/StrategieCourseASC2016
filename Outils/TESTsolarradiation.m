clc, close all, clear all

addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\solarradiation');

dem = zeros(2);
lat = [41 41];
cs = 1;
r = 0.2;

[srad rad] = solarradiation(dem,lat,cs,r);

date = datenum(2016,07,12,23,0,0);
[radiance, sunrise, sunset] = solarradiationInstant(zeros(2),lat,1,0.2,date); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m  
radiance
figure, hold on, grid on

le_18_juillet = 199;
le_2_aout = 214;
le_6_aout = 218;

t = 2.5+(1:length(rad(1,:)));
for k = le_18_juillet:le_2_aout
    plot(t, rad(k,:))
end

x = 0:0.1:24;
irrandiance_coef = polyfit(t, rad(le_18_juillet,:), 5)
%pf(3) = pf(3) + 65;
y = polyval(irrandiance_coef, x);

plot(t, rad(le_18_juillet,:), 'x')
plot(x,y, '--')
xlabel('Heure du jour (24h)')
ylabel('Irradiance (W/m^2)');
title('�volution de l''ensoleillement au cours de la journ�e')

% for k = 1:length(rad(:,1))
%     plot(rad(k,:))
% end

save('SolarIrradianceLat41N.mat', 'irrandiance_coef');