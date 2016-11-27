function apparent_stime_at_greenwich = apparent_stime_at_greenwich_calculation(julian, nutation, true_obliquity)
% This function compute the apparent sideral time at Greenwich. 

JD = julian.day;
JC = julian.century;

% Mean sideral time, in degrees
mean_stime = 280.46061837 + (360.98564736629*(JD-2451545)) + (0.000387933*JC.^2) - (JC.^3/38710000);

% Limit the range to [0-360];
mean_stime = set_to_range(mean_stime, 0, 360);

apparent_stime_at_greenwich = mean_stime + (nutation.longitude.*cos(true_obliquity * pi/180));
return