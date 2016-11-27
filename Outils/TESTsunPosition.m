addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SunPosition\SunPosition_library');
addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SunPosition');

clear all; close all; clc

latitude = 45.6966; % PittRace
longitude = -73.8736; % PittRace
altitude = 360; % km

%SunAngleVariation


%Local Time to julian day starlongitudet
Y=2016; M=7; D=24; H=0; MI=0; S=0;
UT_offset =-2; %-longitude/15

Date_debut = datenum(2016, 07, 25, 0, 0, 0);
Date_fin = datenum(2016, 07, 26, 0, 0, 0);

h1 = datenum(2016, 07, 25, 8, 0, 0);
h2 = datenum(2016, 07, 25, 13, 0, 0);
[E1, Az1] = SunElevationInstant(h1,latitude,longitude,altitude);
[E2, Az2] = SunElevationInstant(h2,latitude,longitude,altitude);


heure = linspace(Date_debut,Date_fin, 24);
for k = 1:length(heure)
%     datestr(heure(k))
    [Elevation(k), Azimuth(k)] = SunElevationInstant(heure(k),latitude,longitude,altitude);
%     jday = julian_calculation(datevec(heure(k)));
    
%     loc_llh(1)= latitude; %37.45;
%     loc_llh(2)= longitude; %-122.17;
%     loc_llh(3)= altitude;
%     loc_llh=loc_llh(:);
%     
%     jday = julian(datevec(heure(k)), UT_offset);
%     
%     sun = sun_positionR(jday, loc_llh);
%     z2(k) = 90-sun.zenith;
end

figure, hold on, grid on
plot(mod(heure, 1)*24+UT_offset, Elevation, '.')
% plot(mod(heure, 1)*24+UT_offset, z2, '.r')
plot(mod(h1, 1)*24 + UT_offset, E1, 'o')
plot(mod(h2, 1)*24 + UT_offset, E2, 'or')
grid on
axis([0,25, 0 90])
ylabel('Elevation-deg')
% subplot(2,1,2)
% plot(mod(heure, 1)*24, sind(Elevation)*1000 * 6 * .22)
% axis([0,25, 0 2000])

% SunElevationInstant
