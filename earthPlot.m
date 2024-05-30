function []=earthPlot
    %generate sphere to represent the earth
    rE=6378.137; %earth radius in km
    [x1,y1,z1]=sphere;
    xe=x1*rE;
    ye=y1*rE;
    ze=z1*rE;
    surf(xe,ye,ze)

    %wrap image of earth around sphere
    imData = imread('2_no_clouds_4k.jpg'); %load picture of earth
    ch = get(gca,'children');
    set(ch,'facecolor','texturemap','cdata',flipud(imData),'edgecolor','none');
    axis equal
    xlabel('x position (km)')
    ylabel('y position (km)')
    zlabel('z position (km)')
    %title('3D Plot of Orbital Trajectory')
end
