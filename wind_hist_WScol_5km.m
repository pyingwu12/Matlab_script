% function wind_hist_5km(expnam)
clear
close all

saveid=1;
pltensize=1000; 

pltime=47:48;  staid=2;

% xp=561; yp=346;
%
expnam='Hagibis05kme01';  infilename='201910101800';%hagibis
expsize=1000;  
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='10-m Wind speed';   fignam=[expnam,'_wind-hist-WScol_']; 
%---
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
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
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
load('colormap/colormap_wind2.mat') 
cmap_wind=colormap_wind2([1 3 4 6 7 8 9 11 12 14],:); 
L_wind=[3 6 9 12 15 18 21 24 27];
%%
titnam='10-m Wind speed';   fignam=[expnam,'_wind-hist-WScol_']; 
%---calculate and plot at different times 
hist_Edge=1:30;
hist_width=hist_Edge(2)-hist_Edge(1);
for ti=pltime    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  obs_wind_spd=obs(ti+17-2,1); 
  plotvar=squeeze(spd10_ens(xp,yp,:,ti));
  [ens_pdf, ~]=histcounts(plotvar,[hist_Edge-hist_width/2 hist_Edge(end)+hist_width/2]);
  %---plot  
  hf=figure('position',[100 55 1200 900]);    
  for i=1:length(hist_Edge)  
    hb=bar(hist_Edge(i),ens_pdf(i)./pltensize*100,'grouped'); hold on     
    %---add color
    icol=find(hist_Edge(i)<L_wind,hist_width);
    if isempty(icol); icol=length(cmap_wind);end
    hb.FaceColor=cmap_wind(icol,:);
    hb.BarWidth=1;
  end
  %---obs
%   xline(obs_wind_spd,'linewidth',2,'color','k');
  %
  xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
  set(gca,'xlim',[hist_Edge(1) hist_Edge(end)],'fontsize',18,'linewidth',1.4,'xtick',0:3:30) ;  
  set(gca,'ylim',[0 15])
  %
  x_lim=xlim; y_lim=ylim;
%   text(x_lim(2)-5,y_lim(2)+0.01,['xp=',num2str(xp),', yp=',num2str(yp)])
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