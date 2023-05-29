clear
% close all

saveid=1;

pltime=[28];  
pltensize=20; randmem=0; %0: plot member 1~pltensize; 50: members iset:50:1000; else:randomly choose <pltensize> members
iset=1;
%
pltdom=40; %range from the center for plotting (unit: grid point)
%
expri='Hagibis05kme01'; infilename='201910101800'; infiletrackname='201910101800track';
%
expsize=1000; 
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  Wind speed spread'];   fignam=[expri,'_WindSprdRecnt_'];  unit='m/s';
%
load('colormap/colormap_sprd.mat');cmap=colormap_sprd([1 2 3 5, 7:10, 11 13 14],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 1 2 3 4 5 6 7 8 9];
%
% load('H05km_center.mat')
%%
%---read ensemble
if randmem==0; member=1:pltensize;  elseif randmem==50; member=iset:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%%
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));      lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon);  ntime=length(data_time);
    spd10_ens0=zeros(nx,ny,pltensize,ntime);    
    lon_track=zeros(ntime,pltensize);    lat_track=zeros(ntime,pltensize);
  end   
  u10 = ncread(infile,'u10m');    v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5;   
  %---read typhoon center
  infile_track= [indir,'/',num2str(member(imem),'%.4d'),'/',infiletrackname,'.nc'];
  filength=length(ncread(infile_track,'lon'));
  if filength~=ntime
   lon_track(1:filength,imem)=ncread(infile_track,'lon'); lat_track(1:filength,imem)=ncread(infile_track,'lat');
  else
   lon_track(:,imem) = ncread(infile_track,'lon');  lat_track(:,imem) = ncread(infile_track,'lat');
  end  
end  %imem

lon_track(lon_track==0)=NaN;
lat_track(lon_track==0)=NaN;
  %%
for ti=pltime
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  spd10_ens=zeros(pltdom*2+1,pltdom*2+1,pltensize);
  for  imem=1:pltensize  
    %--use typhoon center from duc-san
    dis_sta=(lon-lon_track(ti,imem)).^2+(lat-lat_track(ti,imem)).^2; [xp,yp]=find(dis_sta==min(dis_sta(:)));
    %---use calculated typhoon center   
%   cen_idx=typhoon_center(ti,member(imem));      
%   [xp, yp]=ind2sub([nx ny],cen_idx);
    spd10_ens(:,:,imem)=squeeze(spd10_ens0(xp-pltdom:xp+pltdom, yp-pltdom:yp+pltdom,imem,ti));
  end
  %---
  ensmean=repmat(mean(spd10_ens,3),[1,1,pltensize]);
  enspert=spd10_ens-ensmean;
  sprd=sqrt(sum(enspert.^2,3)./(pltensize-1));  
 %
  %---plot
  plotvar=sprd';
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 680]);   
  [~, hp]=contourf(plotvar,L2,'linestyle','none');   hold on 
  %--ens mean
  plotcnt=[10 20 30]; %wind speed contour
  [c,hdis]=contour(mean(spd10_ens,3)',plotcnt,'color','k','linewidth',1.8);     
  clabel(c,hdis,'fontsize',15,'LabelSpacing',500)   

  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'xtick',20:20:pltdom*2-1,'ytick',20:20:pltdom*2-1)
  set(gca,'Xticklabel',(-pltdom+20:20:pltdom-20)*5,'Yticklabel',(-pltdom+20:20:pltdom-20)*5)
  xlabel('Distance from center (km)');  ylabel('Distance from center (km)')
  % 
  tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem, rnd',num2str(randmem),')']};   
  title(tit,'fontsize',18)
  %
  %---colorbar---
  fi=find(L>pmin,1);
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
  colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
  hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
  for idx = 1 : numel(hFills)
    hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
  end
  %
  outfile=[outdir,'/',fignam,'rnd',num2str(randmem),'m',num2str(pltensize),datestr(pltdate,'_mmdd_HHMM_')...
      ,'g',num2str(pltdom)];
  if saveid==1
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
end  %pltime
