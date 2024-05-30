% RK4 method to propagate orbits
function [v_next]=RK4(v_init,dt)
    mu=398600.44;

    k1=twoBodyEOM(0,v_init,mu);
    k2=twoBodyEOM(0+dt/2,v_init+k1*dt/2,mu);
    k3=twoBodyEOM(0+dt/2,v_init+k2*dt/2,mu);
    k4=twoBodyEOM(0+dt,v_init+k3*dt,mu);

    v_next=v_init+dt/6.*(k1+2.*k2+2.*k3+k4);
end
