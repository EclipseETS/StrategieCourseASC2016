addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SunPosition\SunPosition_library');

%Day-Night Terminator
%Center Location
loc_llh(1)=37.45;  
loc_llh(2)=-122.17;
loc_llh(3)=0;

%Start Time 
Y=2014; M=8; D=0; H=20; MI=0; S=0;
jd_start=julian([Y,M,D,H,MI,S]);

%Longitude-Longitude grid
lat_min=loc_llh(1)-60; lat_max=loc_llh(1)+60; nlat=50;
lon_min=loc_llh(2)-60; lon_max=loc_llh(2)+60; nlon=100;
latitude =linspace(lat_min,lat_max,nlat);
longitude=linspace(lon_min,lon_max,nlon);
[LAT,LON]=meshgrid(latitude,longitude);  %n1=nlon, n2=nlat

loc_llh=zeros(3,nlat*nlon);
loc_llh(1,:)=LAT(:);
loc_llh(2,:)=LON(:);

jdays=jd_start;
sun= sun_positionR(jdays,loc_llh);
zenith =reshape(sun.zenith,nlon,nlat);
azimuth=reshape(sun.azimuth,nlon,nlat);

figure
imagesc(longitude,latitude,90-zenith')
axis xy
xlabel('Longitude')
ylabel('Latutude')
%caxis([0,90])
colorbar
title('Solar Elevation West Coast Winter')