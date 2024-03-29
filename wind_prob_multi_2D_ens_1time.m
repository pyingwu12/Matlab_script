clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;
%
pltensize=100;  hr=[14]; minu=[30];  thresholds=[10 15 20 25 30]; 

plotprob=75;% unit:%
%
expri='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Wind speed probability';   fignam=[expri,'_windprob-compo'];  unit='m/s';
%
% plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'2_']; 
 plon=[134.5 143.5]; plat=[32 38.5]; %fignam=[fignam,'3_']; 


%---

%%
%---
for ti=hr
  s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');    
    %
    % read ensemble
    tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
    for imem=1:pltensize     
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      if imem==1
       lon = double(ncread(infile,'lon'));
       lat = double(ncread(infile,'lat'));
       [nx, ny]=size(lon);
       spd10_ens=zeros(nx,ny,pltensize);
      end  
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      spd10_ens(:,:,imem)=double(u10(:,:).^2+v10(:,:).^2).^0.5;  
    end  %imem
%%
    % probability for different thresholds
    wind_pro=zeros(nx,ny,length(thresholds));
    for thi=1:length(thresholds)       
      for i=1:nx
        for j=1:ny
          wind_pro(i,j,thi)=length(find(spd10_ens(i,j,:)>=thresholds(thi)));
        end
      end
    end %thi
    wind_pro=wind_pro./pltensize*100;    
  %%  
  
  compo_prob=zeros(nx,ny);
  
  for thi=1:length(thresholds)
     compo_prob(squeeze(wind_pro(:,:,thi))>=plotprob)=thresholds(thi);     
  end
  %%
    %---plot
    load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([4 8 9 10 11 13],:); 
cmap=cmap(1:length(thresholds)+1,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=thresholds;
%%
    %
    plotvar=mean(spd10_ens,3);
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end  
      
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
 
     [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on 
%      [~, hp]=m_contourf(lon,lat,compo_prob,thresholds,'linestyle','none');  hold on 
%     
%     colormap(cmap(1:length(thresholds),:))
%     colorbar
    
    
%     m_contour(lon,lat,mean(spd10_ens,3),thresholds,'color','k');  hold on 
    
    [c,hdis]=m_contour(lon,lat,compo_prob,thresholds,'color','k','linewidth',1.5);
%     clabel(c,hdis,thresholds,'fontsize',15,'LabelSpacing',1000)   

    
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
%     m_usercoast('gumby','linewidth',1,'color',[0.1 0.6 0.1],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 

    tit={[titnam,' >',num2str(plotprob),'%'];[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
    title(tit,'fontsize',18)
    
    %---colorbar--- 
          fi=find(L>pmin,1);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
      %
   outfile=[outdir,'/',fignam,'1_',month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'prob',num2str(plotprob),];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %%
    
    load('colormap/colormap_PQPF.mat') 
cmap0=colormap_PQPF; cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17 19],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;

    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
 
    
%     m_contourf(mean(spd10_ens,3),20)
    
    
    for thi=1:length(thresholds)
     m_contour(lon,lat,wind_pro(:,:,thi),[plotprob plotprob],'color',cmap(thi,:),'linewidth',2); hold on   
    end 
    %---
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 

    tit={[titnam,' >',num2str(plotprob),'%'];[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
    title(tit,'fontsize',18)
    
    hc=colorbar('fontsize',15,'LineWidth',1.5);
    caxis([0 1])
     L1=((0.5:length(thresholds)-0.5)*(diff(caxis)/(length(thresholds))))+min(caxis());
    set(hc,'YTick',L1,'YTickLabel',thresholds,'fontsize',15,'LineWidth',1.5);
    colormap(cmap(1:length(thresholds),:))
    title(hc,unit,'fontsize',15);  drawnow;

    %
    outfile=[outdir,'/',fignam,'2_',month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'prob',num2str(plotprob),];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
  end %min
end %hr
