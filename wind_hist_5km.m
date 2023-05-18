% function wind_hist_5km(expnam)
clear
close all

saveid=1;
pltensize=1000; 

pltime=47;  staid=2;

% xp=561; yp=346;
%
expnam='Hagibis05kme01'; 
infilename='201910101800';%hagibis
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='10-m Wind speed';   fignam=[expnam,'_wind-hist_']; 
%---
hist_Edge=0:35;
%%
%---obs
station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi'};
station.lon=[139.75 139.863 139.78 140.385 140.857];
station.lat=[35.692 35.638 35.553 35.763 35.738];
% amdsdata   UTC TIME
% start 2019/10/10 01:00  
% end   2019/10/13 00:00
sta=station.name{staid};
indirobs='/data8/wu_py/Data/obs/';
  infileo=[indirobs,'amds_',sta,'.txt'];
  obs=importdata(infileo);
 
lonp= station.lon(staid); latp=station.lat(staid);

%%     
%---read ensemble
tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon);
    spd10_ens=zeros(nx,ny,pltensize,length(data_time));     
    %--find the grid point nearest to the obs station
    dis_sta=(lon-lonp).^2+(lat-latp).^2;   [xp,yp]=find(dis_sta==min(dis_sta(:))); %!!!!!
  end  
  if isfile(infile)
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd10_ens(:,:,imem,:)=double(u10.^2+v10.^2).^0.5;  
  else
      spd10_ens(:,:,imem,:)=NaN;
  end
end  %imem
%%
%---calculate and plot at different times 
for ti=pltime    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  obs_wind_spd=obs(ti+17,1); 
  plotvar=squeeze(spd10_ens(xp,yp,:,ti));
  %%
  %---plot
%   close all
  hf=figure('Position',[100 100 1000 630]);
  h1=histogram(plotvar,'Normalization','probability','BinEdges',hist_Edge); hold on
  %---obs
  xline(obs_wind_spd,'linewidth',2,'color','r');
  
  %
  xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
  set(gca,'xlim',[hist_Edge(1) hist_Edge(end)],'ylim',[0 0.5],'fontsize',18,'linewidth',1.4) ;    
  yticklabels(yticks*100)
  %
  x_lim=xlim; y_lim=ylim;
  text(x_lim(2)-5,y_lim(2)+0.01,['xp=',num2str(xp),', yp=',num2str(yp)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={[titnam,' at ',sta,'(',s_lon,', ',s_lat,')'];...
       [expnam,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),'_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  %---  
end % pltime
  
