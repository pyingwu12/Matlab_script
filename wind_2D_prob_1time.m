% function wind_prob(pltime,memsize,thrd)

clear
close all
% addpath('/data8/wu_py/MATLAB/m_map/')

pltime=43;  memsize=999;  thrd=[20 25 30 35];

tmp=randperm(1000);
member=tmp(1:memsize);

indir='/home/wu_py/plot_5kmEns/201910101800/';
outdir='/data8/wu_py/Result_fig/Hagibis_5km';

nmem=0;
for mem=member
  nmem=nmem+1;
  infile= [indir,num2str(mem,'%.4d'),'/201910101800.nc'];
  
  if nmem==1
    data_time = (ncread(infile,'time'));
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);
    spd10_ens=zeros(nx,ny,memsize);
  end
  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd10_ens(:,:,nmem)=double(u10(:,:,pltime).^2+v10(:,:,pltime).^2).^0.5;
  
%   u = ncread(infile,'u');
%   v = ncread(infile,'v');
%   spd_ens(:,:,nmem)=double(u(:,:,lev,pltt).^2+v(:,:,lev,pltt).^2).^0.5;
end

%%
load('colormap/colormap_PQPF.mat') 
cmap=colormap_PQPF; cmap(1,:)=[0.95 0.95 0.95];
fignam='wind-prob';
pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
%%
for thi=thrd
    
wind_threshold=thi;

wind_pro=zeros(nx,ny);   
for i=1:nx
  for j=1:ny
    wind_pro(i,j)=length(find(spd10_ens(i,j,:)>=wind_threshold));
  end
end
wind_pro=wind_pro/memsize*100;
% wind_pro(wind_pro+1==1)=NaN;
%
%---plot
hf=figure('Position',[100 100 800 630]);
%
m_proj('Lambert','lon',[135 145],'lat',[31 39],'clongitude',140,'parallels',[30 60],'rectbox','on')
% % [~, hp]=m_contourf(lon,lat,squeeze(spd(:,:,pltt)),20,'linestyle','none'); 
[~, hp]=m_contourf(lon,lat,wind_pro,0:10:100,'linestyle','none'); 
% 
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
 m_usercoast('gumby','linewidth',1,'color','k')
% 
m_text(135.2,31.5,{['Threshold: ',num2str(thi),' m/s'],['Valid: ',datestr(pltdate)]},'color','k','fontsize',14)
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50,'fontsize',13); 
% 
% 
colormap(cmap)
hc=colorbar('fontsize',13);
caxis([0 100])
title(hc,'%','fontsize',13)
% 
title(['10-m wind speed probability (',num2str(memsize),' mem)'],'fontsize',16)

outfile=[outdir,'/',fignam,'_t',num2str(pltime),'m',num2str(memsize),'thrd',num2str(thi)];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

end %thi

%%
%---plot ens_mean---
fignam='wind-spd-mean';
hf=figure('Position',[100 100 800 630]);
%
m_proj('Lambert','lon',[135 145],'lat',[31 39],'clongitude',140,'parallels',[30 60],'rectbox','on')
% % [~, hp]=m_contourf(lon,lat,squeeze(spd(:,:,pltt)),20,'linestyle','none'); 
[~, hp]=m_contourf(lon,lat,mean(spd10_ens,3),0:5:100,'linestyle','none'); 
% 
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
 m_usercoast('gumby','linewidth',1,'color','k')
% 
m_text(135.2,31.2,['Valid: ',datestr(pltdate)],'color','k','fontsize',14)
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50,'fontsize',13); 
% 
% 
hc=colorbar('fontsize',13);
caxis([0 35])
title(hc,'m/s','fontsize',13)
% 
title('Wind speed (ensemble mean)','fontsize',16)

outfile=[outdir,'/',fignam,'_t',num2str(pltime),'m',num2str(memsize)];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
