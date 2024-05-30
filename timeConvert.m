% Convert time change in seconds to days hr:min:sec
function [day,hour,minute,second]=timeConvert(delta_t_sec)
    delta_t_days=delta_t_sec/86400;
    day=floor(delta_t_days);
    delta_t_hrs=(delta_t_days-day)*24;
    hour=floor(delta_t_hrs);
    delta_t_min=(delta_t_hrs-hour)*60;
    minute=floor(delta_t_min);
    second=(delta_t_min-minute)*60;
end


