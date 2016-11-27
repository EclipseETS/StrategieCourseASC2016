function observer_local_hour = observer_local_hour_calculation(apparent_stime_at_greenwich, location, sun_rigth_ascension)

observer_local_hour = apparent_stime_at_greenwich + location.longitude - sun_rigth_ascension;
% Set the range to [0-360]
observer_local_hour = set_to_range(observer_local_hour, 0, 360);
return