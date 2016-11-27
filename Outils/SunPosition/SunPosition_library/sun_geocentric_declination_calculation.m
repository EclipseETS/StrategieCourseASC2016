function sun_geocentric_declination = sun_geocentric_declination_calculation(apparent_sun_longitude, true_obliquity, sun_geocentric_position)

argument = (sin(sun_geocentric_position.latitude * pi/180).*cos(true_obliquity * pi/180)) + ...
            (cos(sun_geocentric_position.latitude * pi/180).*sin(true_obliquity * pi/180).*...
             sin(apparent_sun_longitude * pi/180));

sun_geocentric_declination = asin(argument) * 180/pi;
return