clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltbc=[3 19 26 37];
expsize=1000; BCnum=50; ensize=20;
%
expri='Hagibis05kme01'; infilename='201910101800'; infiletrackname='201910101800track';  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Tracks';   fignam=[expri,'_track_']; 
%%
%---
for ibc=pltbc 
  for imem=ibc:BCnum:expsize
    infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];     
    if imem==pltbc(1)
    data_time = (ncread(infile,'time'));
    lon = double(ncread(infile,'lon'));   lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);   ntime=length(data_time);
    lon_track=zeros(ntime,expsize);
    lat_track=zeros(ntime,expsize);
    pmsl_track=zeros(ntime,expsize);
    pmsl0=zeros(nx,ny,ntime,expsize);
    end  
  pmsl0(:,:,:,imem)=ncread(infile,'pmsl'); 
  %---
  infile_track= [indir,'/',num2str(imem,'%.4d'),'/',infiletrackname,'.nc'];
%   len_track=length(ncread(infile_track,'lon'));
%   if len_track~=length(data_time)
%     lon_track(1:len_track,imem) = ncread(infile_track,'lon');
%     lon_track(len_track+1:end,imem) =NaN;
%     lat_track(1:len_track,imem) = ncread(infile_track,'lat');
%     lat_track(len_track+1:end,imem) =NaN;
%   else
    lon_track(:,imem) = ncread(infile_track,'lon');
    lat_track(:,imem) = ncread(infile_track,'lat');
    pmsl_track(:,imem) = ncread(infile_track,'pmsl');
%   end
  
  end  %imem
end %iset
%% best track & track error
%{
%--best track
infileo='/data8/wu_py/Data/Hagibis.txt';
obs=importdata(infileo);
for ti=1:size(obs,1)    
  if strcmp(num2str(obs(ti,1),'%12d'),infilename)        
  st_idx=ti;
  end
end
bestime_idx=st_idx:st_idx+floor(length(data_time)/6);
best_lon=obs(bestime_idx,2); best_lat=obs(bestime_idx,3);

 err_lon=lon_track(1:6:end,:)-repmat(best_lon,1,pltensize);
 err_lat=lat_track(1:6:end,:)-repmat(best_lat,1,pltensize);
 
 err_track=err_lon.^2+err_lat.^2;
%  [~, mem_best]=min(mean(err_track(7:9,:),1));
%}
%%
%---plot
%--colored by BC
load('colormap/colormap_ncl.mat');cmap=colormap_ncl;cmap2=cmap(8:5:end,:);
%---
% plon=[132 149]; plat=[25 43.2];  lo_int=105:5:155; la_int=10:5:50; domtxt='';
plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50; domtxt='_whole';  %Fugaku05km whole domain center

for ti=43
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
%
hf=figure('Position',[100 100 800 650]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%
%   m_usercoast('gumby','patch',[0.9 0.9 0.9],'linestyle','none'); hold on
    m_coast('patch',[0.9 0.9 0.9],'linestyle','none'); hold on
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
%
for ibc=pltbc
  for imem=ibc:BCnum:expsize
%   for imem=ibc
    m_plot(lon_track(:,imem),lat_track(:,imem),'color',cmap2(mod(imem,BCnum)+1,:),'Linewidth',0.8); hold on
    m_contour(lon,lat,pmsl0(:,:,ti,imem),[1015 1015],'color',cmap2(mod(imem,BCnum)+1,:),'Linewidth',0.8,'linestyle','--')
    drawnow
  end
end
%---
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
% m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')

%---plot the box of the domain ---
m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');
m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
%---
tit={expri,['  ',titnam,' and SLP@',datestr(pltdate,'HHMM'),'UTC']};   
title(tit,'fontsize',18)
%
outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd_HHMM'),'_coloredBC',domtxt];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
end %ti
%}
%%
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm')+ minutes(data_time);
tint=6;
%
hf=figure('Position',[100 100 900 630]);
for ibc=pltbc
  for imem=ibc:BCnum:expsize
  plot(pmsl_track(:,imem),'linewidth',1.8,'color',cmap2(mod(imem,BCnum)+1,:)) ; hold on 
    drawnow
  end
end
  xlabel('Time (UTC)');   ylabel('Pressure (hPa)');
  set(gca,'fontsize',16,'linewidth',1.2,'Ylim',[920 985]) 
  set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate(1:tint:end),'HH'))

%---
tit={expri,['  ',titnam,'  (colored by BC)']};   
title(tit,'fontsize',18)
%
outfile=[outdir,'/',expri,'_TCcenterPmslTs_coloredBC'];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}