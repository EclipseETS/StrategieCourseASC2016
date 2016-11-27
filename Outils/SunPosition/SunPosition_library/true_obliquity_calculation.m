function true_obliquity = true_obliquity_calculation(julian, nutation)
% This function compute the true obliquity of the ecliptic. 


p = [2.45 5.79 27.87 7.12 -39.05 -249.67 -51.38 1999.25 -1.55 -4680.93 84381.448];
% mean_obliquity = polyval(p, julian.ephemeris_millenium/10);

U = julian.ephemeris_millenium/10;
mean_obliquity = p(1)*U.^10 + p(2)*U.^9 + p(3)*U.^8 + p(4)*U.^7 +...
   p(5)*U.^6 + p(6)*U.^5 + p(7)*U.^4 + p(8)*U.^3 + p(9)*U.^2 + p(10)*U + p(11);


true_obliquity = (mean_obliquity/3600) + nutation.obliquity;
return