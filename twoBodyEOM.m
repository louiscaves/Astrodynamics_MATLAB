function xdot=twoBodyEOM(t,x,mu)
    %unpack x
    x1=x(1:3); % column vector (x,y,z)
    x2=x(4:6); % column vector (vx,vy,vz)

    %mag of vector transpose*vector
    x1n=sqrt(x1'*x1);
    xdot=[x2;-mu/x1n^3*x1];
end