clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=20; pltime=13;
randmem=50; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members

expri='Hagibis05kme02'; infilename='201910101800';  raincnt=[15 15]; tpwcnt=[65 65];  %hagibis
outag='';
% expri='Nagasaki05km'; infilename='202108131200';  raincnt=[15 15]; tpwcnt=[65 65];  %nagasaki 05 (Duc-san)
plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50; idifx=53; %Fugaku05km whole domain center
%---
% expri='Kumagawa02km'; infilename='202007030900'; raincnt=[15 15]; tpwcnt=[65 65]; %kumakawa 02 (Duc-san)
% plon=[120 139.5]; plat=[23 38];   lo_int=105:10:155; la_int=15:10:50; idifx=58; %Kyushu02km whole domain center
%---
% expri='Nagasaki02km'; infilename='202108131300'; raincnt=[15 15]; tpwcnt=[70 70]; %nagasaki 02 (Oizumi-san)
% plon=[119.6 137.4]; plat=[27.1 36.9]; lo_int=105:10:155; la_int=15:10:50; idifx=44;  %Oizumi-Nagasaki 02km whole domain center
%
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/'];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  TPW spread'];   fignam=[expri,'_TpwSprd_'];
%
% plon=[134.5 143.5]; plat=[32 38.5]; %hagibis kantou
%--
load('colormap/colormap_sprd.mat'); cmap=colormap_sprd(1:2:end,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%---
L=[1 2 3 4 5 6 7];
%---
infile_mfhm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc'];
land = double(ncread(infile_mfhm,'landsea_mask'));
%---
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%---
%%
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/s',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    vari0=zeros(nx,ny,pltensize,ntime);
    rain0=zeros(nx,ny,pltensize,ntime);
  end  
  if isfile(infile) 
    vari0(:,:,imem,:) = ncread(infile,'tpw');
    rain0(:,:,imem,:) = ncread(infile,'rain');
  else
    vari0(:,:,imem,:) = NaN;
    disp(['member ',num2str(member(imem),'%.4d'),' file does''t exist'])
  end    
end
% disp('finished reading files')
%%
for ti=pltime
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  ens=squeeze(vari0(:,:,:,ti));  sprd = std(ens,0,3,'omitnan');     
  %---plot
  plotvar=sprd;
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
  %
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
  m_contour(lon,lat,land,[0.6 0.6],'linewidth',0.8,'color',[0.3 0.3 0.3],'linestyle','-')
  % 
  %---ens mean
  if ti<4
    cntcol=[0.6 0.2 0.1]; pltcnt=tpwcnt;
    [c,hdis]=m_contour(lon,lat,squeeze(mean(vari0(:,:,:,ti),4)),pltcnt,'color',cntcol,'linewidth',1.8,'linestyle',':');     
  else
    cntcol=[0.2 0.2 0.2]; pltcnt=raincnt;
    [c,hdis]=m_contour(lon,lat,squeeze(mean(rain0(:,:,:,ti)-rain0(:,:,:,ti-3),3)),pltcnt,'color',cntcol,'linewidth',1.8,'linestyle',':');
  end
  clabel(c,hdis,pltcnt,'fontsize',10,'LabelSpacing',500,'color',cntcol) 
    %---box of domain
%   m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');
%   m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
  m_plot(lon(1+idifx:end-idifx,idifx),lat(1+idifx:end-idifx,idifx),'color',[0.6 0.6 0.6],'linewidth',1.5);
  m_plot(lon(idifx,1+idifx:end-idifx),lat(idifx,1+idifx:end-idifx),'color',[0.6 0.6 0.6],'linewidth',1.2);
  m_plot(lon(1+idifx:end-idifx,end-idifx),lat(1+idifx:end-idifx,end-idifx),'color',[0.6 0.6 0.6],'linewidth',1.5);
  m_plot(lon(end-idifx,1+idifx:end-idifx),lat(end-idifx,1+idifx:end-idifx),'color',[0.6 0.6 0.6],'linewidth',1.5)

  %
  tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem, rnd',num2str(randmem),')']};   
  title(tit,'fontsize',18)
  %
%---colorbar---
  fi=find(L>pmin,1);
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
  colormap(cmap);  drawnow;  
  hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
  for idx = 1 : numel(hFills)
    hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
  end
%
  outfile=[outdir,'/',fignam,'rnd',num2str(randmem),'m',num2str(pltensize),'_',datestr(pltdate,'mmdd_HHMM')];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

end %ti
%}
