%% Éclipse 9
%  sunCycleFSGP2016.m
%  Ce script permet d'obtenir les informations concernant le cycle du soleil durant la FSGP 2016
%  Les données brutes ont été obtenues sur le site "http://www.sunearthtools.com/dp/tools/pos_sun.php"
%  Elles ont été transcrites manuellement dans un fichier excel qui est lu par ce script.
%  La trajectoire du soleil ainsi créée est ensuite approximée par un polynôme d'ordre 2 afin d'être réutilisé par le fichier solarArrayModel.m
%  
%
%  Auteur : Julien Longchamp
%  Date de création : 25-07-2016
%  Dernière modification :
%%

%% Import the data
[~, ~, raw] = xlsread('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\DonnesSoleil\SoleilFSPG2016.xlsx','Sheet1','A2:M5');

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
Year = data(:,1);
Month = data(:,2);
Day = data(:,3);
SunriseHH = data(:,4);
SunriseMM = data(:,5);
SunriseSS = data(:,6);
SunsetHH = data(:,7);
SunsetMM = data(:,8);
SunsetSS = data(:,9);
ZenithHH = data(:,10);
ZenithMM = data(:,11);
ZenithSS = data(:,12);
Zenithangle = data(:,13);

%% Clear temporary variables
clearvars data raw;

date_sunrise = mean(mod((datenum(Year, Month, Day, SunriseHH, SunriseMM, SunriseSS)),1));
date_sunset = mean(mod((datenum(Year, Month, Day, SunsetHH, SunsetMM, SunsetSS)),1));
date_zenith = mean(mod((datenum(Year, Month, Day, ZenithHH, ZenithMM, ZenithSS)),1));

datestr(date_sunrise)
datestr(date_zenith)
datestr(date_sunset)


date = [date_sunrise; date_sunset; date_zenith];
angle = [0; 0; mean(Zenithangle)];

sun_coef = polyfit(mod(date,1), angle, 2);

t = linspace(0,1,100);

figure, grid on, hold on
plot(mod(date,1)*24, angle, '*')
plot(t*24, polyval(coef, t))

save('SoleilFSGPcoef.mat', 'sun_coef');




