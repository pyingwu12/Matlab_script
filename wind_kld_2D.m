clear
% close all
% addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltensize=50;     randmem=0; %0: plot member 1~pltensize; -1:specific; else:randomly choose members

% pltime=[28 31 34 37 40 43]; 
pltime=[37]; 

pltvari='wind';  %wind, u10m, or v10m
%
expri='Hagibis05kme01'; 
infilename='201910101800';%hagibis
%
expsize=1000; 
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  ',pltvari,'  KLD'];   fignam=[expri,'_',pltvari,'-kld_'];  
%
%%
load('colormap/colormap_br6.mat') 
cmap=colormap_br6([4 5 6 7 8 9],:); 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-0.01  0.01 0.1 0.3 0.5];

%%    
%---read ensemble
if randmem==0;  member=1:pltensize; memtag='seq'; %!!!!! sequential members 
elseif randmem==-1  %!!!!!!! specific for small ensemble with resued BC
BCnum=50; n=0;
for k=1:5
  for m=1:10
   n=n+1;
   member(n)=BCnum*(m-1)+k;  
  end
end
memtag='spfic';
else;  tmp=randperm(expsize); member=tmp(1:pltensize); memtag='rndm';  %!random choose members 
end
%!!!
%%
%---
% infile=[indir,'/0000/',infilename,'.nc'];  
% if isfile(infile)
% rain=ncread(infile,'rain'); 
% pmsl=ncread(infile,'pmsl'); 
% end
%%
for ti=pltime     
  for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    [nx, ny]=size(lon);     data_time = (ncread(infile,'time'));  %ntime=length(data_time);   
    vari_ens=zeros(nx,ny,pltensize); 
  end      
  if strcmp(pltvari,'wind')
    u=ncread(infile,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
    v=ncread(infile,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
    vari_ens(:,:,imem)= sqrt(u.^2 + v.^2) ;  
  else 
    vari_ens(:,:,imem)= ncread(infile,pltvari,[1 1 ti],[Inf Inf 1],[1 1 1]); 
  end
  end  %imem
  disp('end of reading files')
%%
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  %
  %%
%   kld2=zeros(nx,ny);
  kld=zeros(nx,ny); bin_num=NaN(nx,ny); GauSp=NaN(nx,ny); 
  bic=NaN(nx,ny); bicG=NaN(nx,ny); bicGM=NaN(nx,ny);
  for xpi=350:650
   for ypi=150:500
     
     dat=squeeze(vari_ens(xpi,ypi,:));    
     [bin_num(xpi,ypi), intv, x, bic(xpi,ypi)]=opt_binum(dat);
     [q, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);  
     q(q==0)=1e-16;
     q=q/pltensize/intv;   % probability "density"     
     %---gaussian
     sig=std(dat);  ens_me=mean(dat);  
     gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);   gaus(gaus+1==1)=0;
     %
     kld(xpi,ypi)=sum(gaus.*log(gaus./q));
     %

     dat_G=1/(std(dat,1)*(2*pi)^0.5)*exp(-(1/2)*((dat-ens_me)./std(dat,1)).^2);
     maxlG=sum(log(dat_G)); %---the same as the formular below
%      maxlG=-(pltensize/2)*log(2*pi/pltensize*sum((dat-ens_me).^2))-(pltensize/2);
     bicG(xpi,ypi)=-2*maxlG+2*log(pltensize);
     
     if bicG(xpi,ypi)<=bic(xpi,ypi)
         GauSp(xpi,ypi)=1;          
     else 
%          GauSp(xpi,ypi)=0;
         clear GMModel
         options = statset('MaxIter',1000);
         GMModel = fitgmdist(dat,2,'CovarianceType','diagonal','SharedCovariance',true,'Options',options);
         bicGM(xpi,ypi)=GMModel.BIC;
         if bicGM(xpi,ypi)<=bic(xpi,ypi) &&  min(GMModel.ComponentProportion)>=0.15
             GauSp(xpi,ypi)=2; 
         else; GauSp(xpi,ypi)=0; 
         end    
     end
     
    end
  end
  disp('end of calculating')
  kld(kld+1==1)=NaN;
sprd=std(vari_ens,0,3);
%%
% % enme=mean(vari_ens,3);
% % save('e01_kld_0600.mat','GauSp','lon','lat','kld','sprd','enme')
%
% plon=[134.5 143.5]; plat=[32 38.5];
% plon=[135 144.5]; plat=[32 39]; % wide Kantou area
% plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center
 plon=[128 145]; plat=[26 43]; lo_int=105:5:155; la_int=10:5:50;

 lonnG=lon(GauSp==0);latnG=lat(GauSp==0); 
 lonGM=lon(GauSp==2);latGM=lat(GauSp==2);
 
    %---plot
    plotvar=kld;
    tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
    pmin=min(tmp(:));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
%     pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[2500 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      %
   
    m_usercoast('gumby','linewidth',0.8,'color',[0.8 0.8 0.8],'linestyle','-')
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int,'color',[0.6 0.6 0.6]); 
    % 
    
    m_contour(lon(350:650,150:500),lat(350:650,150:500),mean(vari_ens(350:650,150:500,:),3),...
        [ -25 -15  0 15  25 ],'linewidth',1.2,'color',[0.8 0.4 0.4],'linestyle','-')
    m_contour(lon(350:650,150:500),lat(350:650,150:500),sprd(350:650,150:500),5,'linewidth',1.2,'color',[0.4 0.4 0.8],'linestyle','-')
%     m_contour(lon,lat,pmsl(:,:,ti),950:5:990,'linewidth',2,'color',[0.4 0.4 0.4],'linestyle','-')
%     m_contour(lon,lat,rain(:,:,ti)-rain(:,:,ti-1),[10 10 ],'linewidth',2,'color',[0.1 0.3 0.95],'linestyle','-')

        %---
    m_plot(lonnG((1:8:end)),latnG((1:8:end)),'.','Markersize',5,'color',[0.35 0.2 0.1])
%     m_contour(lon,lat,GauSp,[1 1],'color','k')
 m_plot(lonGM((1:8:end)),latGM((1:8:end)),'.','Markersize',5,'color',[0.1 0.8 0.05])
 %---
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
