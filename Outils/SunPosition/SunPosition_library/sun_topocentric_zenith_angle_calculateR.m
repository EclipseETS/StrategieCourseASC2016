function sun = sun_topocentric_zenith_angle_calculateR(loc_llh, topocentric_sun_position, topocentric_local_hour)
% This function compute the sun zenith angle, taking into account the
% atmospheric refraction. A default temperature of 283K and a
% default pressure of 1010 mbar are used. 

% Topocentric elevation, without atmospheric refraction
argument = (sin(loc_llh(1)* pi/180).*sin(topocentric_sun_position.declination * pi/180)) + ...
    (cos(loc_llh(1)* pi/180).*cos(topocentric_sun_position.declination * pi/180).*cos(topocentric_local_hour * pi/180));
true_elevation = asin(argument) * 180/pi;

% Atmospheric refraction correction (in degrees)
argument = true_elevation + (10.3./(true_elevation + 5.11));
refraction_corr = 1.02./(60 * tan(argument * pi/180));

% For exact pressure and temperature correction, use this, 
% with P the pressure in mbar amd T the temperature in Kelvins:
% refraction_corr = (P/1010) * (283/T) * 1.02 / (60 * tan(argument * pi/180));

% Apparent elevation
if(true_elevation > -5)
    apparent_elevation = true_elevation + refraction_corr;
else
    apparent_elevation = true_elevation;
end

sun.zenith = 90 - apparent_elevation;

% Topocentric azimuth angle. The +180 conversion is to pass from astronomer
% notation (westward from south) to navigation notation (eastward from
% north);
nominator = sin(topocentric_local_hour * pi/180);
denominator = (cos(topocentric_local_hour * pi/180).*sin(loc_llh(1,:)* pi/180)) - ...
    (tan(topocentric_sun_position.declination * pi/180).*cos(loc_llh(1,:) * pi/180));
sun.azimuth = (atan2(nominator, denominator) * 180/pi) + 180;
% Set the range to [0-360]
sun.azimuth = set_to_range(sun.azimuth, 0, 360);
return