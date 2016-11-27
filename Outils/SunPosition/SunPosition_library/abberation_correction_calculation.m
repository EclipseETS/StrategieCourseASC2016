function aberration_correction = abberation_correction_calculation(earth_heliocentric_position)
% This function compute the aberration_correction, as a function of the
% earth-sun distance. 

aberration_correction = -20.4898./(3600*earth_heliocentric_position.radius);
return