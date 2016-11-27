function topocentric_sun_position = topocentric_sun_position_calculate(earth_heliocentric_position, loc_llh, observer_local_hour, sun_rigth_ascension, sun_geocentric_declination)
% This function compute the sun position (rigth ascension and declination)
% with respect to the observer local position at the Earth surface. 

% Equatorial horizontal parallax of the sun in degrees
eq_horizontal_parallax = 8.794./(3600 * earth_heliocentric_position.radius);

% Term u, used in the following calculations (in radians)
u = atan(0.99664719 * tan(loc_llh(1)* pi/180));

% Term x, used in the following calculations
x = cos(u) + ((loc_llh(3)/6378140).*cos(loc_llh(1) * pi/180));

% Term y, used in the following calculations
y = (0.99664719 * sin(u)) + ((loc_llh(3)/6378140).*sin(loc_llh(1) * pi/180));

% Parallax in the sun rigth ascension (in radians)
nominator = -x * sin(eq_horizontal_parallax * pi/180).*sin(observer_local_hour * pi/180);
denominator = cos(sun_geocentric_declination * pi/180) - (x * sin(eq_horizontal_parallax * pi/180).*cos(observer_local_hour * pi/180));
sun_rigth_ascension_parallax = atan2(nominator, denominator);
% Conversion to degrees. 
topocentric_sun_position.rigth_ascension_parallax = sun_rigth_ascension_parallax * 180/pi;

% Topocentric sun rigth ascension (in degrees)
topocentric_sun_position.rigth_ascension = sun_rigth_ascension + (sun_rigth_ascension_parallax * 180/pi);

% Topocentric sun declination (in degrees)
nominator = (sin(sun_geocentric_declination * pi/180) - (y*sin(eq_horizontal_parallax * pi/180))).* cos(sun_rigth_ascension_parallax);
denominator = cos(sun_geocentric_declination * pi/180) - (x*sin(eq_horizontal_parallax * pi/180)).* cos(observer_local_hour * pi/180);
topocentric_sun_position.declination = atan2(nominator, denominator) * 180/pi;
return