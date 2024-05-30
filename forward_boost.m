%Define a function to return new orbit given initial orbit and dv
function [a_final,r_perigee,r_apogee,eccentricity]=forward_boost(a_init,r_perigee,dv)
    mu=398600.44;
    v_init=sqrt(mu*(2/r_perigee-1/a_init));
    v_final=v_init+dv;
    a_final=(2/r_perigee-v_final^2/mu)^(-1);
    r_apogee=a_final*(2-r_perigee/a_final);
    eccentricity=1-r_perigee/a_final;
end