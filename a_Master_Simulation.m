clear; clc; close all
mu=398600.44;

%%%%%%%%%%%%%%%%%%%
% Main Simulation %
%%%%%%%%%%%%%%%%%%%

dt=1; % Timestep for numerical integration, timestep used to generate figures shown in technical report was 0.1s
generate_animations=false; % Generate animations from simulated data? Recommend setting to false, animations can be generated later from saved data if needed

% Define Initial Conditions
insat=Satellite;
insat.semimajor=7028;
insat.eccentricity=0;
insat.inclination=10*pi/180;
insat.RAAN=30*pi/180;
insat.perigeeArg=0;
insat.trueAnom=0;
insat=insat.initial_RV; %Finds initial position and velocity vectors given orbital elements

yellowhammer=Satellite;
yellowhammer.semimajor=42164;
yellowhammer.eccentricity=0;
yellowhammer.inclination=0;
yellowhammer.RAAN=0;
yellowhammer.perigeeArg=0;
yellowhammer.trueAnom=pi;
yellowhammer=yellowhammer.initial_RV;

% Initial Epoch 01Feb2024 0h00 UTC
initial_day=1;
initial_month=2;
initial_year=2024;
initial_hour=0;
initial_minute=0;
initial_second=0;
JD_init=epoch2JD(initial_hour,initial_minute,initial_second,initial_day,initial_month,initial_year);
JD_now=JD_init;
ERA=JD2ERA(JD_now);


% Define Series of manuevers to be made by Insat-1
dvMax=0.468;
%Call funciton planManeuvers to find a series of maneuvers to reach a given (circular) orbit given initial (circular) orbit and max dv  
[N_maneuvers,time_of_maneuvers,dv_of_maneuvers,aFinal_manuevers,eccFinal_maneuvers]=planManuevers(insat.semimajor,yellowhammer.semimajor,dvMax);

% We also need to plan the inclination change(s). Thrusters are not
% powerful enough to change inclination by 10° at this speed. We shall do
% to equal maneuvers of 5° each
% This is implemented in the time iterration loop

% Define phasing manuevers, we start 0.25° behind yellowhammer. We wish to
% phase infront by 0.25°, and then phase behind again by 0.1
phase_angle1=-0.5*pi/180;
phase_angle2=0.35*pi/180;
time_begin_phasing=0; % placeholder to be overwritten later
time_second_phase=0;
time_third_phase=0;

% Find time of opportunity to begin manuevering so that yellowhammer is there when we arrive
% We wish to arrive 0.25° behind yellowhammer
d_ang_insat=mod(180*(N_maneuvers-1),360); % each manuever is made 180° from the last.
d_ang_yellowhammer=mod(time_of_maneuvers(N_maneuvers)*sqrt(mu/yellowhammer.semimajor^3)*180/pi,360);
opportunity_angle=d_ang_yellowhammer-d_ang_insat-0.25;

% Find time at which to opportuity angle occurs, this is when to start maneuvering
ang0_insat=atan2d(insat.position(2),insat.position(1));
ang0_yellowhammer=atan2d(yellowhammer.position(2),yellowhammer.position(1));
time_initialManuever=((opportunity_angle-ang0_insat+ang0_yellowhammer)*pi/180)/(sqrt(mu)*(1/insat.semimajor^(3/2)-1/yellowhammer.semimajor^(3/2)));
time_of_maneuvers=time_of_maneuvers+time_initialManuever;


% Define Parameters of Simulation
missionTime=440000;

Nt=missionTime/dt;

% Log states over time
insat_position=zeros([3,Nt]);
insat_position(:,1)=insat.position;
insat_geodetic=zeros([2,Nt-1]);

yellowhammer_position=zeros([3,Nt]);
yellowhammer_position(:,1)=yellowhammer.position;
yellowhammer_geodetic=zeros([2,Nt-1]);

relative_position=zeros([3,Nt]);



% Keep track of maneuvering information
nm=1; % variable to count the number of manuevers that have been made to increase orbital size
incChange=[false,false]; % did the inclination changes happen yet? this ensures the meneuver is not attempted more than once
% Variables to store direction of dvs
vHat_maneuvers=zeros([3,N_maneuvers]);
vHat_incChange=zeros([3,2]);
vHat_phase=zeros([3,3]);

