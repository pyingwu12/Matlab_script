clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltime=43; lev=0;
%member=randi([1 1000],1,1);
member=0;

indir='/home/wu_py/plot_5kmEns/201910101800/';
outdir='/data8/wu_py/Result_fig/Hagibis_5km';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
fignam='WindSpd2D'; 

xp1=556; yp1=325;
xp2=557; yp2=330;

for mem=member
infile= [indir,num2str(mem,'%.4d'),'/201910101800.nc'];
%---read---
data_time = (ncread(infile,'time'));
lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
if lev==0
u10 = ncread(infile,'u10m');
v10 = ncread(infile,'v10m');
spd=double(u10(:,:,pltime).^2+v10(:,:,pltime).^2).^0.5;
else
u = ncread(infile,'u');
v = ncread(infile,'v');
spd=double(u(:,:,lev,pltime).^2+v(:,:,lev,pltime).^2).^0.5;

end
%---

% 
pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));

%---
infile_track= [indir,num2str(mem,'%.4d'),'/201910101800track.nc'];
lon_track = double(ncread(infile_track,'lon'));
lat_track = double(ncread(infile_track,'lat'));


%---plot
%%
hf=figure('Position',[100 100 800 630]);
%
%  plon=[135 145]; plat=[31 39];
 plon=[lon_track(pltime)-5 lon_track(pltime)+5]; plat=[lat_track(pltime)-4 lat_track(pltime)+4]; 
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
% [~, hp]=m_contourf(lon,lat,squeeze(spd(:,:,pltime)),20,'linestyle','none'); 
[~, hp]=m_contourf(lon,lat,spd,20,'linestyle','none'); 
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

hold on
m_plot(lon_track,lat_track,'color','k','Linewidth',2)
m_plot(lon_track(pltime),lat_track(pltime),'^','color','k','Markerfacecolor','k','MarkerSize',10)

m_plot(lon(xp1,yp1),lat(xp1,yp1),'rx','MarkerSize',15,'linew',2)
m_plot(lon(xp2,yp2),lat(xp2,yp2),'rx','MarkerSize',15,'linew',2)

% m_plot(lon(:,1),lat(:,1),'k')
% m_plot(lon(1,:),lat(1,:),'k')
% m_plot(lon(:,end),lat(:,end),'k')
% m_plot(lon(end,:),lat(end,:),'k')

title(['Wind speed (mem ',num2str(mem,'%.4d'),', lev',num2str(lev),')'],'fontsize',18)


    outfile=[outdir,'/',fignam,'_t',num2str(pltime),'_m',num2str(mem),'_lev',num2str(lev)]; 
    if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
end