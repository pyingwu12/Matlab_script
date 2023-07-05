% function gaussian_level(expri,pltensize,pltvari)
% clear
% close all
% addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltensize=300;   
% bin_num=ceil(log2(pltensize)+1);
bin_num=floor(2*pltensize^0.5)-1;

pltime=[31]; 
pltvari='v10m';
x=-50:50; intv=1; %x: range for cal. pdf
%
expri='Hagibis05kme01'; 
infilename='201910101800';%hagibis
%
expsize=1000;  randmem=0; %0: plot member 1~pltensize; else:randomly choose members
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  ',pltvari,'  Diff. from Gaussian'];   fignam=[expri,'_',pltvari,'-diffGau_'];  
%
% plon=[134 144]; plat=[30 38];
%     plon=[135.5 142.5]; plat=[33.5 37];% fignam=[fignam,'2_']; 
    plon=[134.5 143.5]; plat=[32 38.5];
%
load('colormap/colormap_sprd.mat') 
cmap=colormap_sprd; %cmap0(1,:)=[0.9 0.9 0.9]; cmap=cmap0([1 3 12 14 15 17 19],:);
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[.1 .2 .3 .4 0.5 0.6 0.7 0.8 1 1.1 1.2 1.3 1.4 1.5];

%%    
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); memtag='rndm';  %!random choose members  
else; member=1:pltensize; memtag='seq'; %!!!!! sequential members
end
%%
%---
infile=[indir,'/0000/',infilename,'.nc'];  
if isfile(infile)
rain=ncread(infile,'rain'); 
pmsl=ncread(infile,'pmsl'); 
end

for ti=pltime     


for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);     data_time = (ncread(infile,'time'));  ntime=length(data_time);   
    vari_ens0=zeros(nx,ny,pltensize); 
  end    
  
  vari_ens0(:,:,imem)= ncread(infile,pltvari,[1 1 ti],[Inf Inf 1],[1 1 1]); 
  
end  %imem
 disp('end of reading files')

%
%%
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));

  vari_ens= vari_ens0;
  distr_diff=zeros(nx,ny);
  %%
  for xpi=350:650
   for ypi=150:500
       
       dat=squeeze(vari_ens(xpi,ypi,:));
       
     sig=std(dat);  ens_me=mean(dat);
     xup=max(dat); xbt=min(dat);   
     
%      intv=(3.5*sig)/(pltensize)^(1/3);
%  intv = (xup-xbt) / (k-1); 
bin_num=opt_binum(dat,pltensize);
bin_ck(xpi,ypi)=bin_num;
 intv=  (xup-xbt) / (bin_num-1);
       x= xbt : intv : xup ; %mid
      
     gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);   gaus(gaus+1==1)=0;
%    gaus(x<xbt)=NaN; gaus(x>xup)=NaN;
       
     [q, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);
     
     q=q/pltensize/intv;
     
   
     
     distr_diff(xpi,ypi)=sum(abs(gaus-q),'omitnan');             
    end
  end
  disp('end of calculating')
  distr_diff(distr_diff+1==1)=NaN;
%   save(['nonGau_m',num2str(pltensize),'/',expri,'_',pltvari,'_nonGau_',datestr(pltdate,'mmdd_HHMM'),'.mat'],...
%       'distr_diff','lon','lat')
%%
%
% xpi=514; ypi=230;
% xpi=484; ypi=310;
xpi=643; ypi=415;
% xpi=492; ypi=274;


       dat=squeeze(vari_ens(xpi,ypi,:));
%        
%        xup=max(dat); xbt=min(dat);         
%        intv = (xup-xbt) / (bin_num-1);%        
%        x= xbt : intv : xup ; %mid
       
     sig=std(dat);  ens_me=mean(dat);
     xup=max(dat); xbt=min(dat); 
     
%      test_dat=normrnd(ens_me,sig,pltensize);
     
     
     for k=ceil(log2(pltensize)+1):3:floor(2*pltensize^0.5)-1
     
%      intv=(3.5*sig)/(pltensize)^(1/3);
 intv = (xup-xbt) / (k-1);                          
       x= xbt : intv : xup ; %mid
      
     gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);   gaus(gaus+1==1)=0;
%    gaus(x<xbt)=NaN; gaus(x>xup)=NaN;
       
     [q, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);
     
     q=q/pltensize/intv;
     
     KL_k(k)=sum(gaus*log(gaus/q));
     
     figure; histogram(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5],'Normalization','pdf') ;
       
hold on; plot(x,gaus)
drawnow
% set(gca,'xlim',[-50 50])
% set(gca,'ylim',[0 0.35])
     
     
     end
     
     %}
     
     %%
% xpi=526; ypi=205;
% xpi=503; ypi=259;
xpi=364; ypi=405;

    dat=squeeze(vari_ens(xpi,ypi,:));
       
     sig=std(dat);  ens_me=mean(dat);     
            xup=max(dat); xbt=min(dat);
            
             intv=  (xup-xbt) / (bin_num-1);
%           intv=(3.5*sig)/(pltensize)^(1/3);
%            intv=(2*iqr(dat))/(pltensize)^(1/3);
       x= xbt : intv : xup ; %mid

     gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);   gaus(gaus+1==1)=0;

       figure; histogram(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5],'Normalization','pdf') ;
       
hold on; plot(x,gaus)
% set(gca,'xlim',[-50 50])
% set(gca,'ylim',[0 0.35])

[q, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);
q=q/pltensize/intv;
k=sum(gaus*log(gaus/q));

title({['x',num2str(xpi),', y',num2str(ypi)];['sig=',num2str(sig),', IQR=',num2str(iqr(dat)),', bin=',num2str(length(x)),', kld=',num2str(k)]})

[ni, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);
maxl=sum(ni.*log(ni))-pltensize*log(pltensize)
bic=-2*maxl+(length(x)-1)*log(pltensize)

maxlG=-(pltensize/2)*log(2*pi/pltensize*sum((dat-ens_me).^2))-(pltensize/2)
bicG=-2*maxlG+2*log(pltensize)


     %%
x=-50:50; intv=1; %x: range for cal. pdf


    dat=squeeze(vari_ens(xpi,ypi,:));
     xup=max(dat); xbt=min(dat); 
    
     sig=std(dat);  ens_me=mean(dat);
     gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);   gaus(gaus+1==1)=0;
    gaus(x<xbt)=NaN; gaus(x>xup)=NaN;
    
       figure
      histogram(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5],'Normalization','pdf') 
       
hold on; plot(x,gaus)
set(gca,'xlim',[-50 50])
set(gca,'ylim',[0 0.35])

 [q, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);
 q=q/pltensize/intv;
k=sum(abs(gaus-q),'omitnan')  
%}
%%
%
%     plon=[134.5 143.5]; plat=[32 38.5];
% plon=[135 144.5]; plat=[32 39]; % wide Kantou area
plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center

    %---plot
    plotvar=distr_diff;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      %
    %---
%     m_contour(lon,lat,pmsl(:,:,ti),950:5:990,'linewidth',2,'color',[0.4 0.4 0.4],'linestyle','-')
%     m_contour(lon,lat,rain(:,:,ti)-rain(:,:,ti-1),[10 10 ],'linewidth',2,'color',[0.1 0.3 0.95],'linestyle','-')
    %
%     m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.3 0.3 0.3],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.3 0.3 0.3]); 
    % 
%
    tit={[titnam];[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem, ',memtag,')']};   
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
    outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd'),'_',datestr(pltdate,'HHMM'),'_m',num2str(pltensize),memtag];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
    %---
%}
end % pltime
