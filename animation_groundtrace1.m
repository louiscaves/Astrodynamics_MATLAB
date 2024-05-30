%Practicing generating animation of ground trace

figure(4)
   Ncount2=0;
   fram2=0;
   N_last_boost=ceil((time_of_maneuvers(9)+time_of_maneuvers(10))/(2*dt));
   dotspacing=100; % spacing for ground trace
   plotVect=[1:dotspacing/dt:N_last_boost];
   animationTimestep=3000; %wont use every timestep of integration to generate movie, would to too comutationally expensive for a visual aid
   aniVect=[1:animationTimestep/dt:N_last_boost];

     for j=1:length(aniVect)
         Ncount2=Ncount2+1;
         fram2=fram2+1;
         earthPlot2D;
         hold on
         plot(insat_geodetic(2,plotVect),insat_geodetic(1,plotVect),'r.')
         plot(yellowhammer_geodetic(2,plotVect),yellowhammer_geodetic(1,plotVect),'kx','MarkerSize',10)
         plot(insat_geodetic(2,aniVect(j)),insat_geodetic(1,aniVect(j)),'ro','markersize',10);
         % hold on
         % plot(x_1(j),y_1(j),'.','markersize',20);
         % plot(x_2(j),y_2(j),'.','markersize',20);
         % hold off
         % line([0 x_1(j)], [0 y_1(j)],'Linewidth',2);
         % line([x_1(j) x_2(j)], [y_1(j) y_2(j)],'linewidth',2);
         hold off
         axis([-180 180 -90 90]);
         h2=gca; 
         get(h2,'fontSize'); 
         set(h2,'fontSize',12)
         xlabel('Longitude','fontSize',12);
         ylabel('Latitude','fontSize',12);
         title('Ground Trace of Insat-1','fontsize',14);
         legend({'Insat-1','Yellowhammer',''},'Location','northeastoutside')
         fh = figure(4);
         set(fh, 'color', 'white'); 
         F2=getframe;

         % Write to the GIF File 
         im = frame2im(F2); 
         [imind,cm] = rgb2ind(im,256); 
         if j == 1 
              imwrite(imind,cm,'animation_groundtrace1.gif','gif', 'Loopcount',1); 
         else 
              imwrite(imind,cm,'animation_groundtrace1.gif','gif','WriteMode','append'); 
         end 
      end

      movie(F2,fram2,20);