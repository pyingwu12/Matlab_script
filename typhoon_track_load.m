clear 
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltensize=50; 
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
%
% expri='Hagibis05kme01'; infilename='201910101800'; infiletrackname='201910101800track';
expri='H01MultiE0206'; infilename='201910111800'; load(['H01MultiE0206_center_',infilename,'.mat'])
%
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Tracks';   fignam=[expri,'_track_'];  % unit='m s^-^1';
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
%---
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    data_time = (ncread(infile,'time'));
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    ntime=length(data_time);  
    lon_track=zeros(ntime,pltensize);
    lat_track=zeros(ntime,pltensize);
  end  
  
end  %imem
%%
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

%---plot
%%
% plon=[min(lon(:)) max(lon(:))]; plat=[min(lat(:)) max(lat(:))];
plon=[132 148]; plat=[25 42.8];
% plon=[135 142]; plat=[28 38];
%
hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%
for imem=1:pltensize
m_plot(lon_track(:,imem),lat_track(:,imem),'color',[0.95 0.85 0.1],'Linewidth',1.2); hold on
drawnow
end

% m_plot(lon_track(43,:),lat_track(43,:),'.','color',[0.8 0.6 0.05]);
m_plot(best_lon,best_lat,'color',[0.4 0.3 0.1],'Linewidth',1.5,'Marker','.','Markersize',12); 
% m_plot(lon_track(:,mem_best),lat_track(:,mem_best),'color',[0.6 0.1 0.1],'Linewidth',1); 
%---
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
m_usercoast('gumby','linewidth',1,'color',[0.3 0.3 0.3],'linestyle','--')
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',110:5:150,'ytick',15:5:50,'color',[0.3 0.3 0.3]); 
%---plot the box of the domain ---
% m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
%---
tit=[expri,'  ',titnam,'  (',num2str(pltensize),' mem)'];   
title(tit,'fontsize',18)
%
outfile=[outdir,'/',fignam,'m',num2str(pltensize),'rnd',num2str(randmem)];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}