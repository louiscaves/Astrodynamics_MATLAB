% Define a function to return latitude and longitude given satellite
% position and eath rotation angle
function [lattitude_longitude]=ECI2ECEF(sat,era)
    recef=rotz(era)'*sat.position;
    recefmag=sqrt(recef'*recef);
    lattitude=asin(recef(3)/recefmag);
    longitude=atan2(recef(2),recef(1));
    lattitude_longitude(1)=lattitude*180/pi;
    lattitude_longitude(2)=longitude*180/pi;
end