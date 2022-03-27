clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')


pltime=43; memsize=1000; 
tmp=randperm(1000);
member=tmp(1:memsize);
% member=0;

indir='/home/wu_py/plot_5kmEns/201910101800/';
outdir='/data8/wu_py/Result_fig/Hagibis_5km';



% nmember=size(member);
nmember=memsize;
for imember=1:nmember
  %mem=member(imember);
  mem=imember;
    
  infile= [indir,num2str(mem,'%.4d'),'/201910101800.nc'];
  data_time = (ncread(infile,'time'));
  if mem==1
  pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
  end
  pmsl = ncread(infile,'pmsl');
  ens_pmsl(:,:,imember)=pmsl(:,:,pltime);
  
  %---
  infile_track= [indir,num2str(mem,'%.4d'),'/201910101800track.nc'];
  lon_track(:,imember) = ncread(infile_track,'lon');
  lat_track(:,imember) = ncread(infile_track,'lat');
end

%%

lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
% plon=[min(lon(:))+3 max(lon(:))]; plat=[min(lat(:)) max(lat(:))];


%---plot
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl;
cmap2=cmap(8:5:end,:);
%%
hf=figure('Position',[100 100 1000 750]);
%
% plon=[120 150]; plat=[20 45];
%  plon=[127 150]; plat=[28 44];
 plon=[130 148]; plat=[31 43];

 m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')


m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
% m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50); 
% m_coast('color',[0.6 0.6 0.6],'linewidth',2);
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
m_usercoast('gumby','linewidth',0.8,'color','k')

hold on
% a=randperm(50);
% b=a(1:5)
% b=5:10:50;
b=1:50;
for ibc=b
  for imember=ibc:50:nmember
    %mem=member(imember);
    mem=imember;
    bc_n=mod(mem,50)+1;    
    m_plot(lon_track(:,imember),lat_track(:,imember),'color',cmap2(bc_n,:),'Linewidth',1); hold on
    m_contour(lon,lat,ens_pmsl(:,:,imember),[1015 1015],'color',cmap2(bc_n,:),'Linewidth',1,'linestyle','--'); 
  end
end
for ibc=b
  for imember=ibc:50:nmember
    m_plot(lon_track(pltime,imember),lat_track(pltime,imember),'.k')
  end
end

% box of domain
m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')

% m_text(108.5,11.5,['Valid: ',datestr(pltdate,'dd-mmm-yyyy hh:MM:ss')],'color','k','fontsize',15)
m_text(plon(1)+0.25,plat(1)+0.3,['Valid: ',datestr(pltdate,'dd-mmm-yyyy hh:MM:ss')],'color','k','fontsize',15)
title(['Typhoon tracks and SLP'],'fontsize',18)

outfile=[outdir,'/track_slp_BCcolor','_t',num2str(pltime),'_zoom_allmem'];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);