function julian_struct = julian_calculationR(jday);
julian_struct.day = jday;
delta_t = 0; % 33.184;
julian_struct.ephemeris_day = jday + (delta_t/86400);

julian_struct.century = (jday - 2451545) / 36525; 

julian_struct.ephemeris_century = (julian_struct.ephemeris_day - 2451545) / 36525;

julian_struct.ephemeris_millenium = julian_struct.ephemeris_century / 10; 
return