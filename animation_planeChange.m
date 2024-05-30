%Plane change animation

fig=10;

figure(fig)
   Ncount2=0;
   fram2=0;
   % animate up to the beginning of the phasing maneuver
   N_last_inc=ceil(t_incChange2/dt);
   N_last_Maneuver=floor((time_of_maneuvers(9)+time_of_maneuvers(10))/(2*dt));
   animationTimestep=3000; %wont use every timestep of integration to generate movie, would be to too comutationally expensive for a visual aid
   plotVect=[N_last_Maneuver:(animationTimestep/dt):N_last_inc+animationTimestep];
   
   

     for j=1:length(plotVect)
         Ncount2=Ncount2+1;
         fram2=fram2+1;
         earthPlot
         hold on
         plot3(insat_position(1,plotVect),insat_position(2,plotVect),insat_position(3,plotVect),'r',LineWidth=1.25);
         plot3(yellowhammer_position(1,:),yellowhammer_position(2,:),yellowhammer_position(3,:),'k',LineWidth=2);
         plot3(insat_position(1,plotVect(j)),insat_position(2,plotVect(j)),insat_position(3,plotVect(j)),'ro','markersize',6);
         plot3(yellowhammer_position(1,plotVect(j)),yellowhammer_position(2,plotVect(j)),yellowhammer_position(3,plotVect(j)),'ks','MarkerSize',8);
         % hold on
         % plot(x_1(j),y_1(j),'.','markersize',20);
         % plot(x_2(j),y_2(j),'.','markersize',20);
         % hold off
         % line([0 x_1(j)], [0 y_1(j)],'Linewidth',2);
         % line([x_1(j) x_2(j)], [y_1(j) y_2(j)],'linewidth',2);
         view(135,5)
         hold off
         axis([-50000 50000 -50000 50000 -7500 7500]);
         h2=gca; 
         get(h2,'fontSize'); 
         set(h2,'fontSize',12)%,'XTick',[],'YTick',[],'ZTick',[])
         % xlabel('x position (km)','fontSize',12);
         % ylabel('y position (km)','fontSize',12);
         % zlabel('z position (km)','FontSize',12);
         axis off
         %title('Orbital Trajectory of Insat-1','fontsize',14);
         %legend({'','Insat-1','Yellowhammer'},'Location','northeastoutside')
         fh = figure(fig);
         
         set(fh, 'color', 'white'); 
         F2=getframe;

         % Write to the GIF File 
         im = frame2im(F2); 
         [imind,cm] = rgb2ind(im,256); 
         if j == 1 
              imwrite(imind,cm,'animation_planeChange.gif','gif', 'Loopcount',1); 
         else 
              imwrite(imind,cm,'animation_planeChange.gif','gif','WriteMode','append'); 
         end 
      end

      movie(F2,fram2,20);