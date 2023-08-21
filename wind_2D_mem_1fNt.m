clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

members=[29 30];
expri='Hagibis05kme01';  infilename='201910101800';%hagibis
pltime=37; lev=4;


indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
fignam='WindSpd2D'; 

% plon=[130 144]; plat=[30 45];   lo_int=105:5:155; la_int=10:5:50;
 plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center

  xp1=486; yp1=478;
% xp1=556; yp1=325;
% xp2=557; yp2=330;

%%
infile=[indir,'/',num2str(members(1),'%.4d'),'/',infilename,'.nc']; 
data_time = (ncread(infile,'time')); lon = double(ncread(infile,'lon')); lat = double(ncread(infile,'lat'));

for imem=members
infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc']; 
%---read---

for ti=pltime
  if lev==0
  u10 = ncread(infile,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
  v10 = ncread(infile,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
  spd=double(u10.^2+v10.^2).^0.5;
  else
  u = ncread(infile,'u',[1 1 lev ti],[Inf Inf 1 1],[1 1 1 1]);
  v = ncread(infile,'v',[1 1 lev ti],[Inf Inf 1 1],[1 1 1 1]);
  spd=double(u.^2+v.^2).^0.5;
  end
%---
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

end %ti
% 

%---
% infile_track= [indir,num2str(imem,'%.4d'),'/201910101800track.nc'];
% lon_track = double(ncread(infile_track,'lon'));
% lat_track = double(ncread(infile_track,'lat'));


%---plot
%%
hf=figure('Position',[2300 100 800 630]);
%
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
% [~, hp]=m_contourf(lon,lat,squeeze(spd(:,:,pltime)),20,'linestyle','none'); 
[~, hp]=m_contourf(lon,lat,spd,20,'linestyle','none'); 
% [~, hp]=m_contourf(lon,lat,pmsl(:,:,pltime),20,'linestyle','none'); 
% [~, hp]=m_contour(lon,lat,pmsl(:,:,pltime),[1015 1015],'color','b','linewidth',1.5); 

% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
 m_usercoast('gumby','linewidth',0.8,'color','k','linestyle','--')

% m_text(plon(1)+0.25,plat(1)+0.3,['Valid: ',datestr(pltdate)],'color','k','fontsize',15)
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
% m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50); 

colorbar('fontsize',13)
% caxis([0 35])

hold on
% m_plot(lon_track,lat_track,'color','k','Linewidth',2)
% m_plot(lon_track(pltime),lat_track(pltime),'^','color','k','Markerfacecolor','k','MarkerSize',10)

m_plot(lon(xp1,yp1),lat(xp1,yp1),'rx','MarkerSize',15,'linew',2)
% m_plot(lon(xp2,yp2),lat(xp2,yp2),'rx','MarkerSize',15,'linew',2)

% m_plot(lon(:,1),lat(:,1),'k')
% m_plot(lon(1,:),lat(1,:),'k')
% m_plot(lon(:,end),lat(:,end),'k')
% m_plot(lon(end,:),lat(end,:),'k')

tit={expri;['Wind speed (mem ',num2str(imem,'%.4d'),', lev',num2str(lev),')']};
title(tit,'fontsize',18)

    outfile=[outdir,'/',fignam,'_t',num2str(pltime),'_m',num2str(imem),'_lev',num2str(lev)]; 
    if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
end