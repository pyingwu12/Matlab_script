clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')


% pltime=43; 
datime='201910121200';


memsize=100; 
tmp=randperm(memsize);
member=tmp(1:memsize);
% member=0;

% indir='/home/wu_py/plot_5kmEns/201910101800/';  outdir='/data8/wu_py/Result_fig/Hagibis_5km';
indir='/obs262_data01/wu_py/Experiments/Hagibis01km1000'; outdir='/data8/wu_py/Result_fig/Hagibis_1km';

%%
% nmember=size(member);
nmember=memsize;
for imem=1:nmember
  %mem=member(imember);
    
%   infile= [indir,num2str(imem,'%.4d'),'/201910101800.nc'];
      infile= [indir,'/',num2str(imem,'%.4d'),'/',datime,'.nc'];

  
%   data_time = (ncread(infile,'time'));

  pmsl = ncread(infile,'pmsl');
  ens_pmsl(:,:,imem)=pmsl(:,:);
  
  %---
%   infile_track= [indir,num2str(imem,'%.4d'),'/201910101800track.nc'];
%   lon_track(:,imem) = ncread(infile_track,'lon');
%   lat_track(:,imem) = ncread(infile_track,'lat');
end

pltdate = datetime([datime(1:4),'-',datime(5:6),'-',datime(7:8),' ',datime(9:10),':',datime(11:12)],...
    'InputFormat','yyyy-MM-dd HH:mm');

%%

lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));
% plon=[min(lon(:))+3 max(lon(:))]; plat=[min(lat(:)) max(lat(:))];


%---plot
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl;
cmap2=cmap(8:5:end,:);
%%

% pltrangex=4; pltrangey=3.5;
% plon=[140-pltrangex 140+pltrangex]; plat=[35-pltrangey 35+pltrangey]; 
% plon=[120 150]; plat=[20 45];
 plon=[128 149]; plat=[27 42];
%  plon=[130 148]; plat=[31 43];

hf=figure('Position',[100 100 1000 750]);

m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
% m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:5:150,'ytick',25:5:50); 
m_coast('color',[0.6 0.6 0.6],'linewidth',2);
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
% m_usercoast('gumby','linewidth',0.8,'color','k')

hold on
% a=randperm(50);
% b=a(1:5)
% b=5:10:50;
b=1:50;
% b=[5 15 25   25+5  25+15 25+25  ];
for ibc=b
  for imem=ibc:50:nmember
    %mem=member(imember);
    bc_n=mod(imem,50)+1;    
%     m_plot(lon_track(:,imem),lat_track(:,imem),'color',cmap2(bc_n,:),'Linewidth',1); hold on
    m_contour(lon,lat,ens_pmsl(:,:,imem),[1005 1005],'color',cmap2(bc_n,:),'Linewidth',1.2,'linestyle','-'); 
  end
end
% for ibc=b
%   for imem=ibc:50:nmember
%     m_plot(lon_track(pltime,imem),lat_track(pltime,imem),'.k')
%   end
% end

% box of domain
m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')

% m_text(108.5,11.5,['Valid: ',datestr(pltdate,'dd-mmm-yyyy hh:MM:ss')],'color','k','fontsize',15)
m_text(plon(1)+0.25,plat(1)-0.4,['Valid: ',datestr(pltdate,'dd-mmm-yyyy hh:MM:ss')],'color','k','fontsize',15)
title(['Typhoon tracks and SLP'],'fontsize',18)

% outfile=[outdir,'/track_slp_BCcolor','_t',num2str(pltime),'_zoom_allmem'];
outfile=[outdir,'/track_slp_BCcolor','_',datime,'_all'];

% outfile=[outdir,'/',fignam,'_',datime,'_m',num2str(memsize),'thrd',num2str(thi)]; 


print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

