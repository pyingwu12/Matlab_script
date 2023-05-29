close all
clear 
addpath('/data8/wu_py/MATLAB/m_map/')

outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end

load('colormap/colormap_tern.mat') 
cmap=colormap_tern;

%% quick test
%
% filenam='Hagibis200m_terrain_F';
% infile='/home/wu_py/nhm/exp/Hagibis200m/const/mfhm.nc';
%  infile='/data2/wu_py/Tools/Out/mfhm2_RISTrev1.nc';  expri='test_RISTrev1';
expri='Nagasaki02km';
infile=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc'];
% expri='e02nh01K';% expri='Hagibis01kme06';
% infile=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm2.nc'];
lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
land = double(ncread(infile,'landsea_mask'));
terr = double(ncread(infile,'terrain'));
terr(terr+1<=1.05)=NaN;
% rough = double(ncread(infile,'roughness'));
%%
% plon=[136 142.5]; plat=[33 38]; 
% plon=[131 145 ]; plat=[27 40.5];
% plon=[132 145 ]; plat=[28 40.5]; lo_int=130:2:148;  la_int=29:2:49; domtxt='1kmC'; % 1km domain center
% plon=[119.6 137.4]; plat=[27.1 36.9];   lo_int=105:10:155; la_int=15:10:50;  domtxt='N02';  %Oizumi-Nagasaki 02km whole domain center
% plon=[120 139.5]; plat=[23 38];   lo_int=105:10:155; la_int=15:10:50; domtxt='K02km'; %Kyushu02km whole domain center
plon=[112 153]; plat=[18 50];  lo_int=105:15:155; la_int=10:15:50;  domtxt='Fugaku05km'; %Fugaku05km whole domain center


hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
m_contourf(lon,lat,terr,0:250:2500,'linestyle','none');  hold on

m_contour(lon,lat,land,[0.2 0.2],'linewidth',1,'color','k')

colormap(cmap); hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',13)
caxis([0 2500]); set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)
% set(hc,'position',[0.85 0.160 0.02 0.7350]);

m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.1 0.1 0.1],'xtick',lo_int,'ytick',la_int);

m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');
m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')

% m_plot(lon2(:,1),lat2(:,1),'color',[0.4 0.4 0.4],'linewidth',1.2,'linestyle','-');
% m_plot(lon2(1,:),lat2(1,:),'color',[0.4 0.4 0.4],'linewidth',1.2,'linestyle','-');
% m_plot(lon2(:,end),lat2(:,end),'color',[0.4 0.4 0.4],'linewidth',1.2,'linestyle','-');
% m_plot(lon2(end,:),lat2(end,:),'color',[0.4 0.4 0.4],'linewidth',1.2,'linestyle','-')


title([expri,' Terrain'],'fontsize',18)
outfile=[outdir,'/',expri,'_',domtxt,'_terr'];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}

%%
%{
%---1km
infile1='/obs262_data01/wu_py/Experiments/Hagibis01kme02/mfhm.nc';
lon1 = double(ncread(infile1,'lon'));
lat1 = double(ncread(infile1,'lat'));
land1 = double(ncread(infile1,'landsea_mask'));
terr1 = double(ncread(infile1,'terrain'));
terr1(terr1+1==1)=NaN;

%---5km
infile5='/obs262_data01/wu_py/Experiments/Hagibis05kme02/mfhm.nc';
lon5 = double(ncread(infile5,'lon'));
lat5 = double(ncread(infile5,'lat'));
land5 = double(ncread(infile5,'landsea_mask'));
terr5 = double(ncread(infile5,'terrain'));
terr5(terr5+1==1)=NaN;

% load('colormap/colormap_tern.mat') 
% cmap=colormap_tern; 

%%
close all
% plon=[134.5 143.5]; plat=[32 38.5]; 
% plon=[111.6 154 ]; plat=[18 49.5]; % <---- Fugaku05km domain center
plon=[110.6 155 ]; plat=[17 50.5]; % <---- Fugaku05km domain center

hf=figure('Position',[100 100 800 630]);

m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

m_contourf(lon5,lat5,terr5,0:250:2500,'linestyle','none');  hold on
colormap(cmap); hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',14)
caxis([0 2500]); set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)

% m_contour(lon5,lat5,land5,[0.1 0.1],'color','k','linewidth',0.8);  hold on

m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'color',[0.3 0.3 0.3],...
    'xtick',110:15:150,'ytick',5:15:50); 
% m_usercoast('gumby','linewidth',3,'color','k'); hold on
%
boadercol='k';
m_plot(lon5(:,1),lat5(:,1),boadercol,'linewidth',1.5);
m_plot(lon5(1,:),lat5(1,:),boadercol,'linewidth',1.5)
m_plot(lon5(:,end),lat5(:,end),boadercol,'linewidth',1.5);
m_plot(lon5(end,:),lat5(end,:),boadercol,'linewidth',1.5)

m_contourf(lon1,lat1,terr1,0:250:2500,'linestyle','none');  hold on

m_plot(lon1(:,1),lat1(:,1),boadercol,'linewidth',1.5);
m_plot(lon1(1,:),lat1(1,:),boadercol,'linewidth',1.5)
m_plot(lon1(:,end),lat1(:,end),boadercol,'linewidth',1.5);
m_plot(lon1(end,:),lat1(end,:),boadercol,'linewidth',1.5)

title('5&1 domain','fontsize',18)
outfile=[outdir,'/Hagibis0501km_terrain'];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
%%
%{
% plon=[134.5 143.5]; plat=[32 38.5]; 
% 
% hf=figure('Position',[100 100 800 630]);
% 
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

m_contourf(lon1,lat1,terr1,0:250:2500,'linestyle','none');  hold on
% colormap(cmap); hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',13)
% caxis([0 2500]); set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)

m_contour(lon1,lat1,land1,[0.4 0.4],'color','k','linewidth',1.5);  hold on

m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3]); 
% m_usercoast('gumby','linewidth',3,'color','k'); hold on

title('Terrain 1-km','fontsize',18)
outfile=[outdir,'/Hagibis01km05km_terrain'];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);


%%
fignam='Hagibis05km';

% plon=[min(lon5(:))+4 max(lon5(:))]; plat=[min(lat5(:)) max(lat5(:))];

plon=[134.5 143.5]; plat=[32 38.5]; fignam=[fignam,'3_']; 
close all

hf=figure('Position',[100 100 800 630]);
%
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
[~, hp]=m_contourf(lon5,lat5,terr5,0:250:2500,'linestyle','none');  hold on

m_contour(lon5,lat5,land5,[0.9 0.9],'color','k','linewidth',1.5)

% m_contourf(lon1,lat1,terr1,0:250:2500,'linestyle','none'); 
% % m_usercoast('gumby','linewidth',1,'color','k')
% %  m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8,'linestyle','--');
% %  m_contour(lon,lat,terr,[0 0],'color','k')
% % m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:2:150,'ytick',26:2:50,'fontsize',13); 
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3]); 

colormap(cmap)
hc=colorbar('fontsize',13,'linewidth',1.2);
caxis([0 2500])
set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)
title(hc,'m','fontsize',13)

% boadercol='k';
% m_plot(lon5(:,1),lat5(:,1),boadercol,'linewidth',2);
% m_plot(lon5(1,:),lat5(1,:),boadercol,'linewidth',2)
% m_plot(lon5(:,end),lat5(:,end),boadercol,'linewidth',2);
% m_plot(lon5(end,:),lat5(end,:),boadercol,'linewidth',2)
% 

% saveid=1;
% outfile=[outdir,'/',fignam]; 
% if saveid~=0
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
% end
%}
