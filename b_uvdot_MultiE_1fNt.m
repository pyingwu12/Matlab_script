clear
close all

saveid=0;

expri={'Hagibis05kme02';'Hagibis05kme01'};  
expnam={'FuRK';'LoRK'};  outag='e012';
cexp1=[ 0.3,0.745,0.933;   0.929,0.694,0.125];
cexp2=[0,0.447,0.741;   0.85,0.325,0.098];
infilename='201910101800';  idifx=53;  

pltensize=1000;    pltime=37;

randmem=0; %0: plot member 1~pltensize; else:randomly choose members
%
expsize=1000;  
%
indir='/obs262_data01/wu_py/Experiments/'; outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='dom. avg. UV dot ';   fignam=['UVdot_',outag,'_']; 
%---
ntime=length(pltime); nexp=size(expri,1);

%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); memtag='rndm';  %!random choose members  
else; member=1:pltensize; memtag='seq'; %!!!!! sequential members
end

infile=[indir,'/',expri{1},'/',infilename,'/',num2str(1,'%.4d'),'/',infilename,'.nc']; 
lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));  
data_time = (ncread(infile,'time'));      [nx, ny]=size(lon); 


%%
for itime=1:ntime    
plotu=zeros(pltensize,nexp);plotv=zeros(pltensize,nexp);
for iexp=1:nexp
  %---read ensemble
  u10m0=zeros(nx,ny,pltensize);     v10m0=zeros(nx,ny,pltensize);
  for imem=1:pltensize     
    infile=[indir,'/',expri{iexp},'/',infilename,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
    u10m0(:,:,imem) = ncread(infile,'u10m',[1 1 pltime(itime)],[Inf Inf 1],[1 1 1]);
    v10m0(:,:,imem) = ncread(infile,'v10m',[1 1 pltime(itime)],[Inf Inf 1],[1 1 1]);    
    if mod(imem,500)==0; disp([num2str(imem),' done']); end
  end  %imem
%   disp ('end reading files')
  %---
  plotu(:,iexp)=squeeze(mean(u10m0(1+idifx:end-idifx,1+idifx:end-idifx,:),[1 2])); 
  plotv(:,iexp)=squeeze(mean(v10m0(1+idifx:end-idifx,1+idifx:end-idifx,:),[1 2]));
  clear u10m0 v10m0
end  %exp
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime(itime)));
%%
  %---plot
  hf=figure('Position',[2500 300 700 630]);
  %   scatter(plotu,plotv,80,'o','MarkerEdgeColor','none','Markerfacecolor',cexp1(iexp,:),'MarkerFaceAlpha',0.5); hold on
  for iexp=1:nexp
   plot(plotu(:,iexp),plotv(:,iexp),'.','color',cexp1(iexp,:),'Markersize',12); hold on
  end  
  %
  lim=max(max(vertcat(std(plotu,1),std(plotv,1))));
  for iexp=1:nexp
   [ex, ey]=ellipse(std(plotu(:,iexp)),std(plotv(:,iexp)),mean(plotu(:,iexp)),mean(plotv(:,iexp)));
   plot(mean(plotu(:,iexp)),mean(plotv(:,iexp)),'x','color',cexp2(iexp,:),'Markersize',15,'linewidth',3)  
   plot(ex, ey, 'color',cexp2(iexp,:),'linewidth',2.5) 
   %
   text(mean(plotu,'all')+lim*2.2,mean(plotv,'all')-lim*(3-0.3*iexp),expnam{iexp},'color',cexp2(iexp,:),'fontsize',15)
  end    
  xlabel('U (m/s)'); ylabel('V (m/s)')
  set(gca,'fontsize',18,'linewidth',1.4)
  set(gca,'xlim',[mean(plotu,'all')-lim*3 mean(plotu,'all')+lim*3],'ylim',[mean(plotv,'all')-lim*3 mean(plotv,'all')+lim*3]) ;    
  %  
  tit={titnam;[datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};  
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd_HHMM'),'_m',num2str(pltensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  %---  
  disp([datestr(pltdate,'mm/dd HH:MM'),' done'])
end % pltime

