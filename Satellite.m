classdef Satellite
    % Satellite class of which Insat and Yellowhammer will be instances of
    properties
        position
        velocity
        semimajor
        eccentricity
        inclination 
        RAAN
        perigeeArg
        trueAnom
        deltaV = 0
    end

    methods
        function sat = initial_RV(sat)
            [sat.position,sat.velocity] = COE2RV(sat.semimajor,sat.eccentricity,sat.inclination,sat.RAAN,sat.perigeeArg,sat.trueAnom);
        end

        function [sat] = propagate (sat,dt)
            state=RK4([sat.position;sat.velocity],dt);
            sat.position=state(1:3);
            sat.velocity=state(4:6);
            [sat.semimajor,sat.eccentricity,sat.inclination,sat.RAAN,sat.perigeeArg,sat.trueAnom]=RV2COE(sat.position,sat.velocity);
        end

        function [sat,v_hat] = boost_forward (sat,dv)
            v_hat=sat.velocity/sqrt(sat.velocity'*sat.velocity);
            sat.velocity=sat.velocity+dv*v_hat;
            sat.deltaV=sat.deltaV+dv;
        end

        function [sat,dv] = inc_change (sat, inclination_new)
            v_init=sqrt(sat.velocity'*sat.velocity);
            dv=2*v_init*sin(abs(inclination_new-sat.inclination)/2);
            sat.inclination=inclination_new;
            [~,sat.velocity]=COE2RV(sat.semimajor,sat.eccentricity,sat.inclination,sat.RAAN,sat.perigeeArg,sat.trueAnom);
            sat.deltaV=sat.deltaV+dv;
        end

        function [sat,dv,a_chase]= phase (sat,d_ang)
            mu=398600.44;
            v_init=sat.velocity;
            v_hat=v_init/sqrt(v_init'*v_init);
            a_tgt=sqrt(sat.position'*sat.position);
            a_chase=(1+d_ang/(2*pi))^(2/3)*a_tgt;
            v_final=sqrt(mu*(2/a_tgt-1/a_chase));
            dv=abs(v_final-sqrt(v_init'*v_init));
            sat.velocity=v_init+dv*sign(d_ang)*v_hat;
            sat.semimajor=a_chase;
            sat.deltaV=sat.deltaV+2*dv;
        end
    end
end