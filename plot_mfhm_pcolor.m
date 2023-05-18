clear 
close all
addpath('/data8/wu_py/MATLAB/m_map/')

expnam='Hagibis01kme02';
% expnam='e02nh01K';

saveid=1;

outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end


infile=['/obs262_data01/wu_py/Experiments/',expnam,'/mfhm2.nc'];
lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
land = double(ncread(infile,'landsea_mask'));
terr = double(ncread(infile,'terrain'));
terr(terr+1==1)=NaN;
rough = double(ncread(infile,'roughness'));

%
% plon=[131 145 ]; plat=[27 40.5];
% plon=[137 141.5]; plat=[33.5 38]; % Japan portrait
%%
%---
% plon=[138.5 141]; plat=[34 36.5];  fignam=[expnam,'_terr_Kanto_p'];
plon=[139.2 140.9]; plat=[34.85 36.3 ];  fignam=[expnam,'_terr_tokyobay']; 

titnam=[expnam,'  Terrain'];  

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
m_pcolor(lon,lat,terr,'linestyle','none');  hold on

% colormap(cmap);
hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',13)
% caxis([0 2500]);  set(hc,'ytick',0:400:2600,'yticklabel',0:400:2600)
caxis([0 1000]); set(hc,'ytick',0:200:2600,'yticklabel',0:200:2600) % tokyobay
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3]);

title(titnam,'fontsize',18)
outfile=[outdir,'/',fignam];
if saveid~=0
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%%
% plon=[138.5 141]; plat=[34 36.5];  fignam=[expnam,'_land_Kanto_p'];
plon=[139.2 140.9]; plat=[34.85 36.3 ];  fignam=[expnam,'_land_tokyobay'];

land(land+1==1)=0;
land(land+1==2)=1;
titnam=[expnam,'  land-sea ratio'];  

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
m_pcolor(lon,lat,land,'linestyle','none');  hold on
% colormap(cmap);
hc=colorbar('fontsize',13,'linewidth',1.2); 
caxis([0 1]); 
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3],'xtick',137:142,'ytick',33:38);

m_contour(lon,lat,land,[1e-5 1e-5],'color',[0.9 0.9 0.9],'linewidth',0.8)

title(titnam,'fontsize',18)
outfile=[outdir,'/',fignam];
if saveid~=0
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

%%
% plon=[138.5 141]; plat=[34 36.5];  fignam=[expnam,'_rough_Kanto_p'];
plon=[139.2 140.9]; plat=[34.85 36.3 ];  fignam=[expnam,'_rough_tokyobay']; 

titnam=[expnam,'  Roughness'];  

hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
m_pcolor(lon,lat,rough,'linestyle','none');  hold on

% colormap(cmap);
hc=colorbar('fontsize',13,'linewidth',1.2); title(hc,'m','fontsize',13)
caxis([0 3]); 
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'color',[0.3 0.3 0.3]);

title(titnam,'fontsize',18)
outfile=[outdir,'/',fignam];
if saveid~=0
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
