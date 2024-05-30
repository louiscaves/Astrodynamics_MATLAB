% Function to return series of manuevers needed to get from a ciruclar
% orbit a_init to a final circular orbit a_final with limited thrust
% capability dvMax
function [N_of_manuever,time_of_maneuver,dv_of_manuever,a_tran,ecc_tran]=planManuevers(a_init,a_final,dvMax)
    mu=398600.44;
    nLarge=20; %arbitrary number larger than number of necessary transfer manuevers to initialize array lengths to

    a_tran=zeros([1,nLarge]); %array to store values of a for each intermediate transfer orbit
    rp_tran=zeros([1,nLarge]); % array to store perigee distance for each
    ra_tran=zeros([1,nLarge]); % array to store apogee distance for each
    ecc_tran=zeros([1,nLarge]); % eccentricity of orbit
    
    [a_tran(1),rp_tran(1),ra_tran(1),ecc_tran(1)]=forward_boost(a_init,a_init,dvMax); % first boost to leave initial orbit
    time_of_maneuver=zeros([1,nLarge]); %stores the relative time when each manueuver is necessary if the initial maneuver is initiated at time t=0
    time_of_maneuver(1)=0; %first maneuver happens at t=0, this will be set latter
    time_of_maneuver(2)=pi*sqrt(a_tran(1)^3/mu); %first manuever performed at t=0, this is the time to perform next manuever
    
    %while loop to find number of maneuvers necessary at full thrust
    i=2;
    tooBig=false;
    while tooBig==false
        [a_tran(i),rp_tran(i),ra_tran(i),ecc_tran(i)]=forward_boost(a_tran(i-1),ra_tran(i-1),dvMax);
        time_of_maneuver(i+1)=time_of_maneuver(i)+pi*sqrt(a_tran(i)^3/mu); %time of next maneuver is 0.5*Period of this transfer orbit
        if ra_tran(i)>a_final
            tooBig=true;
            n_fullthrust=(i-1);
        end
        i=i+1;
    end
    
    % Overwrite final transfer orbit (n_fullthust+1) since it is too big
    % Final boost at lower dv to reach desired final orbit
    a_tran(n_fullthrust+1)=(a_final+ra_tran(n_fullthrust))/2; %size of final transfer orbit
    rp_tran(n_fullthrust+1)=ra_tran(n_fullthrust);
    ra_tran(n_fullthrust+1)=a_final;
    ecc_tran(n_fullthrust+1)=1-rp_tran(n_fullthrust+1)/a_tran(n_fullthrust+1);
    
    % Find dv required to reach final transfer orbit of desired size
    v_almost_last=sqrt(mu*(2/ra_tran(n_fullthrust)-1/a_tran(n_fullthrust))); % Velocity before manuever is made
    dv_almostFinal=sqrt(mu*(2/rp_tran(n_fullthrust+1)-1/(a_tran(n_fullthrust+1))))-v_almost_last; % dv required for manuever
    
    % Need one final maneuver to leave final transfer orbit and enter circular orbit at desired radius
    time_of_maneuver(n_fullthrust+2)=time_of_maneuver(n_fullthrust+1)+pi*sqrt(a_tran(n_fullthrust+1)^3/mu); %time to perform final maneuver out of the final transfer orbit into the desired circular orbit
    v_last=sqrt(mu*(2/a_final-1/a_tran(n_fullthrust+1)));
    dvFinal=sqrt(mu/a_final)-v_last;
    
    % Store all dvs in a single array for easy indexing later
    dv_of_manuever=[dvMax*ones([1,n_fullthrust]),dv_almostFinal,dvFinal];
    N_of_manuever=n_fullthrust+2;
end