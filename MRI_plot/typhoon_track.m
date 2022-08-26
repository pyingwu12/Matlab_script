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
  pltdate = datetime('2019-10-10 18:00','InputFormat','yyyy-MM-dd HH:mm') + minutes(data_time(pltime));
  %---
  infile_track= [indir,num2str(mem,'%.4d'),'/201910101800track.nc'];
  lon_track(:,imember) = ncread(infile_track,'lon');
  lat_track(:,imember) = ncread(infile_track,'lat');
end

lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
plon=[min(lon(:)) max(lon(:))]; plat=[min(lat(:)) max(lat(:))];


%---plot
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl;
cmap2=cmap(8:5:end,:);
%%
hf=figure('Position',[100 100 800 630]);
%
% plon=[120 150]; plat=[20 45];
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

a=randperm(50);
b=a(1:15);
for ibc=b
for imember=ibc:50:nmember
    %mem=member(imember);
    mem=imember;
    bc_n=mod(mem,50)+1;    
    m_plot(lon_track(:,imember),lat_track(:,imember),'color',cmap2(bc_n,:),'Linewidth',1); hold on
end
end
m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
%  m_usercoast('gumby','linewidth',0.8,'color','k')

% m_text(plon(1)+0.25,plat(1)+0.3,['Valid: ',datestr(pltdate)],'color','k','fontsize',15)
% m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50); 
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')



title(['Typhoon tracks (',num2str(imember),' mem)'],'fontsize',18)