for i=[2:Nt]
    % Propagate Orbits and recover state vairiables at each timestep
    insat=insat.propagate(dt);
    insat_position(:,i)=insat.position;
    yellowhammer=yellowhammer.propagate(dt);
    yellowhammer_position(:,i)=yellowhammer.position;

    % Find relative position in  yellowhammer body frame
    rHat_yellowhammer=yellowhammer.position/sqrt(yellowhammer.position'*yellowhammer.position);
    tHat_yellowhammer=[-1*rHat_yellowhammer(2);rHat_yellowhammer(1);0];
    A_ECI2Body=[rHat_yellowhammer(1), rHat_yellowhammer(2),0
                -1*rHat_yellowhammer(2), rHat_yellowhammer(1), 0
                0, 0, 1];
    relative_position(:,i)=A_ECI2Body*(insat.position-yellowhammer.position);

    % Determine if it is time to make a maneuver, and if so do it
    if nm<=N_maneuvers %size change maneuvers
        if abs((i-1)*dt-time_of_maneuvers(nm))<dt/2
            [insat,vHat_maneuvers(:,nm)]=insat.boost_forward(dv_of_maneuvers(nm));
            nm=nm+1;
        end

    % Inclination change in 2 equal steps of 5°
    elseif abs(insat.position(3))<0.03*(dt/0.1) && incChange(2)==false % Inclination changes can only be performed when crossing equitorial plane, z-position is 0
        if incChange(1)==false %First inclination change to be performed at first equitorial node after final transfer maneuver
            v_prev1=insat.velocity;
            [insat,dvInc1]=insat.inc_change(5*pi/180);
            incChange(1)=true;
            t_incChange1=(i-1)*dt;
            dvtemp1=insat.velocity-v_prev1;
            vHat_incChange(:,1)=dvtemp1/sqrt(dvtemp1'*dvtemp1);

        elseif incChange(2)==false %second inclination change to be performed at the next node
            v_prev2=insat.velocity;
            [insat,dvInc2]=insat.inc_change(0);
            incChange(2)=true;
            t_incChange2=(i-1)*dt;
            dvtemp2=insat.velocity-v_prev2;
            vHat_incChange(:,2)=dvtemp2/sqrt(dvtemp2'*dvtemp2);

            % After placing ourselves in the yellowhammer orbit, we need to chill behind it for 1 whole orbit of period T
            time_begin_phasing=t_incChange2+2*pi*sqrt(insat.semimajor^3/mu);
        end

    % Implement Series of Phasing Maneuvers
    elseif abs((i-1)*dt-time_begin_phasing)<dt/2
        vprev=insat.velocity;
        [insat,dv_phase1,a_phase1]=insat.phase(phase_angle1);
        time_second_phase=time_begin_phasing+2*pi*sqrt(insat.semimajor^3/mu);
        dvtemp=insat.velocity-vprev;
        vHat_phase(:,1)=dvtemp/sqrt(dvtemp'*dvtemp);

    elseif abs((i-1)*dt-time_second_phase)<dt/2
        % unphase from first orbit
        vprev=insat.velocity;
        insat.velocity=insat.velocity-dv_phase1*sign(phase_angle1)*insat.velocity/sqrt(insat.velocity'*insat.velocity);
        %insat.deltaV=insat.deltaV+dv_phase1; %phasing method already counts this dv
        % Phase into second orbit
        [insat,dv_phase2,a_phase2]=insat.phase(phase_angle2);
        time_third_phase=time_second_phase+2*pi*sqrt(insat.semimajor^3/mu);
        dvtemp=insat.velocity-vprev;
        vHat_phase(:,2)=dvtemp/sqrt(dvtemp'*dvtemp);

    elseif abs((i-1)*dt-time_third_phase)<dt/2
        vprev=insat.velocity;
        % unphase from second orbit
        insat.velocity=insat.velocity-dv_phase2*sign(phase_angle2)*insat.velocity/sqrt(insat.velocity'*insat.velocity);
        %insat.deltaV=insat.deltaV+dv_phase2;
        dvtemp=insat.velocity-vprev;
        vHat_phase(:,3)=dvtemp/sqrt(dvtemp'*dvtemp);
    end


    % Update Julian Date and find new Earth Rotation Angle
    JD_now=JD_now+dt/86400;
    ERA=JD2ERA(JD_now);
    insat_geodetic(:,i-1)=ECI2ECEF(insat,ERA);
    yellowhammer_geodetic(:,i-1)=ECI2ECEF(yellowhammer,ERA);
end

% Recover Mission end time in DDMMYYY hr:min:sec
total_mission_time=time_third_phase;
% Initial Epoch 01Feb2024 00:00:00.00 UTC
[duration_days,duration_hours,duration_minutes,duration_seconds]=timeConvert(time_third_phase);
% Mission End Time = Initial Epoch + mission duration
end_day=initial_day+duration_days;
end_month=initial_month;
end_year=initial_year;
end_hour=initial_hour+duration_hours;
end_minute=initial_minute+duration_minutes;
end_second=initial_second+duration_seconds;
disp('Mission End Time: ' + string(end_day) + 'Feb2024 ' + string(end_hour) +':'+ string(end_minute) +':'+ string(end_second) +' UTC')

% Total mission fuel used
total_mission_dv=insat.deltaV;
disp('Total Mission Fuel Consumtion: ' + string(total_mission_dv) +' km/s')




% 3D Orbital Plot All 
figure(1)
earthPlot
hold on
plot3(insat_position(1,:),insat_position(2,:),insat_position(3,:),'r',LineWidth=1.25);
plot3(yellowhammer_position(1,:),yellowhammer_position(2,:),yellowhammer_position(3,:),'k',LineWidth=2);
plot3(insat_position(1,end),insat_position(2,end),insat_position(3,end),'ro',MarkerSize=10);
plot3(yellowhammer_position(1,end),yellowhammer_position(2,end),yellowhammer_position(3,end),'ks',MarkerSize=10);
hold off
legend({'','Insat-1','YellowHammer'})
axis equal

% 3D Orbital Plot Size Change
figure(4)
earthPlot
hold on
plot3(insat_position(1,1:ceil(t_incChange1/dt)),insat_position(2,1:ceil(t_incChange1/dt)),insat_position(3,1:ceil(t_incChange1/dt)),'r',LineWidth=1.25);
plot3(yellowhammer_position(1,:),yellowhammer_position(2,:),yellowhammer_position(3,:),'k',LineWidth=2);
plot3(insat_position(1,1),insat_position(2,1),insat_position(3,1),'ro',MarkerSize=10);
plot3(yellowhammer_position(1,1),yellowhammer_position(2,1),yellowhammer_position(3,1),'ks',MarkerSize=10);
hold off
axis equal


% Ground Trace - ECEF
dotspacing=100;
plotVect=[1:dotspacing/dt:Nt];
figure(2)
earthPlot2D
hold on
plot(insat_geodetic(2,plotVect),insat_geodetic(1,plotVect),'r.')
plot(yellowhammer_geodetic(2,plotVect),yellowhammer_geodetic(1,plotVect),'kx')
hold off
xlabel('Longitude')
ylabel('Latitude')
ylim([-90 90])


% Circumnavigation Plot
index_begin_phasing=floor(time_begin_phasing/dt);
figure(3)
plot(relative_position(2,index_begin_phasing:Nt),relative_position(1,index_begin_phasing:Nt))
ylim([-80 80])
set(gca, 'YDir', 'normal','XDir','reverse','YAxisLocation','origin','XAxisLocation','origin');
Ylm=ylim;                          % get x, y axis limits 
Xlm=xlim;                          % so can position relative instead of absolute
X_Xlb=mean(Xlm);                    % set horizontally at midpoint
X_Ylb=0.99*Ylm(1);                  % and just 1% below minimum y value
hXLbl=xlabel('In-Track','Position',[X_Xlb X_Ylb],'VerticalAlignment','top','HorizontalAlignment','center'); 
Y_Xlb=0.99*Xlm(1);
Y_Ylb=mean(Ylm);
hYLbl=ylabel('Range','Position',[Y_Xlb Y_Ylb],'VerticalAlignment','top','HorizontalAlignment','center','Rotation',90); 

% Find closest approach distances for phasing maneuvers
relative_position_mag=zeros([1,Nt-index_begin_phasing]);
for i=[index_begin_phasing:Nt]
    vectemp=relative_position(:,i);
    relative_position_mag(i-index_begin_phasing+1)=sqrt(vectemp'*vectemp);
end
closePass1=min(relative_position_mag(1:ceil((Nt-index_begin_phasing)/2)));
closePass2=min(relative_position_mag);



% Generate animations of orbital dynamics
if generate_animations==true
    animation_orbit
    animation_planeChange
    animation_circumnavigation
    animation_groundtrace1
end





