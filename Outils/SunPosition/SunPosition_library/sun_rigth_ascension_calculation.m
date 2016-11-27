function sun_rigth_ascension = sun_rigth_ascension_calculation(apparent_sun_longitude, true_obliquity, sun_geocentric_position)
% This function compute the sun rigth ascension. 

argument_numerator = (sin(apparent_sun_longitude * pi/180).*cos(true_obliquity * pi/180)) - ...
    (tan(sun_geocentric_position.latitude * pi/180).* sin(true_obliquity * pi/180));
argument_denominator = cos(apparent_sun_longitude * pi/180);

sun_rigth_ascension = atan2(argument_numerator, argument_denominator) * 180/pi;
% Limit the range to [0,360];
sun_rigth_ascension = set_to_range(sun_rigth_ascension, 0, 360);
return