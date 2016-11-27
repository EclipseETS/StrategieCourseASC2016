function sun_geocentric_position = sun_geocentric_position_calculation(earth_heliocentric_position)
% This function compute the sun position relative to the earth. 

sun_geocentric_position.longitude = earth_heliocentric_position.longitude + 180;
% Limit the range to [0,360];
sun_geocentric_position.longitude = set_to_range(sun_geocentric_position.longitude, 0, 360);

sun_geocentric_position.latitude = -earth_heliocentric_position.latitude;
% Limit the range to [0,360]
sun_geocentric_position.latitude = set_to_range(sun_geocentric_position.latitude, 0, 360);
return