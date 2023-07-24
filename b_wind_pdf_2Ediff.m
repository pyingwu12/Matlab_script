clear
% close all
% addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;   

pltime=[28 31 34 37 40 43]; 
pltvari='v10m'; %wind, u10m, or v10m


%
expri1='Hagibis05kme01'; expri2='Hagibis05kme02';
infilename='201910101800';%hagibis
%
expsize=1000;  randmem=0; %0: plot member 1~pltensize; else:randomly choose members
%
% indir=['/obs262_data01/wu_py/Experiments/',expri1,'/',infilename];
indir='/obs262_data01/wu_py/Experiments/';outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri1,' ',expri2,'  ',pltvari,'  KLD'];   fignam=[expri1,expri2,'_',pltvari,'-pdf-diff_'];  
%
%
load('colormap/colormap_parula20.mat') 
cmap=colormap_parula20(1:2:end,:);  
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[-0.15 -0.1 -0.05 -0.01  0.01 0.1 0.3 0.5];
L=[0.1 0.3 0.5 0.7 0.9 1.1 1.4 1.7 2];

%%    
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); memtag='rndm';  %!random choose members  
else; member=1:pltensize; memtag='seq'; %!!!!! sequential members
end
%%

for ti=pltime     
  for imem=1:pltensize     
    infile1=[indir,expri1,'/',infilename,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
    infile2=[indir,expri2,'/',infilename,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];  
    if imem==1
    lon = double(ncread(infile1,'lon'));    lat = double(ncread(infile1,'lat'));
    [nx, ny]=size(lon);     data_time = (ncread(infile1,'time'));  %ntime=length(data_time);   
    ens1=zeros(nx,ny,pltensize); 
    ens2=zeros(nx,ny,pltensize); 
    end      
    %
    if strcmp(pltvari,'wind')
      u=ncread(infile1,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
      v=ncread(infile1,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
     ens1(:,:,imem)= sqrt(u.^2 + v.^2) ;  
      u=ncread(infile2,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
      v=ncread(infile2,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
     ens2(:,:,imem)= sqrt(u.^2 + v.^2) ; 
    else     
     ens1(:,:,imem)= ncread(infile1,pltvari,[1 1 ti],[Inf Inf 1],[1 1 1]); 
     ens2(:,:,imem)= ncread(infile2,pltvari,[1 1 ti],[Inf Inf 1],[1 1 1]); 
    end
  end  %imem
  disp('end of reading files')
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  %%
  kld=zeros(nx,ny);  
  for xpi=350:650
   for ypi=150:500
     
     dat1=squeeze(ens1(xpi,ypi,:));
     dat2=squeeze(ens2(xpi,ypi,:));

     [bin_num, intv, x, bic]=opt_binum(dat2);
     
     [q2, ~]=histcounts(dat2,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);                
     [q1, ~]=histcounts(dat1,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);  

     q1(q1==0)=1e-16;
     q1=q1/pltensize/intv;   % probability "density"
     
     q2(q2==0)=1e-16;
     q2=q2/pltensize/intv;  
     
     kld(xpi,ypi)=sum(q2.*log(q2./q1)); 

    end
  end
  disp('end of calculating')
  kld(kld+1==1)=NaN;
  % sprd=std(vari_ens,0,3);
%%
% figure; contourf(kld',25,'linestyle','none')
% colorbar
% caxis([-0.15 0.15])
% hold on
% plot(x_nG(1:5:end),y_nG(1:5:end),'.r','markersize',0.5)
%%

 plon=[128 145]; plat=[26 43]; lo_int=105:5:155; la_int=10:5:50;
 
    %---plot
    plotvar=kld;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      %
    %---
    %
%     m_coast('color','k');
    % m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
    m_usercoast('gumby','linewidth',1,'color',[0.6 0.6 0.6],'linestyle','--')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.6 0.6 0.6]); 
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
%}
end % pltime