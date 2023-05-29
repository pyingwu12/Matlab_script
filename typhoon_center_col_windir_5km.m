clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;  pltime=[43];   
%
expri='H05km';
infilename='201910101800';
infiletrackname='201910101800track';
expsize=1000;  
%
indir='/data8/leduc/nhm/exp/Fugaku05km/forecast/Fugaku05km06/201910101800';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Typhoon center & Wind direction';  
fignam=[expri,'_tcent-coldir_'];  unit='degree';
%
% plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37];% fignam=[fignam,'2_']; 
    plon=[134.5 143.5]; plat=[32 38.5];
%
load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd; %cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17 19],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 1 1.5 2 3 4 5 6 7 8 9 10 11 12];

%%
%---obs
staid=2;
station.name={'Tokyo';'Rinkai';'Haneda';'Narita';'Choshi'};
station.lon=[139.75 139.863 139.78 140.385 140.857];
station.lat=[35.692 35.638 35.553 35.763 35.738];
% amdsdata   UTC TIME
% start 2019/10/10 01:00 ; end 2019/10/13 00:00
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
    [nx, ny]=size(lon);      
    data_time = (ncread(infile,'time'));
    spd10_ens0=zeros(nx,ny,pltensize,length(data_time));  
    dir10_ens0=zeros(nx,ny,pltensize,length(data_time));
    %--find the grid point nearest to the obs station
    dis_sta=(lon-lonp).^2+(lat-latp).^2;   [xp,yp]=find(dis_sta==min(dis_sta(:))); %!!!!!

  end  
  u10 = ncread(infile,'u10m');    v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
  
  dir10_ens0(:,:,imem,:)=mod(atan2(u10,v10)/pi*180+180,360);
  
  infile_track= [indir,'/',num2str(member(imem),'%.4d'),'/',infiletrackname,'.nc'];
  lon_track(:,imem) = ncread(infile_track,'lon');
  lat_track(:,imem) = ncread(infile_track,'lat');
end  %imem
%%
% load('H05km_center.mat')
for ti=pltime     
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  
%   spd10_ens= squeeze(spd10_ens0(:,:,:,ti));
%   %---
%   ensmean=repmat(mean(spd10_ens,3),[1,1,pltensize]);
%   enspert=spd10_ens-ensmean;
%   sprd=sqrt(sum(enspert.^2,3)./(pltensize-1));   
   
%   close all
    %---plot
%     plotvar=sprd;
%     pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%     [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    %
    % m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.2 0.2 0.2],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
    % 
    %---
    hold on
    
    
    %---wind speed at the station
    load('colormap/colormap_wind2.mat') 
cmap_wind=colormap_wind2([1 3 5 7 8 9 11 13],:); 
L_wind=[45 90 135 180 225 270 315];
%     spd_sta=squeeze(spd10_ens0(xp,yp,:,ti));
    dir_sta=squeeze(dir10_ens0(xp,yp,:,ti));
    
    hpp=plot_point(dir_sta,lon_track(ti,:),lat_track(ti,:),cmap_wind,L_wind,11);
    
    m_plot(lon(xp,yp),lat(xp,yp),'x','Markersize',15,'linewidth',2,'color','r')

    %---ens mean
%   plotcnt=[10 20 30]; cntcol=[0.1 0.1 0.1];
%   [c,hdis]=m_contour(lon,lat,squeeze(mean(spd10_ens,3)),plotcnt,'color',cntcol,'linewidth',1.8);     
%   clabel(c,hdis,plotcnt,'fontsize',15,'LabelSpacing',500,'color',cntcol)   
%
    tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)
    %
%     %---colorbar---
%     fi=find(L>pmin,1);
    L1=((1:length(L_wind))*(diff(caxis)/(length(L_wind)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L_wind,'fontsize',15,'LineWidth',1.5);
    colormap(cmap_wind); title(hc,unit,'fontsize',15);  drawnow;  
%     hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%     for idx = 1 : numel(hFills)
%       hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
%     end
    %
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---

end % pltime
