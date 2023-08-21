clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltensize=1000;  pltime=37;   %staid=2;
randmem=0;
 
varinam='wind';


% xp=453; yp=385; 
xp=486; yp=478; 
% xp=589; yp=280; 
% xp=359; yp=249;

%
expri='Hagibis05kme01';  infilename='201910101800';%hagibis
infiletrackname='201910101800track';
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=['Typhoon center & ',varinam];   fignam=[expri,'_TCentCol',varinam,'_'];  unit='m/s';
%
  lo_int=105:5:155; la_int=10:5:50;
 %
load('colormap/colormap_wind2.mat') 
% cmap_wind=colormap_wind2([1 3 4 5 6 7 8 9 10 11 12 13 14],:); 
% L_wind=[2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30];
cmap=colormap_wind2([1 3 4 6 7 8 9 11 12 14],:); 
if strcmp(varinam,'wind')
%     L=[3 6 9 12 15 18 21 24 27];
      L=[1 3 5  7  9 11 13 15 17];
else
    load('colormap/colormap_vr.mat') 
    cmap=colormap_vr([1:2:8, 9 ,10:2:end],:); 
    cmap(5,:)=[0.7 0.7 0.7];
    L=[-8 -6 -4 -2 2 4 6 8];
end
load('colormap/colormap_ncl.mat'); cmap2=colormap_ncl(8:5:end,:);
BCnum=50;

%% obs
%{
%---obs
% station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi'};
% station.lon=[139.75 139.863 139.78 140.385 140.857];
% station.lat=[35.692 35.638 35.553 35.763 35.738];
% % amdsdata   UTC TIME
% % start 2019/10/10 01:00 ; end 2019/10/13 00:00
% sta=station.name{staid};
% indirobs='/data8/wu_py/Data/obs/';
%   infileo=[indirobs,'amds_',sta,'.txt'];
%   obs=importdata(infileo); 
% lonp= station.lon(staid); latp=station.lat(staid);
%}
%%    
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize);   %!random choose members  
else; member=1:pltensize;  %!!!!! sequential members
end

infile=[indir,'/',num2str(1,'%.4d'),'/',infilename,'.nc']; 
lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
data_time = (ncread(infile,'time'));
[nx, ny]=size(lon);  ntime0=length(data_time); 
%%
for ti=pltime    

