%
%---Specially for compare sameBC(n:50:100) and diffBC(n:n+20)---

% clear; addpath('/data8/wu_py/MATLAB/m_map/')
close all

saveid=1;

pltime=1:3:25;

expsize=1000; BCnum=50; ensize=20;

% expri='Hagibis05kme01'; infilename='201910101800';  pltcnt=[970,990,1010,1015:5:1040];  %hagibis
% expri='Nagasaki05km'; infilename='202108131200';  pltcnt=900:5:1040;    %nagasaki 05 (Duc-san)
% plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center
%---
% expri='Kumagawa02km'; infilename='202007030900';  pltcnt=1002:3:1015; %kumakawa 02 (Duc-san)
% plon=[120 139.5]; plat=[23 38];   lo_int=105:10:155; la_int=15:10:50;  %Kyushu02km whole domain center
%---
expri='Nagasaki02km'; infilename='202108131300';  pltcnt=1000:3:1012;   %nagasaki 02 (Oizumi-san)
plon=[119.6 137.4]; plat=[27.1 36.9]; lo_int=105:10:155; la_int=15:10:50;  %Oizumi-Nagasaki 02km whole domain center
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
expnam=expri;  titnam=[expnam,'  Psea spread']; fignam=[expri,'_BC_PmslSprd_']; unit='hPa';
%--
% plon=[134.5 143.5]; plat=[32 38.5]; %hagibis kantou
%--
load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd(1:2:end,:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%---
L=[0.3 0.6 0.9 1.2 1.5 1.8 2.1];
%---
infile_mfhm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm.nc'];
land = double(ncread(infile_mfhm,'landsea_mask'));
%%
for imem=1:expsize 
  infile=[indir,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    pmsl0=zeros(nx,ny,ntime,expsize);    
  end  
  if isfile(infile) 
    pmsl0(:,:,:,imem) = ncread(infile,'pmsl');    
  else
    pmsl0(:,:,:,imem) = NaN;
    disp(['member ',num2str(imem,'%.4d'),' file does''t exist'])
  end    
end
% pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
%%
plotid={'sameBC';'diffBC'};
for ti=pltime 
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  pmsl=squeeze(pmsl0(:,:,ti,:));
%   sprd_all = std(pmsl_ti,0,3,'omitnan')  ;  
  %---
  sprd_sameBC=0; sprd_diffBC=0;
  for iset=1:BCnum
    member=iset:BCnum:expsize; 
    vari1=pmsl(:,:,member);
    sprd_sameBC = sprd_sameBC+std(vari1,0,3,'omitnan')./BCnum; 
    
    member=(iset-1)*ensize+1:iset*ensize;
    vari1=pmsl(:,:,member);
    sprd_diffBC = sprd_diffBC+std(vari1,0,3,'omitnan')./BCnum; 
  end
  %%
  %---plot
  cmap=colormap_sprd(1:2:end,:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
  L=[0.3 0.6 0.9 1.2 1.5 1.8 2.1];
  close all
  for iplot=[1 2]  
%     L=[0.3 0.4 0.5 0.6 0.7 0.8 0.9];
%     eval(['plotvar=sprd_',plotid{iplot},'./sprd_all;'])
    eval(['plotvar=sprd_',plotid{iplot},';'])
    pmin=double(min(plotvar(:)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
    %
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
    m_contour(lon,lat,land,[0.6 0.6],'linewidth',0.8,'color',[0.5 0.5 0.5],'linestyle','-')
    %---ens mean
    cntcol=[0.2 0.2 0.2];
    [c,hdis]=m_contour(lon,lat,squeeze(mean(pmsl,3)),pltcnt,'color',cntcol,'linewidth',1.8,'linestyle',':');     
    clabel(c,hdis,pltcnt,'fontsize',10,'LabelSpacing',500,'color',cntcol) 
    %
    tit={[titnam,'  (',plotid{iplot},')'];[datestr(pltdate,'mm/dd HHMM  ('),num2str(BCnum),' sets mean)']};   
    title(tit,'fontsize',18)
    %
%---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap);  drawnow;  title(hc,unit)
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %
    outfile=[outdir,'/',fignam,plotid{iplot},'_',datestr(pltdate,'mmdd_HHMM')];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %
  end %iplot
  %%  plot diff  
  sprd_diff = sprd_diffBC - sprd_sameBC;
  load('colormap/colormap_br6.mat') 
  cmap=colormap_br6;
  cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
  L=[-0.8 -0.6 -0.4 -0.2   0.2  0.4   0.6 0.8];   
  %---plot
  plotvar=sprd_diff;
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
  %  
  hf=figure('Position',[100 100 800 630]);
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
  [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      % 
  %
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.5 0.5 0.5]); 
  m_contour(lon,lat,land,[0.6 0.6],'linewidth',0.8,'color',[0.5 0.5 0.5],'linestyle','-')
  %--- 
  tit={[titnam];['diffBC-sameBC',datestr(pltdate,'  mm/dd HHMM')]};   
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
  outfile=[outdir,'/',fignam,'Diff_',datestr(pltdate,'mmdd_HHMM')];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  
end %ti
%}
