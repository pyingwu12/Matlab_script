
clear
close all

member=1:1000; hr=18; minu=0;   %initial time: 10/12 0000 UTC

expri='Hagibis01km1000';  expri='H01km';
year='2019'; month='10'; day=12;  infilename='sfc';

indir=['/obs262_data01/wu_py/Experiments/',expri];
indir_5km_track='/home/wu_py/plot_5kmEns/201910101800/';  %for first guess-

%---plotting figure for check 
% addpath('/data8/wu_py/MATLAB/m_map/')
% load('colormap/colormap_ncl.mat'); 
% cmap=colormap_ncl(15:2:end,:);
% plon=[134 144]; plat=[30 38];  
%  hf=figure('Position',[100 100 800 630]);
%  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    
ntime=length(minu)*length(hr);  nmember=length(member);
typhoon_center=zeros(ntime,nmember);
%%
for imem=1:nmember
  s_mem=num2str(member(imem),'%.4d');
  %--read Duc-san's 5-km typhoon center for first guess
  infile_track= [indir_5km_track,s_mem,'/201910101800track.nc'];
  lon_track = ncread(infile_track,'lon');   lat_track = ncread(infile_track,'lat');  
  %--
  nti=0;
  for ti=hr     
    for tmi=minu
      nti=nti+1;
      s_min=num2str(mod(tmi,60),'%.2d');  
      s_hr=num2str(mod(ti+fix(tmi/60),24),'%2.2d');  
      s_date=num2str(day+fix((ti+fix(tmi/60))/24),'%2.2d'); 
      %---read file   
      infile= [indir,'/',s_mem,'/',infilename,year,month,s_date,s_hr,s_min,'.nc']; 
      if imem==1 && nti==1
      lon = double(ncread(infile,'lon'));     lat = double(ncread(infile,'lat'));
      [nx, ny]=size(lon);
      end
      pmsl0 = ncread(infile,'pmsl'); 
runum=100;
      pmsl=movmean(movmean(pmsl0,runum),runum,2); %running mean
      %--distance from fg
      if nti==1  % fg=duc-san's
        dis_fg=(lon-lon_track(31)).^2+(lat-lat_track(31)).^2;          
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
%       [xp, yp]=ind2sub([nx ny],cen_idx);

      typhoon_center(nti,imem)=cen_idx;

% hf=figure('Position',[100 100 800 630]);
% m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
% m_plot(lon(cen_idx),lat(cen_idx),'.','color',cmap(nti,:),'linewidth',2.5,'Markersize',10); hold on
%       
% % figure
% m_contourf(lon,lat,pmsl); hold on; m_plot(lon(cen_idx),lat(cen_idx),'rx','linewidth',2)
% m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:2:150,'ytick',25:2:50); 
% % drawnow
       
    end
  end %ti
 
%   m_plot(lon(typhoon_center(:,imem)),lat(typhoon_center(:,imem)),'.','Markersize',10); hold on
%   m_text(lon(typhoon_center(1,imem)),lat(typhoon_center(1,imem)),num2str(member(imem)));
%  drawnow

  if mod(imem,100)==1; disp(['mem',s_mem,' done']); end
end %imem

% save([expri,'_center_',month,s_date,'_',num2str(hr(1),'%.2d'),num2str(minu(1),'%.2d'),...
%       '_t',num2str(ntime),'.mat'],'typhoon_center')

% m_usercoast('gumby','linewidth',0.8,'color','k')
% m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:2:150,'ytick',25:2:50); 
