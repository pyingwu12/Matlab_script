clear
close all

saveid=0;

pltensize=100; pltime=[12];

% expri='Hagibis05kme01'; infilename='201910101800';%hagibis
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% convert_id=2; %1: duc-san default; 2: convert by wu (<-not used,fixed on 230212)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san)
%
expsize=1000;  BCnum=50;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  pmsl spread ratio to IC'];   fignam=[expri,'_pmsl-SprdRatio_'];
%
%cvrt_name={'';'sfc'};cvrt_time={'time';'times'};
%--
%     plon=[134.5 143.5]; plat=[32 38.5]; %hagibis kantou
%     plon=[121.2 138]; plat=[25 36.3]; %kumakawa
% plon=[112 156]; plat=[18 50]; %Fugaku5km
plon=[120 138]; plat=[26 38]; %nagasaki

load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd(1:2:end,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=5:5:35;
% L=[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6];
%---
% tmp=randperm(expsize); 
member=1:pltensize;  %!!!!!!!
%%
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
%   infile=[indir,'/',num2str(member(imem),'%.4d'),'/',cvrt_name{convert_id},infilename,'.nc'];
  if imem==1
      [nx, ny, ntime]=size(ncread(infile,'pmsl'));
      pmsl0=zeros(nx,ny,pltensize,ntime);
  end  
  if isfile(infile) 
    pmsl0(:,:,imem,:) = ncread(infile,'pmsl');
  else
    pmsl0(:,:,imem,:) = NaN;
    disp(['member ',num2str(member(imem),'%.4d'),' file does''t exist'])
  end    
end
lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
%data_time = (ncread(infile,cvrt_time{convert_id}));
data_time = (ncread(infile,'time'));
disp('finished reading files')
%
%%
sprdall_ini=std(pmsl0(:,:,:,1),0,4,'omitnan');
sprd50_ini=std(pmsl0(:,:,1:BCnum,1),0,4,'omitnan');
sprdBC_ini=std(pmsl0(:,:,1:BCnum:pltensize,1),0,4,'omitnan');
%%
% plon=[131 145.5]; plat=[28 40.5];
% close all
for ti=pltime
    pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  sprdall=std(pmsl0(:,:,:,ti),0,4,'omitnan');
  sprd50=std(pmsl0(:,:,1:BCnum,ti),0,4,'omitnan');
  sprdBC=std(pmsl0(:,:,1:BCnum:pltensize,ti),0,4,'omitnan');
  
%     plotcnt=950:10:1010; cntcol=[0.2 0.2 0.2];
    plotcnt=974:3:1013; cntcol=[0.2 0.2 0.2];
    L=[1 2 3 4 5 6 7];

%% all
%
  growthr=sprdall./sprdall_ini;
  pmin=double(min(min(growthr)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%   [~, hp]=m_contourf(lon,lat,growth,L2,'linestyle','none'); hold on      % 
  [~, hp]=m_contourf(lon,lat,sprdall_ini,L2,'linestyle','none'); hold on   
  %
  % m_coast('color','k');
  % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
  m_usercoast('gumby','linewidth',1,'color',[0.9 0.9 0.9],'linestyle','--')
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',120:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
  % 
%   % ens mean
%   [c,hdis]=m_contour(lon,lat,squeeze(mean(pmsl0(:,:,ti,:),4)),plotcnt,'color',cntcol,'linewidth',1.8);     
%   clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500,'color',cntcol) 
  
%  m_contour(lon,lat,sprdall_ini,5,'color',[1 0 0],'linewidth',1.8,'linestyle','--');
  m_contour(lon,lat,growthr,5,'color',[1 0 0],'linewidth',1.8,'linestyle','--');
%    clabel(c,hdis,'fontsize',15,'LabelSpacing',500) 

  tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
  title(tit,'fontsize',18)
  %
%---colorbar---
  fi=find(L>pmin,1);
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
  colormap(cmap);  drawnow;  
  hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
  for idx = 1 : numel(hFills)
    hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
  end
%
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m',num2str(pltensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%---   
 %}
   %% 1-50 
   %
%    close all
growthr=sprd50./sprd50_ini;
  pmin=double(min(min(growthr)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,growthr,L2,'linestyle','none'); hold on      % 
  %
  % m_coast('color','k');
  % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
  m_usercoast('gumby','linewidth',1,'color',[0.9 0.9 0.9],'linestyle','--')
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',125:10:150,'ytick',20:10:50,'color',[0.3 0.3 0.3]); 
  % 
  % ens mean
  [c,hdis]=m_contour(lon,lat,squeeze(mean(pmsl0(:,:,ti,:),4)),plotcnt,'color',cntcol,'linewidth',1.8);     
  clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500,'color',cntcol) 
  
 m_contour(lon,lat,sprd50_ini,5,'color',[1 0 0],'linewidth',1.8,'linestyle','--');
%    clabel(c,hdis,'fontsize',15,'LabelSpacing',500) 

  tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (mem 1-50)']};   
  title(tit,'fontsize',18)
  %
%---colorbar---
  fi=find(L>pmin,1);
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
  colormap(cmap);  drawnow;  
  hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
  for idx = 1 : numel(hFills)
    hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
  end
%
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m0150'];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
   %}
   %% same BC
growthr=sprdBC./sprdBC_ini;
  pmin=double(min(min(growthr)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,growthr,L2,'linestyle','none'); hold on      % 
  %
  % m_coast('color','k');
  % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
  m_usercoast('gumby','linewidth',1,'color',[0.9 0.9 0.9],'linestyle','--')
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
  % 
  % ens mean
  [c,hdis]=m_contour(lon,lat,squeeze(mean(pmsl0(:,:,ti,:),4)),plotcnt,'color',cntcol,'linewidth',1.8);     
  clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500,'color',cntcol) 
  
 m_contour(lon,lat,sprdBC_ini,5,'color',[1 0 0],'linewidth',1.8,'linestyle','--');
%    clabel(c,hdis,'fontsize',15,'LabelSpacing',500) 

  tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  same BC  (',num2str(pltensize),' mem)']};   
  title(tit,'fontsize',18)
  %
%---colorbar---
  fi=find(L>pmin,1);
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
  colormap(cmap);  drawnow;  
  hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
  for idx = 1 : numel(hFills)
    hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
  end
%
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m',num2str(pltensize),'sameBC'];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end   
   
end %ti
%}
