function observer_local_hour = observer_local_hour_calculationR(apparent_stime_at_greenwich, loc_llh, sun_rigth_ascension)

observer_local_hour = apparent_stime_at_greenwich + loc_llh(2,:) - sun_rigth_ascension;
% Set the range to [0-360]
observer_local_hour = set_to_range(observer_local_hour, 0, 360);
return