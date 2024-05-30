% Define a function to transform RV to COE
function [a,e,inc,RAAN,perarg,nu]=RV2COE(R,V)
    mu=398600.44; %m^3/s^2
    rmag=sqrt(R'*R);
    vmag=sqrt(V'*V);
    a=((2/rmag)-(vmag^2/mu))^(-1);
    h=cross(R,V);
    eVec=1/mu*(cross(V,h)-mu/rmag*R);
    e=sqrt(eVec'*eVec);
    nu=acos((dot(R,eVec)/(rmag*e)));
    if dot(R,V)<0
       nu=2*pi-nu;
    end
    eH=h/sqrt(h'*h);
    eN=cross([0;0;1],eH);
    inc=acos(h(3)/sqrt(h'*h));
    RAAN=acos(eN(1)/sqrt(eN'*eN));
    if eN(2)<0
        RAAN=2*pi-RAAN;
    end
    perarg=acos(dot(eVec,eN)/(sqrt(eVec'*eVec)*sqrt(eN'*eN)));
    if eVec(3)<0
        perarg=2*pi-perarg;
    end
end