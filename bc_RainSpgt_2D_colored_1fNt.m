clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltime=15;   acch=3;
%
% expri='Hagibis05kme01'; infilename='201910101800';  pltcnt=[970,990,1010,1015:5:1040];  %hagibis
% expri='Nagasaki05km'; infilename='202108131200';  pltcnt=900:5:1040;    %nagasaki 05 (Duc-san)
% plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center
%---
% expri='Kumagawa02km'; infilename='202007030900';  pltcnt=1002:3:1015; %kumakawa 02 (Duc-san)
% plon=[120 139.5]; plat=[23 38];   lo_int=105:10:155; la_int=15:10:50;  %Kyushu02km whole domain center
%---
expri='Nagasaki02km'; infilename='202108131300';  pltcnt=1000:3:1012;   %nagasaki 02 (Oizumi-san)
plon=[119.6 137.4]; plat=[27.1 36.9]; lo_int=105:10:155; la_int=15:10:50;  %Oizumi-Nagasaki 02km whole domain center
%---
expsize=1000; BCnum=50; ensize=20;
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%--
titnam='BC-colored';   fignam=[expri,'_PmslRainSpgt_'];   
%
load('colormap/colormap_ncl.mat'); cmap=colormap_ncl; cmap2=cmap(8:5:end,:);
%---
%%
pltbc=[6 26 46];
% pltbc=[9 10 25 26 43 44] %kuma for SV pair 
for ibc=pltbc 
for imem=ibc:BCnum:expsize
  infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];      
  if imem==pltbc(1)
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon);      ntime=length(data_time);
    rain0=zeros(nx,ny,pltensize,ntime);
    pmsl0=zeros(nx,ny,pltensize,ntime);
  end  
  rain0(:,:,imem,:) = ncread(infile,'rain');
  pmsl0(:,:,imem,:) = ncread(infile,'pmsl');
end  %imem
end
%%
close all
for ti=pltime    
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  pmsl_plt=squeeze(pmsl0(:,:,:,ti));
%   rain_plt=squeeze(rain0(:,:,:,ti)-rain0(:,:,:,ti-acch));
  %---plot    
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%---
  m_usercoast('gumby','patch',[0.9 0.9 0.9],'linestyle','none'); hold on
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
%
  for ibc=pltbc
    for imem=ibc:BCnum:expsize
    m_contour(lon,lat,pmsl_plt(:,:,imem),pltcnt,'color',cmap2(ibc,:),'Linewidth',1.2,'linestyle','--');
%     m_contour(lon,lat,rain_plt(:,:,imem),[30 30],'color',cmap2(ibc,:),'Linewidth',1.4,'linestyle','-'); hold on
    drawnow
    end
  end
  %---box of domain
  m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');
  m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
  %-- 
  tit={[expri,'  ',titnam];[datestr(pltdate,'mm/dd HHMM')]};   
  title(tit,'fontsize',18)    
  %   
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd_HHMM')];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  %---
end % pltime
