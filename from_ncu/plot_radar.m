function hc=plot_radar(Var,lon,lat,cmap,L,zmind,plon,plat)

  clen=length(cmap);
  %Msize=3;   
  Msize=4;   
  %plon=[117.3 124.5]; plat=[19.8 27.5];   % 4 radar  
  %plon=[118.5 124.5]; plat=[21.8 28];   % RCWF
  %plon=[118.3 122.7]; plat=[20.3 25.6];   % RCCG+RCKT  
  if zmind==1; 
   Msize=4.8;  %plon=[118.6 121.4]; plat=[21.7 24.3];  %RCCG   
  elseif zmind==2;
   Msize=4.6;  %plon=[118.9 121.8];  plat=[21 24.3];   %RCCG+RCKT   
  end
  M=length(Var);
  %figure('position',[600 100 600 500])
  %m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')i
   figure('position',[100 200 900 750])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')

  [~, b]=sort(Var);

  for j=1:M
     i=b(j) ;
    for k=1:clen-2;
      if (Var(i) > L(k) && Var(i)<=L(k+1))
        c=cmap(k+1,:);
        hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
        set(hp,'linestyle','none');    
      end      
    end
    if Var(i)>L(clen-1)
       c=cmap(clen,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
       set(hp,'linestyle','none');   
    end
    if Var(i)<L(1)
       c=cmap(1,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
       set(hp,'linestyle','none');   
    end   
  end
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:45,'fontsize',16); 
  m_gshhs_h('color','k','LineWidth',0.8);
  %m_coast('color','k');
  cm=colormap(cmap);    caxis([L(1) L(length(L))]);  
%  hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',17,'LineWidth',1); 
%  set(hc,'position',[0.8 0.12 0.0275 0.8])
%  title(hc,'dBZ','position',[0.5 55],'fontsize',17)
  hc=Recolor_contourf(hp,cm,L,'h');   set(hc,'fontsize',17,'LineWidth',1);
  set(hc,'position',[0.205 0.038 0.62 0.022])
  title(hc,'m/s','position',[14.4 -1.8],'fontsize',18)


  
  
