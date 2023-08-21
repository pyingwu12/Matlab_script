clear
close all

saveid=1;

expri={'Hagibis05kme02';'Hagibis05kme01'};  
expnam={'FuRK';'LoRK'};  outag='e012';
cexp1=[ 0.3,0.745,0.933;   0.929,0.694,0.125];
cexp2=[0,0.447,0.741;   0.85,0.325,0.098];
infilename='201910101800';  idifx=53;  

pltensize=1000;    pltime=37;   varinam='wind';

xp=453; yp=385; 
% xp=486; yp=478; 
% xp=589; yp=280; 
% xp=359; yp=249; 

randmem=0; %0: plot member 1~pltensize; else:randomly choose members
%
expsize=1000;  
%
indir='/obs262_data01/wu_py/Experiments/'; outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[varinam,' CDF'];   fignam=['cdf_',outag,'_']; 
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
for ti=pltime  
  
for iexp=1:nexp
  %---read ensemble
  vari0=zeros(nx,ny,pltensize); 
  for imem=1:pltensize     
    infile=[indir,'/',expri{iexp},'/',infilename,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
    if strcmp(varinam,'wind')
    u10 = ncread(infile,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]); 
    v10 = ncread(infile,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
    vari0(:,:,imem)=double(u10.^2+v10.^2).^0.5; 
    else
    vari0(:,:,imem) = ncread(infile,varinam,[1 1 ti],[Inf Inf 1],[1 1 1]);
    end
    if mod(imem,500)==0; disp([num2str(imem),' done']); end
  end  %imem
%   disp ('end reading files')
  %---
  vari1=squeeze(vari0(xp,yp,:)); 
  [bin_num, intv, x, ~]=opt_binum(vari1); 

  n=0;
  for i=x(1)+intv/2:intv:x(end)+intv/2
      n=n+1;
      pltcdf{iexp}(n) = length(find(vari1<=i))/pltensize;
  end
  xi{iexp}=x;
  
  sig=std(vari1);  mu=mean(vari1);
  y{iexp} = cdf('Normal',x,mu,sig);

  figure; histogram(vari1)
end  %exp
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
%%
  %---plot
  hf=figure('Position',[2500 300 930 600]);
  for iexp=1:nexp
   plot(xi{iexp},pltcdf{iexp},'color',cexp1(iexp,:),'linewidth',4); hold on
   plot(xi{iexp},y{iexp},'color',cexp1(iexp,:),'linewidth',2,'linestyle','--')
  end  
  legend(expnam,'box','off','location','se','fontsize',25)
   
  xlabel([varinam,' (m/s)']); ylabel('f(x)')
  set(gca,'fontsize',18,'linewidth',1.4)
 %
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit={[titnam,' at (',s_lon,', ',s_lat,')'];['  ',datestr(pltdate,'mm/dd HHMM'),'  (',num2str(pltensize),' mem)']};
  title(tit,'fontsize',18)
  %
  outfile=[outdir,'/',fignam,datestr(pltdate,'mmdd_HHMM'),'_x',num2str(xp),'y',num2str(yp),'_m',num2str(pltensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  %---  
%   disp([datestr(pltdate,'mm/dd HH:MM'),' done'])

end % pltime

