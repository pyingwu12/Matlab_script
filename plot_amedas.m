

% close all
clear

addpath('/data8/wu_py/MATLAB/m_map/')
indir='/data8/wu_py/Data/obs/';


sta_info=amedastation();
nstation=size(sta_info.name,1);
% sta_info=readtable('/data8/wu_py/Data/amedas_info');
% nstation=size(sta_info,1);


for istation=1:nstation  
%  infile=[indir,'amds_',sta_info.NAME_EN{istation},'.txt'];
  infile=[indir,'amds_',sta_info.name{istation},'.txt'];
  if exist(infile, 'file')==0; continue;  end
  wind=importdata(infile);
  wind_dir=wind(:,2);
  wind_speed=wind(:,1);

  figure 
   plot(wind_speed); hold on
   yyaxis right
   plot(wind_dir,'o','color',[0.8 0.8 0]);
   title(sta_info.name{istation})
end

%%
load('colormap/colormap_wind.mat') 
cmap=colormap_wind([3 5 6 9 11 12 13 16],:); 
colL=5:5:35;
%%

pltime=2*24+13;

figure('Position',[100 100 800 630])

plon=[138 142]; plat=[33 37];
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

for istation=1:nstation    
  infile=[indir,'amds_',sta_info.name{istation},'.txt'];
  if exist(infile, 'file')==0; continue;  end
  wind=importdata(infile);
  wind_dir(:,istation)=wind(:,2);
  wind_speed(:,istation)=wind(:,1);
end
m_usercoast('gumby','linewidth',0.8,'color','k')
m_color_point(sta_info.lon, sta_info.lat, wind_speed(pltime,:),cmap,colL,'o',10)
% m_plot(sta_info.lon(istation),sta_info.lat(istation),'^','Markersize',8,'color','r'); hold on
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',135:2:145,'ytick',26:2:40,'fontsize',13);

L1=((1:length(colL))*(diff(caxis)/(length(colL)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',colL,'fontsize',14,'LineWidth',1.3);
colormap(cmap); 
title(hc,'m/s','fontsize',14)  
set(hc,'position',[0.85 0.160 0.02 0.7150]);
    