clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=10;  pltime=43;  
pltdmsize=40; %range from the center for plotting (unit: grid point)

%
expnam='Hagibis05kme01'; infilename='201910101800';%hagibis
% expnam='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expnam='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% expnam='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san) 
% convert_id=2; %1: duc-san default; 2: convert by wu (<-not used,fixed on 230212)
expsize=1000; 
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam=[expnam,'  Wind speed spread (recenter)'];   fignam=[expnam,'_windsprd-recent_'];  unit='m/s';
%
% plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37];% fignam=[fignam,'2_']; 
    plon=[134.5 143.5]; plat=[32 38.5];
%
load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd; %cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17 19],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 1 1.5 2 3 4 5 6 7 8 9 10 11 12];
%
load('H05km_center.mat')

%%
%---read ensemble
tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  

for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));      lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);  
    data_time = (ncread(infile,'time'));
    spd10_ens0=zeros(nx,ny,pltensize,length(data_time));
  end   
  u10 = ncread(infile,'u10m');    v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
end  %imem
  %%
for ti=pltime     
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
spd10_ens=zeros(pltdmsize*2+1,pltdmsize*2+1,pltensize);

  for  imem=1:pltensize  
  cen_idx=typhoon_center(ti,member(imem));      
  [xp, yp]=ind2sub([nx ny],cen_idx);
  spd10_ens(:,:,imem)=squeeze(spd10_ens0(xp-pltdmsize:xp+pltdmsize,...
                                     yp-pltdmsize:yp+pltdmsize,imem,ti));
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
   
  [~, hp]=contourf(plotvar,L2,'linestyle','none');
    
   hold on 
   plotcnt=[10 20 30];
  [c,hdis]=contour(mean(spd10_ens,3)',plotcnt,'color','k','linewidth',1.8);     
  clabel(c,hdis,'fontsize',15,'LabelSpacing',500)   

  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'xtick',20:20:pltdmsize*2-1,'ytick',20:20:pltdmsize*2-1)
  set(gca,'Xticklabel',(-pltdmsize+20:20:pltdmsize-20)*5,'Yticklabel',(-pltdmsize+20:20:pltdmsize-20)*5)
  xlabel('distance from center (km)')
  ylabel('distance from center (km)')

    % 
    tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
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
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),...
        '_m',num2str(pltensize),'size',num2str(pltdmsize)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---

end % pltime
