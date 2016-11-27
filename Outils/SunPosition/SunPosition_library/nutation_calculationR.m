function nutation = nutation_calculationR(julian)
% This function compute the nutation in longtitude and in obliquity, in
% degrees. 

% All Xi are in degrees. 
JCE = julian.ephemeris_century;
ntimes=length(JCE);
% 1. Mean elongation of the moon from the sun 
p = [(1/189474) -0.0019142 445267.11148 297.85036];
% X0 = polyval(p, JCE);
X0 = p(1) * JCE.^3 + p(2) * JCE.^2 + p(3) * JCE + p(4); % This is faster than polyval...

% 2. Mean anomaly of the sun (earth)
p = [-(1/300000) -0.0001603 35999.05034 357.52772];
% X1 = polyval(p, JCE);
X1 = p(1) * JCE.^3 + p(2) * JCE.^2 + p(3) * JCE + p(4); 

% 3. Mean anomaly of the moon
p = [(1/56250) 0.0086972 477198.867398 134.96298];
% X2 = polyval(p, JCE);
X2 = p(1) * JCE.^3 + p(2) * JCE.^2 + p(3) * JCE + p(4); 

% 4. Moon argument of latitude
p = [(1/327270) -0.0036825 483202.017538 93.27191];
% X3 = polyval(p, JCE);
X3 = p(1) * JCE.^3 + p(2) * JCE.^2 + p(3) * JCE + p(4); 

% 5. Longitude of the ascending node of the moon's mean orbit on the
% ecliptic, measured from the mean equinox of the date
p = [(1/450000) 0.0020708 -1934.136261 125.04452];
% X4 = polyval(p, JCE);
X4 = p(1) * JCE.^3 + p(2) * JCE.^2 + p(3) * JCE + p(4); 

% Y tabulated terms from the original code
Y_terms =  [0 0 0 0 1  
 -2 0 0 2 2  
 0 0 0 2 2  
 0 0 0 0 2  
 0 1 0 0 0  
 0 0 1 0 0  
 -2 1 0 2 2  
 0 0 0 2 1  
 0 0 1 2 2  
 -2 -1 0 2 2  
 -2 0 1 0 0  
 -2 0 0 2 1  
 0 0 -1 2 2  
 2 0 0 0 0  
 0 0 1 0 1  
 2 0 -1 2 2  
 0 0 -1 0 1  
 0 0 1 2 1  
 -2 0 2 0 0  
 0 0 -2 2 1  
 2 0 0 2 2  
 0 0 2 2 2  
 0 0 2 0 0  
 -2 0 1 2 2  
 0 0 0 2 0  
 -2 0 0 2 0  
 0 0 -1 2 1  
 0 2 0 0 0  
 2 0 -1 0 1  
 -2 2 0 2 2  
 0 1 0 0 1  
 -2 0 1 0 1  
 0 -1 0 0 1  
 0 0 2 -2 0  
 2 0 -1 2 1  
 2 0 1 2 2  
 0 1 0 2 2  
 -2 1 1 0 0  
 0 -1 0 2 2  
 2 0 0 2 1  
 2 0 1 0 0  
 -2 0 2 2 2  
 -2 0 1 2 1  
 2 0 -2 0 1  
 2 0 0 0 1  
 0 -1 1 0 0  
 -2 -1 0 2 1  
 -2 0 0 0 1  
 0 0 2 2 1  
 -2 0 2 0 1  
 -2 1 0 2 1  
 0 0 1 -2 0  
 -1 0 1 0 0  
 -2 1 0 0 0  
 1 0 0 0 0  
 0 0 1 2 0  
 0 0 -2 2 2  
 -1 -1 1 0 0  
 0 1 1 0 0  
 0 -1 1 2 2  
 2 -1 -1 2 2  
 0 0 3 2 2  
 2 -1 0 2 2];

nutation_terms = [ -171996 -174.2 92025 8.9  
 -13187 -1.6 5736 -3.1  
 -2274 -0.2 977 -0.5  
 2062 0.2 -895 0.5  
 1426 -3.4 54 -0.1  
 712 0.1 -7 0  
 -517 1.2 224 -0.6  
 -386 -0.4 200 0  
 -301 0 129 -0.1  
 217 -0.5 -95 0.3  
 -158 0 0 0  
 129 0.1 -70 0  
 123 0 -53 0  
 63 0 0 0  
 63 0.1 -33 0  
 -59 0 26 0  
 -58 -0.1 32 0  
 -51 0 27 0  
 48 0 0 0  
 46 0 -24 0  
 -38 0 16 0  
 -31 0 13 0  
 29 0 0 0  
 29 0 -12 0  
 26 0 0 0  
 -22 0 0 0  
 21 0 -10 0  
 17 -0.1 0 0  
 16 0 -8 0  
 -16 0.1 7 0  
 -15 0 9 0  
 -13 0 7 0  
 -12 0 6 0  
 11 0 0 0  
 -10 0 5 0  
 -8 0 3 0  
 7 0 -3 0  
 -7 0 0 0  
 -7 0 3 0  
 -7 0 3 0  
 6 0 0 0  
 6 0 -3 0  
 6 0 -3 0  
 -6 0 3 0  
 -6 0 3 0  
 5 0 0 0  
 -5 0 3 0  
 -5 0 3 0  
 -5 0 3 0  
 4 0 0 0  
 4 0 0 0  
 4 0 0 0  
 -4 0 0 0  
 -4 0 0 0  
 -4 0 0 0  
 3 0 0 0  
 -3 0 0 0  
 -3 0 0 0  
 -3 0 0 0  
 -3 0 0 0  
 -3 0 0 0  
 -3 0 0 0  
 -3 0 0 0];

% Using the tabulated values, compute the delta_longitude and
% delta_obliquity. 
Xi = [X0
    X1
    X2
    X3
    X4];

tabulated_argument = (Y_terms * Xi) * pi/180;

delta_longitude = ((repmat(nutation_terms(:,1),[1,ntimes]) + ...
                    (nutation_terms(:,2) * JCE))).*sin(tabulated_argument);
delta_obliquity = ((repmat(nutation_terms(:,3),[1,ntimes])+ ...
                    (nutation_terms(:,4) * JCE))).* cos(tabulated_argument);

% Nutation in longitude
nutation.longitude = sum(delta_longitude) / 36000000;

% Nutation in obliquity
nutation.obliquity = sum(delta_obliquity) / 36000000;
return