lon_track=zeros(pltensize,1);   lat_track=zeros(pltensize,1);  
pmsl_track=zeros(pltensize,1);  rvmax_track=zeros(pltensize,1);  vmax_track=zeros(pltensize,1);
vari0=zeros(nx,ny,pltensize);
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
 
  if strcmp(varinam,'wind')
    u10 = ncread(infile,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
    v10 = ncread(infile,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
    vari0(:,:,imem)=double(u10.^2+v10.^2).^0.5; 
  else
    vari0(:,:,imem) = ncread(infile,varinam);
  end
    
  infile_track= [indir,'/',num2str(member(imem),'%.4d'),'/',infiletrackname,'.nc'];
   lon_track(imem) = ncread(infile_track,'lon',ti,1,1);
   lat_track(imem) = ncread(infile_track,'lat',ti,1,1);
   pmsl_track(imem) = ncread(infile_track,'pmsl',ti,1,1);
   rvmax_track(imem) = ncread(infile_track,'rvmax',ti,1,1);
   vmax_track(imem) = ncread(infile_track,'vmax',ti,1,1);

end  %imem
%%
plon1=min(min(lon_track),lon(xp,yp))-2.5;
plon2=max(max(lon_track),lon(xp,yp))+2.5;
plat1=min(min(lat_track),lat(xp,yp))-2;
plat2=max(max(lat_track),lat(xp,yp))+2;

plon=[plon1 plon2]; plat=[plat1 plat2];
% plon=[125 144]; plat=[30 40]; 

  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  vari_p=squeeze(vari0(xp,yp,:)); %---wind speed at the grid point
  
  intv=max(vari_p)-min(vari_p);
  L0=floor(min(vari_p)):intv/8:ceil(max(vari_p));
  L=L0(1:length(cmap)-1);
%% 2-d
%{
 %---plot  
    hf=figure('Position',[2500 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    %
    hpp=plot_point(vari_p,lon_track,lat_track,cmap,L,5);
hold on 
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.2 0.2 0.2],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    %---station x
    m_plot(lon(xp,yp),lat(xp,yp),'+','Markersize',15,'linewidth',3.5,'color','r')

    tit={[titnam,'  ',datestr(pltdate,'mm/dd HHMM')];[expri,'  (',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)
    %
    %---colorbar---
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  

    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
%}
    %---
%% lon-wind
%{
  hf=figure('Position',[2500 100 800 680]);
  for ibc=1:BCnum
    plot(lon_track(ibc:BCnum:end),vari_p(ibc:BCnum:end),'.','color',cmap2(ibc,:),'Markersize',10); hold on
    for imem=ibc:BCnum:pltensize
      text(lon_track(imem),vari_p(imem),num2str(ibc),'color',cmap2(ibc,:),'fontsize',10); hold on
    end
  end    
    
  xlabel('Lontitude'); ylabel([varinam,' (m/s)'])
  set(gca,'fontsize',18,'linewidth',1.4,'xlim',[min(lon_track) max(lon_track)],'ylim',[min(vari_p) max(vari_p)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={['Lon. of typhoon and ',varinam,' at (',s_lon,', ',s_lat,')'];['  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',expri,'_TClon',varinam,'_',datestr(pltdate,'mmdd_HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}
%% lat-wind
%{
  hf=figure('Position',[2500 100 800 680]);
  for ibc=1:BCnum
    plot(vari_p(ibc:BCnum:end),lat_track(ibc:BCnum:end),'.','color',cmap2(ibc,:),'Markersize',10); hold on
    for imem=ibc:BCnum:pltensize
      text(vari_p(imem),lat_track(imem),num2str(ibc),'color',cmap2(ibc,:),'fontsize',10); hold on
    end
  end
  %
  xlabel([varinam,' (m/s)']); ylabel('Latitude')
  set(gca,'fontsize',18,'linewidth',1.4,'xlim',[min(vari_p) max(vari_p)],'ylim',[min(lat_track) max(lat_track)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={['Lat. of typhoon and ',varinam,' at (',s_lon,', ',s_lat,')'];['  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',expri,'_','TClat',varinam,'_',datestr(pltdate,'mmdd_HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
    %}
%% pmsl-wind
%
  hf=figure('Position',[2500 100 800 680]);
  for ibc=1:BCnum
    plot(pmsl_track(ibc:BCnum:end),vari_p(ibc:BCnum:end),'.','color',cmap2(ibc,:),'Markersize',10); hold on
    for imem=ibc:BCnum:pltensize
      text(pmsl_track(imem),vari_p(imem),num2str(ibc),'color',cmap2(ibc,:),'fontsize',10); hold on
    end
  end
  %
  xlabel('Central pressure'); ylabel([varinam,' (m/s)'])
  set(gca,'fontsize',18,'linewidth',1.4,'xlim',[min(pmsl_track) max(pmsl_track)],'ylim',[min(vari_p) max(vari_p)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={['Cental SLP of typhoon and ',varinam,' at (',s_lon,', ',s_lat,')'];['  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',expri,'_','TCpmsl',varinam,'_',datestr(pltdate,'mmdd_HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
     %}
     
%% rvmax
%{
  hf=figure('Position',[2500 100 800 680]);
  for ibc=1:BCnum
    plot(rvmax_track(ibc:BCnum:end),vari_p(ibc:BCnum:end),'.','color',cmap2(ibc,:),'Markersize',10); hold on
    for imem=ibc:BCnum:pltensize
      text(rvmax_track(imem),vari_p(imem),num2str(ibc),'color',cmap2(ibc,:),'fontsize',10); hold on
    end
  end
  %
  xlabel('Radius of max. wind (km)'); ylabel([varinam,' (m/s)'])
  set(gca,'fontsize',18,'linewidth',1.4,'xlim',[min(rvmax_track) max(rvmax_track)],'ylim',[min(vari_p) max(vari_p)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={['Max. wind radius of typhoon and ',varinam,' at (',s_lon,', ',s_lat,')'];['  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',expri,'_','TCrvmax',varinam,'_',datestr(pltdate,'mmdd_HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}
%% vmax
%{
  hf=figure('Position',[2500 100 800 680]);
  for ibc=1:BCnum
    plot(vmax_track(ibc:BCnum:end),vari_p(ibc:BCnum:end),'.','color',cmap2(ibc,:),'Markersize',10); hold on
    for imem=ibc:BCnum:pltensize
      text(vmax_track(imem),vari_p(imem),num2str(ibc),'color',cmap2(ibc,:),'fontsize',10); hold on
    end
  end
  %
  xlabel('Max. wind  (m/s)'); ylabel([varinam,' (m/s)'])
  set(gca,'fontsize',18,'linewidth',1.4,'xlim',[min(vmax_track) max(vmax_track)],'ylim',[min(vari_p) max(vari_p)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={['Max. wind of typhoon and ',varinam,' at (',s_lon,', ',s_lat,')'];['  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',expri,'_','TCvmax',varinam,'_',datestr(pltdate,'mmdd_HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}
end % pltime
