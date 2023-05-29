clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;
%
pltensize=10;  hr=1; minu=30;  
%
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='pmsl spread';   fignam=[expri,'_pmsl-sprd3_'];  unit='hPa';
%
% plon=[134 144]; plat=[30 38];

%     plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'2_']; 
%  plon=[134.5 143.5]; plat=[32 38.5]; %fignam=[fignam,'3_']; 

%
load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd; %cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17 19],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7];
L=[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6];
%---
%     tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
% member=1:50; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% member=1:2:50; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
member=51:1000; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
load('H01km_center.mat')
%%
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');   s_hr=num2str(mod(ti,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');    
    
         ntrack=1+(ti-0)*6+(tmi-0)/10; 

    %
    % read ensemble
    for imem=1:pltensize     
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      if imem==1
       lon = double(ncread(infile,'lon'));
       lat = double(ncread(infile,'lat'));
       [nx, ny]=size(lon);
       pmsl_ens=zeros(nx,ny,pltensize);
      end         
      pmsl_ens(:,:,imem)=ncread(infile,'pmsl'); 
    end  %imem

    %---
  
   ensmean=repmat(mean(pmsl_ens,3),[1,1,pltensize]);
   enspert=pmsl_ens-ensmean;
   sprd=sqrt(sum(enspert.^2,3)./(pltensize-1));  

    %%
      %
      %---plot
      plon=[131 145.5]; plat=[28 40.5]; 

      plotvar=sprd;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
      %  
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
      [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      
      hold on 
      %---
      % m_coast('color','k');
      % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
      m_usercoast('gumby','linewidth',1,'color',[0.95 0.95 0.95],'linestyle','--')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
 %
%       plotcnt=[10 20 30]; cntcol=[0.1 0.1 0.1];
%   [c,hdis]=m_contour(lon,lat,squeeze(mean(pmsl_ens,3)),plotcnt,'color',cntcol,'linewidth',1.8);     
% clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500,'color',cntcol)   


    for imem=1:3:50
      m_plot(lon(typhoon_center(ntrack,imem)),lat(typhoon_center(ntrack,imem)),'.','color',[0.01 0.05 0.8],'Markersize',10); hold on
%       m_contour(lon,lat,pmsl_ens(:,:,imem),[970 985 1005],'color',[0.2 0.2 0.2],'linewidth',0.8);
      drawnow  
    end

   for imem=51:115:1000
      m_plot(lon(typhoon_center(ntrack,imem)),lat(typhoon_center(ntrack,imem)),'.','color',[0.8 0.05 0.01],'Markersize',10); hold on
%       m_contour(lon,lat,pmsl_ens(:,:,imem),[970 985 1005],'color',[0 0 1],'linewidth',0.8);
      drawnow  
   end
    

m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')


      %
      tit={[titnam];[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
      title(tit,'fontsize',18)
      %
% xp=666;yp=653; m_plot(lon(xp,yp),lat(xp,yp),'kx','markersize',20,'linewidth',3)
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
      outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize)];
      if saveid==1
       print(hf,'-dpng',[outfile,'.png'])    
       system(['convert -trim ',outfile,'.png ',outfile,'.png']);
      end

  end %min
end %hr
