clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')


pltt=43; lev=1;
member=randi([1 1000],1,3);

indir='/home/wu_py/plot_5kmEns/201910101800/';

for mem=member
infile= [indir,num2str(mem,'%.4d'),'/201910101800.nc'];
%---read---
data_time = (ncread(infile,'time'));
lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
% u10 = ncread(infile,'u10m');
% v10 = ncread(infile,'v10m');
u = ncread(infile,'u');
v = ncread(infile,'v');
%---
% spd10=double(u10.^2+v10.^2);

spd=double(u(:,:,lev,pltt).^2+v(:,:,lev,pltt).^2).^0.5;

% latlim=[min(lat(:)) max(lat(:))];
% lonlim=[min(lon(:)) max(lon(:))];

pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltt));

%---plot
%%
figure('Position',[100 100 800 630])
%
m_proj('Lambert','lon',[135 145],'lat',[31 39],'clongitude',140,'parallels',[30 60],'rectbox','on')
% [~, hp]=m_contourf(lon,lat,squeeze(spd(:,:,pltt)),20,'linestyle','none'); 
[~, hp]=m_contourf(lon,lat,spd,20,'linestyle','none'); 

% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
 m_usercoast('gumby','linewidth',0.8,'color','k')

% m_text(120.5,43.5,['Valid: ',datestr(pltdate)],'color','w','fontsize',15)
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50); 


colorbar('fontsize',13)
caxis([0 35])

title(['Wind speed (mem',num2str(mem),')'],'fontsize',18)
end