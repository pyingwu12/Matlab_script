% clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;  pltime=[47 48];   staid=2;
 
%
expnam='Hagibis05kme02';  infilename='201910101800';%hagibis
infiletrackname='201910101800track';
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';

titnam='Typhoon center & Wind speed';   fignam=[expnam,'_tcent-colspd_'];  unit='m/s';
%
% plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37];% fignam=[fignam,'2_']; 
    plon=[134.5 143.5]; plat=[32 38.5];
%
load('colormap/colormap_wind2.mat') 
% cmap_wind=colormap_wind2([1 3 4 5 6 7 8 9 10 11 12 13 14],:); 
% L_wind=[2.5 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30];
cmap_wind=colormap_wind2([1 3 4 6 7 8 9 11 12 14],:); 
L_wind=[3 6 9 12 15 18 21 24 27];

%%
%---obs
station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi'};
station.lon=[139.75 139.863 139.78 140.385 140.857];
station.lat=[35.692 35.638 35.553 35.763 35.738];
% amdsdata   UTC TIME
% start 2019/10/10 01:00 ; end 2019/10/13 00:00
sta=station.name{staid};
indirobs='/data8/wu_py/Data/obs/';
  infileo=[indirobs,'amds_',sta,'.txt'];
  obs=importdata(infileo); 
lonp= station.lon(staid); latp=station.lat(staid);

%%    
%---read ensemble
% tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members 
member=1:pltensize;
%%
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
%     lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
%     [nx, ny]=size(lon);      
%     data_time = (ncread(infile,'time'));
%     spd10_ens=zeros(nx,ny,pltensize,length(data_time));  
    %--find the grid point nearest to the obs station
%     dis_sta=(lon-lonp).^2+(lat-latp).^2;   [xp,yp]=find(dis_sta==min(dis_sta(:))); %!!!!!
    lon_track=zeros(length(data_time),pltensize);
    lat_track=zeros(length(data_time),pltensize);
  end  
%   u10 = ncread(infile,'u10m');    v10 = ncread(infile,'v10m');
%   spd10_ens(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
  
  infile_track= [indir,'/',num2str(member(imem),'%.4d'),'/',infiletrackname,'.nc'];
    len_track=length(ncread(infile_track,'lon'));
  if len_track~=length(data_time)
      lon_track(1:len_track,imem) = ncread(infile_track,'lon');
      lon_track(len_track+1:end,imem) =NaN;
      lat_track(1:len_track,imem) = ncread(infile_track,'lat');
      lat_track(len_track+1:end,imem) =NaN;
  else
   lon_track(:,imem) = ncread(infile_track,'lon');
   lat_track(:,imem) = ncread(infile_track,'lat');
  end
end  %imem
%%
titnam='Typhoon center & Wind speed';   fignam=[expnam,'_tcent-colspd_'];  unit='m/s';
plon=[137.5 142.8]; plat=[34.5 38];  lo_int=136:2:144; la_int=33:2:37; 
for ti=pltime
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  spd_sta=squeeze(spd10_ens(xp,yp,:,ti)); %---wind speed at the station

 %---plot  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    %
    hpp=plot_point(spd_sta,lon_track(ti,:),lat_track(ti,:),cmap_wind,L_wind,15);
hold on 
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.2 0.2 0.2],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
    %---station x
    m_plot(lon(xp,yp),lat(xp,yp),'+','Markersize',15,'linewidth',3.5,'color','r')

    tit={[titnam,'  ',datestr(pltdate,'mm/dd HHMM')];[expnam,'  (',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)
    %
    %---colorbar---
    L1=((1:length(L_wind))*(diff(caxis)/(length(L_wind)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L_wind,'fontsize',15,'LineWidth',1.5);
    colormap(cmap_wind); title(hc,unit,'fontsize',15);  drawnow;  

    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---

end % pltime
