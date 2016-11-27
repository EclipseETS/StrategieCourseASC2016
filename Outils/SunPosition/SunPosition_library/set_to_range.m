function var = set_to_range(var, min_interval, max_interval)


% if(var>0)
%     var = var - max_interval * floor(var/max_interval);
% else
%     var = var - max_interval * ceil(var/max_interval);
% end
% 
% if(var<min_interval)
%     var = var + max_interval;
% end

var = var - max_interval * floor(var/max_interval);

if(var<min_interval)
    var = var + max_interval;
end