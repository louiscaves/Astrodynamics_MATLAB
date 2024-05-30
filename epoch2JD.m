%Define a function to convert epoch to Julian Date
function JD=epoch2JD(hour,minute,second,day,month,year) %Julian date from epoch, equation from nlecture notes
    JD=367*year - floor(7*(year+floor((month+9)/12))/4) + floor(275*month/9) + day + 1721013.5 + ((((second/60)+minute)/60)+hour)/24;
end
