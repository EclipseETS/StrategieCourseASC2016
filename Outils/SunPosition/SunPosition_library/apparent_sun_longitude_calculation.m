function apparent_sun_longitude = apparent_sun_longitude_calculation(sun_geocentric_position, nutation, aberration_correction)
% This function compute the sun apparent longitude

apparent_sun_longitude = sun_geocentric_position.longitude + nutation.longitude + aberration_correction;
return