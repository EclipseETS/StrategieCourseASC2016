function [ Elevation Azimuth] = SunElevationInstant(Time,Lat,Lon,Alt)
%% Éclipse 9
%  La fonction SunElevationInstant.m  permet d'obtenir l'angle d'élévation du soleil pour une position GPS et un temps précis
%
%  Cette fonction utilise les travaux de Charles Rino qui étaient eux-même basés sur la fonction sun_position.m de Vincent Roy.
%  Le code présenté permet d'interfacer ces travaux avec le modèle de la voiture solaire Éclipse 9, il est grandement inspiré du script SunAngleLocalVariation disponible sur MATLAB Central
%
%  Inputs :
%    Time : time in datenum format (see help datenum)
%    Lat : GPS latitude in decimal
%    Lon : GPS longitude in decimal
%    Alt : Altitude in meters
%
%  Output :
%    Elevation : Sun's elevation in degrees
%
%
%  Auteur : Julien Longchamp
%  Date de création : 24-07-2016
%  Dernière modification :
%%

addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SunPosition\SunPosition_library');

if nargin == 0
    %     latitude = 45.6966; % PittRace
    %     longitude = -73.8736; % PittRace
    %     altitude = 360; % m
    loc_llh(1)=  45.6966; %37.45;
    loc_llh(2)= -73.8736; %-122.17;
    loc_llh(3)= 360;
    loc_llh=loc_llh(:);
    
    %Local Time to julian day start
    Y=2016; M=7; D=24; H=0; MI=0; S=0;
    
else
    %SunAngleVariation
    [Y,M,D,H,MI,S] = datevec(Time);
    
    %Location
    loc_llh(1)= Lat; %37.45;
    loc_llh(2)= Lon; %-122.17;
    loc_llh(3)= Alt;
    loc_llh=loc_llh(:);
end


UT_offset = -10; %-longitude/15 ***** TODO : Vérifier la valeur

if nargin == 0
    figure
    heure = linspace(0,24, 24);
    date = datestr([Y,M,D,H,MI,S])
    jday0=julian([Y,M,D,H,MI,S],UT_offset);
    minutes_day=24*60;
    jday=jday0+(0:minutes_day-60)/minutes_day-0.3;
    sun=sun_positionR(jday,loc_llh);
    
    
    sun2=sun_positionR(jday0+7/24,loc_llh);
    
    zenith=sun.zenith;
    azimuth=sun.azimuth;
    
    subplot(2,1,1)
    hold on
    plot((jday-jday0)*24,90-zenith)
    plot(8, sun2.zenith, 'o')
    grid on
    axis([0,25, 0 90])
    ylabel('Elevation-deg')
    title('Local Solar Angle (NORCAL)')
    subplot(2,1,2)
    hold on
    plot((jday-jday0)*24,azimuth)
    grid on
    ylabel('Azimuth-deg')
    xlabel('Local Time-hrs')
    subplot(2,1,1)
    legend('Winter','Summer')
else
    %     date = datestr([Y,M,D,H,MI,S])
    %     jday0=julian([Y,M,D,H,MI,S],UT_offset);
    %     sun=sun_positionR(jday0,loc_llh);
    
    jday = julian(datevec(Time), -2);    % UT_offset = -2
    sun = sun_positionR(jday, loc_llh);
end
Elevation = 90-sun.zenith;
Azimuth = sun.azimuth;
end

