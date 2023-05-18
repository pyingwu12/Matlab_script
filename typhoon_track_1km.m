clear
close all

saveid=0;
%
pltensize=1000;   randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

expnam='Hagibis01kme06';  expsize=1000; infilename='201910111800';
%
infile_track=[expnam,'_center_',infilename,'.mat'];
%
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Tracks';   fignam=[expnam,'_track2_'];  % unit='m s^-^1';
%
plon=[135 142.6]; plat=[30.2 38.5];
%%
infile_mfhm=['/obs262_data01/wu_py/Experiments/',expnam,'/mfhm2.nc'];  %for get lon lat
lon = double(ncread(infile_mfhm,'lon'));
lat = double(ncread(infile_mfhm,'lat')); 
%--
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
load(infile_track)
 lon_track=lon(typhoon_center);
 lat_track=lat(typhoon_center);
%%
%--best track
infileo='/data8/wu_py/Data/Hagibis.txt';
obs=importdata(infileo);
for ti=1:size(obs,1)    
  if strcmp(num2str(obs(ti,1),'%12d'),infilename)        
  st_idx=ti;
  end
end
bestime_idx=st_idx:st_idx+floor(size(typhoon_center,1)/6);
best_lon=obs(bestime_idx,2); best_lat=obs(bestime_idx,3);
%%
 err_lon=lon_track(1:6:end,1:pltensize)-repmat(best_lon,1,pltensize);
 err_lat=lat_track(1:6:end,1:pltensize)-repmat(best_lat,1,pltensize); 
 err_track=err_lon.^2+err_lat.^2;
 tidx=4; %1200
 [~, mem_best]=min(mean(err_track(tidx,:),1));
%%
%---normal plot
hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%
for imem=1:pltensize
  m_plot(lon(typhoon_center(:,member(imem))),lat(typhoon_center(:,member(imem))),'color',[0.95 0.85 0.1]); hold on
  drawnow  
end
m_plot(best_lon,best_lat,'ok','MarkerFaceColor','k','linestyle','-.','linewidth',1.5,'Markersize',7);
%---
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',110:2:150,'ytick',19:2:50,'color',[0.2 0.2 0.2]); 


%---plot the box of the domain ---
% m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
%---
tit=[expnam,'  ',titnam,'  (',num2str(pltensize),' mem)'];   
title(tit,'fontsize',18)
%
outfile=[outdir,'/',fignam,'m',num2str(pltensize),'rnd',num2str(randmem)];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
%% colored plot
%{
hf=figure('Position',[100 100 800 630]);
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%
for imem=1:50
  m_plot(lon(typhoon_center(1,imem)),lat(typhoon_center(1,imem)),'.','color',[0.01 0.05 0.8],'Markersize',10); hold on
  drawnow  
end
for imem=51:10:1000
  m_plot(lon(typhoon_center(1,imem)),lat(typhoon_center(1,imem)),'.','color',[0.8 0.05 0.01],'Markersize',10); hold on
  drawnow  
end
%---
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',110:5:150,'ytick',15:5:50,'color',[0.3 0.3 0.3]); 
%---plot the box of the domain ---
% m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
%---
tit=[expnam,'  ',titnam,'  (',num2str(pltensize),' mem)'];   
title(tit,'fontsize',18)
%
outfile=[outdir,'/',fignam,'m',num2str(pltensize),'_colored50_950'];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
