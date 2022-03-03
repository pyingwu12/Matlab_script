function plot_accum(acci,xi,yj,ai,cmap,ctnid,textid,seaid)

%---set clim and end time---    
      if mod(ai,2)~=0; clim=[0 ai*75+25]; elseif ai>=6; clim=[0 400]; else clim=[0 ai*75]; end    % colorbar      
      if ctnid~=0; clim=[0 ctnid]; end       
      L=fix(clim(2)/17*(1:16));
      if clim(2)==250;      L=[  1   5  10  20  30  40  50  60  70  90 110 130 150 180 200 230];
      elseif clim(2)==100;  L=[  1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];
      elseif clim(2)==200;  L=[  5  10  15  20  30  40  50  60  70  80 100 120 140 160 180 200]; 
      elseif clim(2)==300;  L=[  5  10  20  30  40  50  60  75  90 110 130 150 180 220 260 300]; 
      elseif clim(2)==400;  L=[  5  10  20  30  50  70 100 130 160 190 220 260 300 350 400 450]; 
      elseif clim(2)==1;    L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300];
      elseif clim(2)==999;  L=[ 10  30  50  80 100 120 140 160 200 240 280 320 360 400 450 500];
      elseif clim(2)==150;  L=[  5  10  15  20  30  40  50  60  70  80  90 100 110 120 130 140];
      end
%---find maximum---
      [Y mxI]=max(acci);
      [maxm myi]=max(Y);
      mxi=mxI(myi);     
%---plot---
      if     seaid==1;  plon=[118.3 122.85];  plat=[21.2 25.8]; %plon=[117.6924  122.1526]; plat=[21.3721 25.5304]; 
      %elseif seaid==2;  plon=[118.3 121.8];   plat=[21 24.3]; 
      elseif seaid==2;  plon=[118.9 121.8];   plat=[21 24.3];    %for sampling error paper rainfall 
      else              plon=[119 123];       plat=[21.65 25.65]; 
      end
      L2=[min(min(acci)),L];
      figure('position',[100 200 600 500])
%      figure('position',[100 200 600 800])
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
      %m_proj('Lambert','lon',plon,'lat',plat,'clongitude',120.75,'parallels',[30 60],'rectbox','on')
      %m_proj('Miller','lon',plon,'lat',plat)      
      [~, hp]=m_contourf(xi,yj,acci,L2);   set(hp,'linestyle','none');
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45); 
      m_gshhs_h('color','k','LineWidth',0.8);
      %m_coast('color','k');
      cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
      hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);
      title(hc,'mm','position',[0.5 303 0],'fontsize',14);
      if textid~=0
        hold on
        m_text(xi(mxi+1,myi+1),yj(mxi+1,myi+1),num2str(round(maxm*10)/10),'color','k','fontsize',14)
        m_plot(xi(mxi,myi),yj(mxi,myi),'o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 0],'MarkerSize',5)
      end        
