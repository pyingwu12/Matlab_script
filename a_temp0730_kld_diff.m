clear
% close all
% addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;   


pltvari='wind';  %wind, u10m, or v10m
%
expri='Hagibis05kme01'; 
infilename='201910101800';%hagibis
%
expsize=1000;  randmem=0; %0: plot member 1~pltensize; else:randomly choose members
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Diff. of KLD';   fignam=['e01e02diff_',pltvari,'-kld_'];  
%
%%
load('colormap/colormap_br6.mat') 
cmap=colormap_br6; 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[ -0.3 -0.2 -0.1 -0.05 0.05  0.1 0.2 0.3];

e02=load('e02_kld_0600.mat');
e01=load('e01_kld_0600.mat');

lon=e01.lon; lat=e01.lat;

infile=[indir,'/0001/',infilename,'.nc'];
data_time = (ncread(infile,'time'));
ti=37; 
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

%  plon=[128 145]; plat=[26 43]; lo_int=105:5:155; la_int=10:5:50;
  plon=[130 144]; plat=[29 40]; lo_int=105:5:155; la_int=10:5:50;

 lonGwrong=lon(e02.GauSp==1 &  e01.GauSp~=1);
 latGwrong=lat(e02.GauSp==1 &  e01.GauSp~=1); 
 
 lonnGwrong=lon(e02.GauSp~=1 &  e01.GauSp==1);
 latnGwrong=lat(e02.GauSp~=1 &  e01.GauSp==1); 
 %%
    %---plot
    plotvar=e01.kld-e02.kld;
    tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
    pmin=min(tmp(:));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
%     pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      %
      
%     m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',0.8,'color',[0.8 0.8 0.8],'linestyle','-')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.6 0.6 0.6]); 
    % 
    enmediff=e01.enme-e02.enme;
    m_contour(lon(350:650,150:500),lat(350:650,150:500),enmediff(350:650,150:500),...
        [0.1 0.1],'linewidth',1.4,'color',[0.8 0.4 0.4],'linestyle','-')
    
    sprddiff=e01.sprd-e02.sprd;
    m_contour(lon(350:650,150:500),lat(350:650,150:500),sprddiff(350:650,150:500),[0.1 0.1],...
        'linewidth',1.4,'color',[0.2 0.6 0.2],'linestyle','-')
 %---
    m_plot(lonGwrong(1:10:end),latGwrong(1:10:end),'.','Markersize',4,'color',[0.5 0.5 0.1])
     m_plot(lonnGwrong(1:10:end),latnGwrong(1:10:end),'.','Markersize',4,'color',[0.5 0.1 0.5])
 %---
%
    tit=[titnam,'  ',datestr(pltdate,'mm/dd HHMM'),' UTC'];   
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