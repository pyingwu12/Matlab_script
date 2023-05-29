clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltime=35;

member=[41];

% randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members

expri='Hagibis05kme01'; infilename='201910101800';  plotcnt=[970,990,1010,1015:5:1040]; idifx=53; %hagibis
plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center

%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  PSEA'];   fignam=[expri,'_Pmsl_'];
%--
load('colormap/colormap_grads.mat'); cmap=colormap_grads([2 3 4 6 8 9 11 12 13],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[940 950 960 970 980 990 1010 1020]; 
%---
infile_mfhm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc'];
land = double(ncread(infile_mfhm,'landsea_mask'));
%---
%%
for imem=member 
  infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];   
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
%     pmsl=zeros(nx,ny,ntime);
    pmsl = ncread(infile,'pmsl');

% disp('finished reading files')
%%
for ti=pltime
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  
  %---plot
  plotvar=squeeze(pmsl(:,:,ti));
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,plotvar,20,'linestyle','none'); hold on      % 
  %
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
  m_contour(lon,lat,land,[0.6 0.6],'linewidth',0.8,'color',[0.3 0.3 0.3],'linestyle','-')
  %
  %---box of domain
%   m_plot(lon(:,1),lat(:,1),'k');m_plot(lon(1,:),lat(1,:),'k');
%   m_plot(lon(:,end),lat(:,end),'k');m_plot(lon(end,:),lat(end,:),'k')
%   m_plot(lon(1+idifx:end-idifx,idifx),lat(1+idifx:end-idifx,idifx),'color',[0.6 0.6 0.6],'linewidth',1.5);
%   m_plot(lon(idifx,1+idifx:end-idifx),lat(idifx,1+idifx:end-idifx),'color',[0.6 0.6 0.6],'linewidth',1.2);
%   m_plot(lon(1+idifx:end-idifx,end-idifx),lat(1+idifx:end-idifx,end-idifx),'color',[0.6 0.6 0.6],'linewidth',1.5);
%   m_plot(lon(end-idifx,1+idifx:end-idifx),lat(end-idifx,1+idifx:end-idifx),'color',[0.6 0.6 0.6],'linewidth',1.5)

  %---  
  tit=[titnam,'  ',datestr(pltdate,'mm/dd HHMM'),'  (mem',num2str(imem),')'];   
  title(tit,'fontsize',17)
  %
%---colorbar---
caxis([940 1020]); colorbar('fontsize',15,'LineWidth',1.5)
%   fi=find(L>pmin,1);
%   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
%   hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
%   colormap(cmap);  drawnow;  
%   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%   for idx = 1 : numel(hFills)
%     hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
%   end
%
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd_HHMM_'),'m',num2str(imem,'%.4d')];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

end %ti

end %member
%}
