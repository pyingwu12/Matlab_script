
clear 
close all
addpath('/data8/wu_py/MATLAB/m_map/')

outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end


unit='m';

load('colormap/colormap_br2.mat') 
cmap0=colormap_br2;  cmap=cmap0(3:2:end-1,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-15 -10 -5 -1 1 5 10 15]*10;

filenam1='Hagibis01kme05';
infile1=['/obs262_data01/wu_py/Experiments/',filenam1,'/mfhm.nc'];
lon1 = double(ncread(infile1,'lon'));
lat1 = double(ncread(infile1,'lat'));
land1 = double(ncread(infile1,'landsea_mask'));
terr1 = double(ncread(infile1,'terrain'));
% terr1(terr1+1==1)=NaN;


filenam2='Hagibis01kme06';
infile2=['/obs262_data01/wu_py/Experiments/',filenam2,'/mfhm.nc'];
lon2 = double(ncread(infile2,'lon'));
lat2 = double(ncread(infile2,'lat'));
land2 = double(ncread(infile2,'landsea_mask'));
terr2 = double(ncread(infile2,'terrain'));
% terr2(terr2+1==1)=NaN;

% plon=[136 142.5]; plat=[33 38]; 
% plon=[131 145 ]; plat=[27 40.5];

%%
plon=[139.2 140.9]; plat=[34.85 36.3 ];  pltdomtxt='tokyobay'; 
% plon=[136 142.5]; plat=[33 38];  pltdomtxt='wideKando'; 

    plotvar=terr1-terr2;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
plotvar(plotvar+1==1)=NaN;

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

m_pcolor(lon1,lat2,plotvar);  hold on

m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3]);
% 
hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,unit,'fontsize',13)
% caxis([-200 200]); 
caxis([-50 50]); 

title([filenam1(12:14),' - ',filenam2(12:14),'  Terrain difference'],'fontsize',18)
outfile=[outdir,'/',filenam1,'_',filenam2,'_terrain_diff_pcolor_',pltdomtxt];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

%%
    plotvar=land1-land2;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
plotvar(plotvar+1==1)=NaN;

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

hp=m_pcolor(lon1,lat2,plotvar);  hold on

colorbar('fontsize',13,'linewidth',1.2); 
caxis([-1 1])

m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3]);
% 

title({[filenam1,' - ',filenam2];'Land difference'},'fontsize',18)
outfile=[outdir,'/',filenam1,'_',filenam2,'_land_diff_pcolor_',pltdomtxt];
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);

