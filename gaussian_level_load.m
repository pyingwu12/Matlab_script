% function gaussian_level(expri,pltensize,pltvari)
% clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltensize=1000;  pltime=[43]; pltvari='wind';
%
expri='Hagibis05kme02'; infilename='201910101800';%hagibis
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  ',pltvari,'  Diff. from Gaussian'];   fignam=[expri,'_',pltvari,'-diffGau_'];  
%
%%
infile=[indir,'/0000/',infilename,'.nc'];  
rain=ncread(infile,'rain'); 
pmsl=ncread(infile,'pmsl'); 
data_time = (ncread(infile,'time'));  
%
%%
%     plon=[134.5 143.5]; plat=[32 38.5];lo_int=105:5:155; la_int=10:5:50;
% plon=[135 144.5]; plat=[32 39]; lo_int=105:5:155; la_int=10:5:50;% wide Kantou area
plon=[130 144.1]; plat=[28 40]; lo_int=105:5:155; la_int=10:5:50;% Japan area
% plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center

load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd([1 2 3 5, 7:10, 11 13 14],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.1:0.1:1];
%%
for ti=pltime
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

  load(['nonGau_m',num2str(pltensize),'/',...
      expri,'_',pltvari,'_nonGau_',datestr(pltdate,'mmdd_HHMM'),'.mat']);
    %---plot
    plotvar=distr_diff;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      %
    %---
    m_contour(lon,lat,pmsl(:,:,ti),950:10:990,'linewidth',2,'color',[0.4 0.4 0.4],'linestyle','-')
%     m_contour(lon,lat,rain(:,:,ti)-rain(:,:,ti-1),[10 10 ],'linewidth',2,'color',[0.1 0.3 0.95],'linestyle','-')
    %
%     m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.3 0.3 0.3],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
%
    tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};   
    title(tit,'fontsize',18)
    %
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
    colormap(cmap); drawnow;  
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),'_m',num2str(pltensize)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
%}
end % pltime
