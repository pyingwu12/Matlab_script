close all
clear 
addpath('/data8/wu_py/MATLAB/m_map/')

outdir='/data8/wu_py/Result_fig';

% infile='/data8/wu_py/NHM_LETKF/nhm/const/mfhm.nc';
infile='/obs262_data01/wu_py/Experiments/Hagibis01km1000/const/mfhm.nc';


lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
terr = double(ncread(infile,'terrain'));
terr(terr+1==1)=NaN;

plon=[min(lon(:)) max(lon(:))]; plat=[min(lat(:)) max(lat(:))];



load('colormap/colormap_tern.mat') 
cmap=colormap_tern; 


%%
hf=figure('Position',[100 100 800 630]);
%

m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
[~, hp]=m_contourf(lon,lat,terr,0:250:2500,'linestyle','none');  hold on
m_usercoast('gumby','linewidth',1,'color','k')
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:2:150,'ytick',26:2:50,'fontsize',13); 



colormap(cmap)
hc=colorbar('fontsize',13);
caxis([0 2500])
set(hc,'ytick',500:500:2000,'yticklabel',500:500:2000)
title(hc,'m','fontsize',13)

m_plot(lon(:,1),lat(:,1),'r');m_plot(lon(1,:),lat(1,:),'r')
m_plot(lon(:,end),lat(:,end),'r');m_plot(lon(end,:),lat(end,:),'r')

title('Terrain 1-km domain','fontsize',18)

fignam='Hagibis01km-domai02n';
saveid=1;
outfile=[outdir,'/',fignam]; 
if saveid~=0
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end