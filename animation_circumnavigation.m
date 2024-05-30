% Animation of circumnavigation during phasing
figure(7)
   Ncount2=0;
   fram2=0;
   N_begin_phasing=ceil((time_begin_phasing)/(dt));
   N_thirdphase=ceil((time_third_phase/dt));
   animationTimestep=3000; %wont use every timestep of integration to generate movie, would to too comutationally expensive for a visual aid
   aniVect=[N_begin_phasing:animationTimestep/dt:N_thirdphase];

     for j=1:length(aniVect)
         Ncount2=Ncount2+1;
         fram2=fram2+1;
         
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
        hold on
        plot(relative_position(2,aniVect(j)),relative_position(1,aniVect(j)),'r.','MarkerSize',8)


         
         hold off
         % axis([40 60 -15 10]);
         h2=gca; 
         get(h2,'fontSize'); 
         set(h2,'fontSize',12)
         % xlabel('Longitude','fontSize',12);
         % ylabel('Latitude','fontSize',12);
         title('Relative Position','fontsize',14);
         %legend({'Insat-1','Yellowhammer',''},'Location','northeastoutside')
         fh = figure(7);
         set(fh, 'color', 'white'); 
         F2=getframe;

         % Write to the GIF File 
         im = frame2im(F2); 
         [imind,cm] = rgb2ind(im,256); 
         if j == 1 
              imwrite(imind,cm,'animation_circumnav.gif','gif', 'Loopcount',1); 
         else 
              imwrite(imind,cm,'animation_circumnav.gif','gif','WriteMode','append'); 
         end 
      end

      movie(F2,fram2,20);