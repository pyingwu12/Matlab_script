 % plot horizontal colorbar for rainfall
 % please excute accum_sing first



   if ctnid~=0; clim=[0 ctnid]; end
   L=fix(clim(2)/17*(1:16));
   if clim(2)==250;      L=[  1   5  10  20  30  40  50  60  70  90 110 130 150 180 200 230];
   elseif clim(2)==1;    L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300];
   end

   if     seaid==1;  plon=[118.3 122.85];  plat=[21.2 25.8]; %plon=[117.6924  122.1526]; plat=[21.3721 25.5304];
   elseif seaid==2;  plon=[118.9 121.8];   plat=[21 24.3];    %for sampling error paper rainfall
   else              plon=[119 123];       plat=[21.65 25.65];
   end

   L2=[min(min(acci)),L]; 

   figure('position',[100 200 700 800])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [~, hp]=m_contourf(x,y,acci,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
  % m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])
   %hc=Recolor_contourf(hp,cm,L,'horiz');  set(hc,'fontsize',13,'LineWidth',1);

   %set(hc,'position',[0.05 0.05 0.9 0.015])
   %title(hc,'mm','position',[305 -1.95 0],'fontsize',14)

    %set(gcf,'PaperPositionMode','auto');  print('-dpdf','colorbar_rain.pdf'])
    %system('convert -trim -density 500  colorbar_rain.pdf colorbar_rain.png');



