clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')


pltime=43; lev=1;
% member=randi([1 1000],1,1);
member=5;
indir='/data8/leduc/nhm/exp/Fugaku05km/forecast/Fugaku05km06/201910101800';
% indir='/home/wu_py/plot_5kmEns/201910101800';
% indir='/obs262_data01/wu_py/Experiments/Hagibis01km1000';

date_time='201910121200';
%%
for mem=member
     infile= [indir,'/',num2str(mem,'%.4d'),'/201910101800.nc'];
% infile= [indir,'/',num2str(mem,'%.4d'),'/',date_time,'.nc'];
%---read---
% data_time = (ncread(infile,'time'));
lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
u10 = ncread(infile,'u10m');
v10 = ncread(infile,'v10m');
% u = ncread(infile,'u');
% v = ncread(infile,'v');
% ps = ncread(infile,'ps');
pmsl = ncread(infile,'pmsl');
%---
spd10=double((u10.^2+v10.^2).^0.5);
% spd=double(u(:,:,lev,pltime).^2+v(:,:,lev,pltime).^2).^0.5;

% pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
pltdate = datetime('2019-10-12 12:00','InputFormat','yyyy-MM-dd HH:mm');

%---
% infile_track= [indir,num2str(mem,'%.4d'),'/201910101800track.nc'];
% lon_track = ncread(infile_track,'lon');
% lat_track = ncread(infile_track,'lat');

%---
infile_mfhm='/obs262_data01/wu_py/Experiments/Hagibis01km1000/const/mfhm.nc';
lon_mfhm = double(ncread(infile_mfhm,'lon'));
lat_mfhm = double(ncread(infile_mfhm,'lat'));
% terr = double(ncread(infile,'terrain'));
% terr(terr+1==1)=NaN;



% plon=[min(lon(:)) max(lon(:))]; plat=[min(lat(:)) max(lat(:))];


%---plot

spd_lt=zeros(size(spd10));
spd_lt(spd10>15)=1;

%%
figure('Position',[100 100 800 630])
%
%  plon=[135 145]; plat=[31 39];
%   plon=[130 145]; plat=[24 43];
  plon=[135 143]; plat=[32 38];
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
% [~, hp]=m_contourf(lon,lat,squeeze(spd(:,:,pltime)),20,'linestyle','none'); 
[~, hp]=m_contourf(lon,lat,spd10,20,'linestyle','none');  hold on
% [~, hp]=m_contourf(lon,lat,pmsl(:,:,pltime),20,'linestyle','none'); 
% [~, hp]=m_contour(lon,lat,pmsl(:,:,pltime),[1015 1015],'color','b','linewidth',1.5); 

% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
 m_usercoast('gumby','linewidth',0.8,'color','k')

m_text(plon(1)+0.25,plat(1)+0.3,['Valid: ',datestr(pltdate)],'color','k','fontsize',15)
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
% m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50); 

colorbar('fontsize',13)
% caxis([0 35])


% hold on
% m_plot(lon_track,lat_track,'color','k','Linewidth',2)
% m_plot(lon_track(pltime),lat_track(pltime),'^','color','k','Markerfacecolor','k','MarkerSize',10)
% m_plot(lon_track(49),lat_track(49),'^','color','k','Markerfacecolor','k','MarkerSize',10)
% m_plot(lon_track(43),lat_track(43),'^','color','k','Markerfacecolor','k','MarkerSize',10)


% m_plot(lon(:,1),lat(:,1),'k')
% m_plot(lon(1,:),lat(1,:),'k')
% m_plot(lon(:,end),lat(:,end),'k')
% m_plot(lon(end,:),lat(end,:),'k')

% m_plot(lon_mfhm(:,1),lat_mfhm(:,1),'r','linew',1.8);m_plot(lon_mfhm(1,:),lat_mfhm(1,:),'r','linew',1.8)
% m_plot(lon_mfhm(:,end),lat_mfhm(:,end),'r','linew',1.8);m_plot(lon_mfhm(end,:),lat_mfhm(end,:),'r','linew',1.8)


title(['Wind speed (mem ',num2str(mem,'%.4d'),')'],'fontsize',18)
end