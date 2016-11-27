function sun = sun_positionR(jday,loc_llh)
% sun = sun_position(time, loc_llh, UToffset)
%
% This function compute the sun position (zenith and azimuth angle at the observer
% location) as a function of julian day and position. 
%
% It is an implementation of the algorithm presented by Reda et Andreas in:
%   Reda, I., Andreas, A. (2003) Solar position algorithm for solar
%   radiation application. National Renewable Energy Laboratory (NREL)
%   Technical report NREL/TP-560-34302. 
% This document is avalaible at www.osti.gov/bridge
%
% This algorithm is based on numerical approximation of the exact equations.
% The authors of the original paper state that this algorithm should be
% precise at +/- 0.0003 degrees. I have compared it to NOAA solar table
% (http://www.srrb.noaa.gov/highlights/sunrise/azel.html) and to USNO solar
% table (http://aa.usno.navy.mil/data/docs/AltAz.html) and found very good
% correspondance (up to the precision of those tables), except for large
% zenith angle, where the refraction by the atmosphere is significant 
% (difference of about 1 degree). Note that in this code the correction 
% for refraction in the atmosphere as been implemented for a temperature 
% of 10C (283 kelvins) and a pressure of 1010 mbar. See the subfunction 
% «sun_topocentric_zenith_angle_calculation» for a possible modification 
% to explicitely model the effect of temperature and pressure as describe
% in Reda & Andreas (2003). 
%
% Input parameters:
%   jday= julian day at loc_llh  Nx1 vector
%   
%   loc_llh: a  3xN vector containing 
%       latitude:   latitude (in degrees, north of equator positive)
%       longitude: longitude (in degrees, positive east of Greenwich)
%       altitude:   altitude above mean sea level (in meters) 
%                   wgs ellipsoid<=sea level
% 
% Output parameters
%   sun: a structure with the calculated sun position
%       sun.zenith  = zenith angle in degrees (angle from the vertical)
%       sun.azimuth = azimuth angle in degrees, eastward from the north. 
% Only the sun zenith and azimuth angles are returned as output, but a lot
% of other parameters are calculated that could also extracted as output of
% this function. 
%
% History 
%
%   09/03/2004  Original creation by Vincent Roy (vincent.roy@drdc-rddc.gc.ca)
%   10/03/2004  Fixed a bug in julian_calculation subfunction (was
%               incorrect for year 1582 only), Vincent Roy
%   18/03/2004  Correction to the header (help display) only. No changes to
%               the code. (changed the «elevation» field in «location» structure
%               information to «altitude»), Vincent Roy
%   13/04/2004  Following a suggestion from Jody Klymak (jklymak@ucsd.edu),
%               allowed the 'time' input to be passed as a Matlab time string. 
%   22/08/2005  Following a bug report from Bruce Bowler
%               (bbowler@bigelow.org), modified the julian_calculation function. Bug
%               was 'MATLAB has allowed structure assignment  to a non-empty non-structure 
%               to overwrite the previous value.  This behavior will continue in this release, 
%               but will be an error in a  future version of MATLAB.  For advice on how to 
%               write code that  will both avoid this warning and work in future versions of 
%               MATLAB,  see R14SP2 Release Notes'. Script should now be
%               compliant with futher release of Matlab...
%   12/01/2012  Revised by Charles L. Rino for vector julian day and location
%   inputs

% 1. Generate Julian day, Julian Century, Julian Ephemeris day, century
% and millenium calculated using a mean delta_t of 33.184 seconds. 
% NOTE: Current verision uses delta_t=0;
julian = julian_calculationR(jday);

% 2. Calculate the Earth heliocentric longitude, latitude, and radius
% vector (L, B, and R)
earth_heliocentric_position = earth_heliocentric_position_calculationR(julian);

% 3. Calculate the geocentric longitude and latitude
sun_geocentric_position = sun_geocentric_position_calculation(earth_heliocentric_position);

% 4. Calculate the nutation in longitude and obliquity (in degrees). 
nutation = nutation_calculationR(julian);

% 5. Calculate the true obliquity of the ecliptic (in degrees). 
true_obliquity = true_obliquity_calculation(julian, nutation);

% 6. Calculate the aberration correction (in degrees)
aberration_correction = abberation_correction_calculation(earth_heliocentric_position);

% 7. Calculate the apparent sun longitude in degrees)
apparent_sun_longitude = apparent_sun_longitude_calculation(sun_geocentric_position, nutation, aberration_correction);

% 8. Calculate the apparent sideral time at Greenwich (in degrees)
apparent_stime_at_greenwich = apparent_stime_at_greenwich_calculation(julian, nutation, true_obliquity);

% 9. Calculate the sun rigth ascension (in degrees)
sun_rigth_ascension = sun_rigth_ascension_calculation(apparent_sun_longitude, true_obliquity, sun_geocentric_position);

% 10. Calculate the geocentric sun declination (in degrees). Positive or
% negative if the sun is north or south of the celestial equator. 
sun_geocentric_declination = sun_geocentric_declination_calculation(apparent_sun_longitude, true_obliquity, sun_geocentric_position);

% 11. Calculate the observer local hour angle (in degrees, westward from south).
observer_local_hour = observer_local_hour_calculationR(apparent_stime_at_greenwich, loc_llh, sun_rigth_ascension);

% 12. Calculate the topocentric sun position (rigth ascension, declination and
% rigth ascension parallax in degrees)
topocentric_sun_position = topocentric_sun_position_calculateR(earth_heliocentric_position, loc_llh, observer_local_hour, sun_rigth_ascension, sun_geocentric_declination);

% 13. Calculate the topocentric local hour angle (in degrees)
topocentric_local_hour = topocentric_local_hour_calculate(observer_local_hour, topocentric_sun_position);

% 14. Calculate the topocentric zenith and azimuth angle (in degrees)
sun = sun_topocentric_zenith_angle_calculateR(loc_llh, topocentric_sun_position, topocentric_local_hour);

