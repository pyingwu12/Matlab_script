clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

pltime=50; 


ensize=1000;   tmp=randperm(ensize);

pltsize=100;
member=tmp(1:pltsize);
% member=[10:100:510,11:100:512];

indir='/home/wu_py/plot_5kmEns/201910101800/';  outdir='/data8/wu_py/Result_fig/Fugaku_sym220910';
% indir='/obs262_data01/wu_py/Experiments/Hagibis01km1000'; outdir='/data8/wu_py/Result_fig/Hagibis_1km';

%%
for imem=1:pltsize
 
  infile= [indir,num2str(member(imem),'%.4d'),'/201910101800.nc'];
%       infile= [indir,'/',num2str(imem,'%.4d'),'/',datime,'.nc'];

%   pmsl = ncread(infile,'pmsl');
%   ens_pmsl(:,:,imem)=pmsl(:,:);
  
  %---
  infile_track= [indir,num2str(member(imem),'%.4d'),'/201910101800track.nc'];
  lon_track(:,imem) = ncread(infile_track,'lon');
  lat_track(:,imem) = ncread(infile_track,'lat');
end

% pltdate = datetime([datime(1:4),'-',datime(5:6),'-',datime(7:8),' ',datime(9:10),':',datime(11:12)],...
%     'InputFormat','yyyy-MM-dd HH:mm');

%%

lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
% plon=[min(lon(:))+3 max(lon(:))]; plat=[min(lat(:)) max(lat(:))];
% times = (ncread(infile,'time'));

%---plot
plon=[134 144]; plat=[26.8 38];

hf=figure('Position',[100 100 1000 750]);

m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
% m_coast('color',[0.6 0.6 0.6],'linewidth',2);
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
m_usercoast('gumby','linewidth',1.5,'color',[0.4 0.4 0.4])

hold on
for  imem=1:pltsize
m_plot(lon_track(5:pltime,imem),lat_track(5:pltime,imem),'color',[1 0.8 0],'Linewidth',1.5); hold on
end 
for  imem=1:pltsize
m_plot(lon_track(43,imem),lat_track(43,imem),'.','color',[0.7 0.4 0],'Markersize',9); hold on
end 

% m_plot(lon_track(5:end,1),lat_track(5:end,1),'color',[0.2 0.3 0.8],'Linewidth',4); hold on
% m_plot(lon_track(5:end,2),lat_track(5:end,2),'color',[0.2 0.7 0.1],'Linewidth',4); hold on
% m_plot(lon_track(5:10,1),lat_track(5:10,1),'color',[0.2 0.3 0.8],'Linewidth',4); hold on
% m_plot(lon_track(pltime,1),lat_track(pltime,1),'k^','MarkerFaceColor',[0.2 0.3 0.8],'Markersize',12,'linewidth',1.5)
% 
% m_plot(lon_track(5:10,2),lat_track(5:10,2),'color',[0.2 0.7 0.1],'Linewidth',4); hold on  
% m_plot(lon_track(pltime,2),lat_track(pltime,2),'k^','MarkerFaceColor',[0.2 0.7 0.1],'Markersize',12,'linewidth',1.5)
  
outfile=[outdir,'/track_5km_mem',num2str(pltsize),'_t',num2str(pltime)];

% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);

