%close all
clear 
addpath('/data8/wu_py/MATLAB/m_map/')

outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end

load('colormap/colormap_tern.mat') 
cmap=colormap_tern;

%% quick test
%
% filenam='Hagibis200m_terrain_F';
% infile2='/home/wu_py/nhm/exp/Hagibis200m/const/mfhm.nc';
% infile2='/data2/wu_py/Tools/Out/mfhm.nc';
% filenam='Hagibis01kme06';
filenam='Hagibis05kme02';
infile2=['/obs262_data01/wu_py/Experiments/',filenam,'/mfhm2.nc'];
lon2 = double(ncread(infile2,'lon'));
lat2 = double(ncread(infile2,'lat'));
land2 = double(ncread(infile2,'landsea_mask'));
terr2 = double(ncread(infile2,'terrain'));
terr2(terr2+1==1)=NaN;
rough2 = double(ncread(infile2,'roughness'));
%%
% plon=[136 142.5]; plat=[33 38]; 
plon=[131 145 ]; plat=[27 40.5];


hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
m_contourf(lon2,lat2,terr2,0:250:2500,'linestyle','none');  hold on

m_contour(lon2,lat2,land2,[0.2 0.2],'linewidth',1,'color','k')

colormap(cmap); hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',13)
caxis([0 2500]); set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3]);

m_plot(lon2(:,1),lat2(:,1),'k');m_plot(lon2(1,:),lat2(1,:),'k');
m_plot(lon2(:,end),lat2(:,end),'k');m_plot(lon2(end,:),lat2(end,:),'k')

title([filenam,' Terrain'],'fontsize',18)
outfile=[outdir,'/',filenam];
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}

%%
%---1km
%{
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
plon=[111.6 154 ]; plat=[18 49.5]; % <---- Fugaku05km domain center

hf=figure('Position',[100 100 800 630]);

m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

m_contourf(lon5,lat5,terr5,0:250:2500,'linestyle','none');  hold on
colormap(cmap); hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',13)
caxis([0 2500]); set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)

% m_contour(lon5,lat5,land5,[0.1 0.1],'color','k','linewidth',0.8);  hold on

m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3],...
    'xtick',103:15:150); 
% m_usercoast('gumby','linewidth',3,'color','k'); hold on

boadercol='k';
m_plot(lon5(:,1),lat5(:,1),boadercol,'linewidth',1.5);
m_plot(lon5(1,:),lat5(1,:),boadercol,'linewidth',1.5)
m_plot(lon5(:,end),lat5(:,end),boadercol,'linewidth',1.5);
m_plot(lon5(end,:),lat5(end,:),boadercol,'linewidth',1.5)

% title('Hagibis05km Terrain','fontsize',18)
% outfile=[outdir,'/Hagibis05km_terrain'];
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%%

% plon=[134.5 143.5]; plat=[32 38.5]; 
% 
% hf=figure('Position',[100 100 800 630]);
% 
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

m_contourf(lon1,lat1,terr1,0:250:2500,'linestyle','none');  hold on
colormap(cmap); hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',13)
caxis([0 2500]); set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)

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
m_plot(lon1(:,1),lat1(:,1),boadercol,'linewidth',2);
m_plot(lon1(1,:),lat1(1,:),boadercol,'linewidth',2)
m_plot(lon1(:,end),lat1(:,end),boadercol,'linewidth',2);
m_plot(lon1(end,:),lat1(end,:),boadercol,'linewidth',2)


% saveid=1;
% outfile=[outdir,'/',fignam]; 
% if saveid~=0
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
% end
%}
