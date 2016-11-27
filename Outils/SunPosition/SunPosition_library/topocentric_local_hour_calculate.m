function topocentric_local_hour = topocentric_local_hour_calculate(observer_local_hour, topocentric_sun_position)
% This function compute the topocentric local jour angle in degrees

topocentric_local_hour = observer_local_hour - topocentric_sun_position.rigth_ascension_parallax;
return