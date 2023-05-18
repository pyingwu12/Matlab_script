
clear
close all


expnam='Hagibis01kme06'; infilename='201910111800';  member=1:1000;  

indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
indir_5km_track='/obs262_data01/wu_py/Experiments/Hagibis05kme02/201910101800';
infile5km_trackname='201910101800track';
fgtime=25; %time of the first gauss
%

%---plotting figure for check 
% load('colormap/colormap_ncl.mat'); 
% % cmap=colormap_ncl(15:5:end,:);
% cmap=colormap_ncl(15:2:end,:);
% plon=[134 144]; plat=[30 38];  
% hf=figure('Position',[100 100 800 630]);
% m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

runum=100; %range for running mean
%
plon=[134 144]; plat=[30 38];  
 hf=figure('Position',[100 100 800 630]);
 m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')

%
nmember=length(member);
for imem=1:nmember
  
  %--read Duc-san's 5-km typhoon center for first guess
  infile_track= [indir_5km_track,'/',num2str(member(imem),'%.4d'),'/',infile5km_trackname,'.nc'];  %for first guess-
  lon_track = ncread(infile_track,'lon');   lat_track = ncread(infile_track,'lat');  
  
  %---read file  
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];
  pmsl0 = ncread(infile,'pmsl'); 
  if imem==1
  data_time = (ncread(infile,'time'));    
  lon = double(ncread(infile,'lon'));     lat = double(ncread(infile,'lat'));
  [nx, ny]=size(lon);
  ntime=size(pmsl0,3);
  typhoon_center=zeros(ntime,nmember);
  end  
      
  for ti=1:ntime
 
    pmsl_ti=pmsl0(:,:,ti);
    pmsl=movmean(movmean(pmsl_ti,runum),runum,2); %running mean
    
    %--distance from fg
      if ti==1  % fg=duc-san's
        dis_fg=(lon-lon_track(fgtime)).^2+(lat-lat_track(fgtime)).^2;          
      else       % fg=last time
        dis_fg=(lon-lon(cen_idx)).^2+(lat-lat(cen_idx)).^2;     
      end

      %---
      pmsl(dis_fg>2)=NaN;      
      cen_idx=find(pmsl==min(pmsl(:)));
      if length(cen_idx)~=1          
          cen_idx=find(dis_fg==min(dis_fg(cen_idx)));          
      end   
      if length(cen_idx)~=1;   cen_idx=cen_idx(1);  end  

      typhoon_center(ti,imem)=cen_idx;

%  m_plot(lon(cen_idx),lat(cen_idx),'.','Markersize',10); hold on

% m_plot(lon(cen_idx),lat(cen_idx),'.','color',cmap(ti,:),'linewidth',2.5,'Markersize',10); hold on
% % % figure
% % % contourf(pmsl); hold on; plot(yp,xp,'rx','linewidth',2)
% % % drawnow
  end
  if imem==1;  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:2:150,'ytick',25:2:50); hold on;end
  m_plot(lon(typhoon_center(:,imem)),lat(typhoon_center(:,imem)),'color',[0.95 0.85 0.1]); hold on
drawnow

  if mod(imem,100)==1; disp([num2str(imem),' member done']); end
end

save([expnam,'_center_',infilename,'.mat'],'typhoon_center')
%       
m_usercoast('gumby','linewidth',0.8,'color','k')

