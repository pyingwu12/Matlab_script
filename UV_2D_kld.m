clear
% close all
% addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=1000;   

pltime=[31]; 
pltvari='u10m';
% x=-50:50; intv=1; %x: range for cal. pdf
%
expri='Hagibis05kme01'; 
infilename='201910101800';%hagibis
%
expsize=1000;  randmem=0; %0: plot member 1~pltensize; else:randomly choose members
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  ',pltvari,'  KLD'];   fignam=[expri,'_',pltvari,'-kld_'];  
%
%
load('colormap/colormap_br6.mat') 
cmap=colormap_br6; 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-0.15 -0.1 -0.05 -0.01  0.01 0.05 0.1 0.15];

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
%%
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
  %
  vari_ens= vari_ens0;
  %%
  kld=zeros(nx,ny); bin_num=NaN(nx,ny); GauSp=NaN(nx,ny); bic=NaN(nx,ny);bicG=NaN(nx,ny);
  sprd=zeros(nx,ny);
  for xpi=350:650
   for ypi=150:500
     
     dat=squeeze(vari_ens(xpi,ypi,:));
     
     sig=std(dat);  ens_me=mean(dat);
     
     [bin_num(xpi,ypi), intv, x, bic(xpi,ypi)]=opt_binum(dat,pltensize);
      
     gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x-ens_me)/sig).^2);   gaus(gaus+1==1)=0;
       
     [q, ~]=histcounts(dat,'BinEdges',[x-intv*0.5 x(end)+intv*0.5]);     
     q=q/pltensize/intv;   % probability "density"
     
     kld(xpi,ypi)=sum(gaus*log(gaus/q));    

     dat_G=1/(std(dat,1)*(2*pi)^0.5)*exp(-(1/2)*((dat-ens_me)./std(dat,1)).^2);
     maxlG=sum(log(dat_G));
%      maxlG=-(pltensize/2)*log(2*pi/pltensize*sum((dat-ens_me).^2))-(pltensize/2);
     bicG(xpi,ypi)=-2*maxlG+2*log(pltensize);
     
     if bicG(xpi,ypi)<=bic(xpi,ypi);  GauSp(xpi,ypi)=1;  else;   GauSp(xpi,ypi)=0;   end
% %               lon_nG(n)=lon(xpi,ypi); lat_nG(n)=lat(xpi,ypi);         x_nG(n)=xpi; y_nG(n)=ypi;
     sprd(xpi,ypi)=sig;
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

%     plon=[134.5 143.5]; plat=[32 38.5];
% plon=[135 144.5]; plat=[32 39]; % wide Kantou area
% plon=[112 153]; plat=[18 50];   lo_int=105:15:155; la_int=10:15:50;  %Fugaku05km whole domain center
 plon=[128 145]; plat=[26 43]; lo_int=105:5:155; la_int=10:5:50;

 lonnG=lon(GauSp==0);latnG=lat(GauSp==0);
 
    %---plot
    plotvar=kld;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    %  
    hf=figure('Position',[100 100 800 630]);
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
    [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      %
    %---
    m_plot(lonnG(1:4:end),latnG(1:4:end),'x','Markersize',2,'color',[0.2 0.05 0.2])
%     m_contour(lon,lat,GauSp,[1 1],'color','k')
    
    m_contour(lon,lat,mean(vari_ens,3),5,'linewidth',1.5,'color',[0.8 0.4 0.4],'linestyle','-')
    m_contour(lon,lat,sprd,5,'linewidth',2,'color',[0.4 0.8 0.4],'linestyle',':')
%     m_contour(lon,lat,pmsl(:,:,ti),950:5:990,'linewidth',2,'color',[0.4 0.4 0.4],'linestyle','-')
%     m_contour(lon,lat,rain(:,:,ti)-rain(:,:,ti-1),[10 10 ],'linewidth',2,'color',[0.1 0.3 0.95],'linestyle','-')
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