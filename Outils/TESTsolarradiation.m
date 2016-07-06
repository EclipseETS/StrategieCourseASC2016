clc, close all, clear all

addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\solarradiation');

dem = ones(2);
lat = [45.495122 45.495120];
cs = 1;
r = 0.2;

[srad rad] = solarradiation(dem,lat,cs,r);

figure, hold on, grid on
for k = 1:length(rad(1,:))
    plot(rad(:,k))
end