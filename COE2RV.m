% Define a function to transform COE to RV
function[R,V]=COE2RV(a,e,i,RAAN,perarg,nu)
    mu=398600.44; %m^3/s^2
    rpmag=(a*(1-e^2))/(1+e*cos(nu));
    rp=[rpmag*cos(nu);rpmag*sin(nu);0];
    vp=sqrt(mu/(a*(1-e^2)))*[-sin(nu);e+cos(nu);0];
    A=[cos(RAAN)*cos(perarg)-sin(RAAN)*sin(perarg)*cos(i) -cos(RAAN)*sin(perarg)-sin(RAAN)*cos(perarg)*cos(i) sin(RAAN)*sin(i);...
        sin(RAAN)*cos(perarg)+cos(RAAN)*sin(perarg)*cos(i) -sin(RAAN)*sin(perarg)+cos(RAAN)*cos(perarg)*cos(i) -cos(RAAN)*sin(i);...
        sin(perarg)*sin(i) cos(perarg)*sin(i) cos(i)];
    R=A*rp;
    V=A*vp;
end