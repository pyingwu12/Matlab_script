clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;  pltime=[1:7];

expri='MSM'; infilename='201910121200'; 
%
indir=['/data8/wu_py/Data/fcst_surf.nus'];
outdir=['/home/wu_py/labwind/Result_fig'];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,' wind spped'];   fignam0=[expri,'_WinSpd_'];
%--
% plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center
% plon=[139.2 140.9]; plat=[34.85 36.3 ];  fignam=[fignam0,'tokyobay_']; lo_int=134:2:145; la_int=31:2:40;

plon=[134.8 143.5]; plat=[32.3 38.5];  fignam=[fignam0,'Kanto_']; lo_int=135:5:144; la_int=30:5:37; % Japan center of Kanto
% plon=[138 141]; plat=[34 37.3]; fignam=[fignam0,'ktp_'];  lo_int=130:2:146; la_int=25:2:45; msize=13;  %Kantou portrait(verticle)
%--
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 8 9 11 12 14 ],:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 5 10 15 20 25 30];
%---
infile_mfhm='/obs262_data01/wu_py/Experiments/Hagibis05kme01/mfhm.nc';
land = double(ncread(infile_mfhm,'landsea_mask'));
lon = double(ncread(infile_mfhm,'lon'));    lat = double(ncread(infile_mfhm,'lat'));
%---
%
infile=[indir,'/',infilename,'.nc'];   
data_time = (ncread(infile,'time'));   
[nx, ny]=size(lon); ntime=length(data_time);
u10 = ncread(infile,'u10m');    v10 = ncread(infile,'v10m');
spd10=double((u10.^2+v10.^2).^0.5);     
pmsl = ncread(infile,'pmsl');


%% plot maximum during pltime
%--
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
spd_maxP=squeeze(max(spd10,[],3));  
%---
plotvar=spd_maxP;
tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
pmin=min(tmp);  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
%
hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
  %--    
m_contour(lon,lat,land,[0.5 0.5],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--') %--coast line by mfhm
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
%---  
  tit={[titnam];[datestr(pltdate(pltime(end)),'mm/dd HHMM-'),datestr(pltdate(pltime(1)),'HHMM'),' Max.']};   
  title(tit,'fontsize',17)
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
outfile=[outdir,'/',fignam,datestr(pltdate(pltime(end)),'mmdd_HH'),datestr(pltdate(pltime(1)),'HH'),'M'];
if saveid==1
 print(hf,'-dpng',[outfile,'.png'])    
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

%% plot each time
%{
%--
for ti=pltime
  plotvar=squeeze(spd10(:,:,ti));
  %
  tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
  pmin=min(tmp);  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
  %
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
  %--    
m_contour(lon,lat,land,[0.5 0.5],'linewidth',1.2,'color',[0.1 0.1 0.1],'linestyle','--') %--coast line by mfhm
m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
  %
  %---box of domain
  %m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
  %---  
  tit=[titnam,'  ',datestr(pltdate,'mm/dd HHMM')];   
  title(tit,'fontsize',17)
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
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd_HHMM_'),'ti',num2str(ti)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
end %ti
%}
