% function wind_hist_5km(expri)
clear
% close all

saveid=0;
pltensize=1000; 

pltime=48;  
staid=2;

% xp=561; yp=346;
%
expri='Hagibis05kme02'; infilename='201910101800';%hagibis
expsize=1000;  numBC=50;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='10-m Wind speed';   fignam=[expri,'_wind-hist-col_']; 
%---
hist_Edge=0:40;
%
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl; cmap2=cmap(8:5:end,:);

%%     
%---read ensemble
tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon); ntime=length(data_time);
    spd0=zeros(nx,ny,pltensize,ntime);     
  end  
  if isfile(infile)
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5;  
  else
      spd0(:,:,imem,:)=NaN;
  end
end  %imem
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
%--find the grid point nearest to the obs station
dis_sta=(lon-lonp).^2+(lat-latp).^2;   [xp,yp]=find(dis_sta==min(dis_sta(:))); %!!!!!
%%
%---calculate and plot at different times 
for ti=pltime    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  obs_wind_spd=obs(ti+17,1); 
  plotvar=squeeze(spd0(xp,yp,:,ti));
  %
  clear ens_pdf
  for ibc=1:numBC
  [ens_pdf(ibc,:), ~]=histcounts(plotvar(ibc:numBC:end),[hist_Edge-0.5 hist_Edge(end)+0.5]);
  end
  %---plot
  hf=figure('position',[100 55 1200 900]);  
  hb=bar(hist_Edge,ens_pdf./pltensize*100,'stacked');  
  for ibc=1:numBC     
    hb(ibc).FaceColor=cmap2(ibc,:);
  end 
  %
  xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
  set(gca,'xlim',[hist_Edge(1) hist_Edge(end)],'ylim',[0 15],'fontsize',18,'linewidth',1.4) ;    
  %
  x_lim=xlim; y_lim=ylim;
  text(x_lim(2)-5,y_lim(2)+0.3,['xp=',num2str(xp),', yp=',num2str(yp)])
  %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={[titnam,' at ',sta,'(',s_lon,', ',s_lat,')'];...
       [expri,'  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
  title(tit,'fontsize',18)
  
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),'_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  %---  
end % pltime