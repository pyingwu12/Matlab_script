
% load('colormap/colormap_wind2.mat') 
% cmap=colormap_wind2; 
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[0.5 1 2 4 6 9 12 15 18 21 25 30 35];

load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([1 3 4 6 7 8 9 11 12 14],:); 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[3 6 9 12 15 18 21 24 27];

%%
plotvar=mean(spd10_ens,3);
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
%%
  for plti=pltspds    
      
    %---plot    
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on 
    
    m_contour(lon,lat,plotvar,[plti plti],'linewidth',1.5,'color',[0.1 0.1 0.1]);  
    %---
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
    % 
    hold on
    pltensize=1000;
    for imem=1:pltensize     
      m_contour(lon,lat,spd10_ens(:,:,imem),[plti plti],'linewidth',0.8,'color',[0.5 0.5 0.5]); 
      drawnow
    end    
%     for imem=1:pltensize     
%       m_plot(lon_track(pltime,imem),lat_track(pltime,imem),'.','color',[0.3 0.3 0.3],'markersize',10)
%     end
    %
    tit={[titnam,' (',num2str(plti),' m/s)'];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)    
    %
    %---colorbar---
      fi=find(L>pmin,1);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
%         hFills(idx).ColorData=uint8(cmap2(idx+fi+1,:)');
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
     %
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
              '_m',num2str(pltensize),'thrd',num2str(plti)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
  end %thi