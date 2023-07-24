clear
% close all

saveid=0;

pltensize=1000;   randmem=0;

expri='Hagibis05kme01'; infilename='201910101800'; %pltime=25:6:49;  %hagibis05
pltrng=[1  55];  pltint=3; 
tint=1;%for x axis
pltime=pltrng(1):pltint:pltrng(end);
%
expsize=1000; 
%
ntime=length(pltime);
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
indir_obs='/data8/wu_py/Data/obs/';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  10-m wind speed'];   fignam=[expri,'_WindBs_'];
%
%---
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end

% plon=[138 142]; plat=[33 36.5]; % for specify varification area
%%
crps=zeros(ntime,1); 
for ti=1:length(pltime)
  if ti==1
  infile=[indir,'/',num2str(1,'%.4d'),'/',infilename,'.nc'];  
  lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat')); [nx, ny]=size(lon);  
  data_time = (ncread(infile,'time'));
  end
    
  spd_ens=zeros(nx,ny,pltensize);
  for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];     
  u10= ncread(infile,'u10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]);
  v10= ncread(infile,'v10m',[1 1 pltime(ti)],[Inf Inf 1],[1 1 1]); 
  spd_ens(:,:,imem)= double(u10.^2+v10.^2).^0.5; 
  end
  if mod(ti,5)==1; disp([num2str(ti),' end reading ensemble']);end
  
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime(ti)));
  infileo=[indir_obs,'amds_',datestr(pltdate,'YYYY'),datestr(pltdate,'mm'),datestr(pltdate,'dd'),...
                            datestr(pltdate,'HH'),datestr(pltdate,'MM'),'.txt']  ;                  
  A=importdata(infileo);  
  lono0=A(:,7); lato0=A(:,8); 
%   fin=find(lono0>=plon(1) & lono0<=plon(2) & lato0>=plat(1) & lato0<=plat(2) )  ;
%   lono=A(fin,7); lato=A(fin,8); windiro=A(fin,10); windspdo=A(fin,9);
  lono=A(:,7); lato=A(:,8); windiro=A(:,10); windspdo=A(:,9);
  nobs=length(lono);
  %%
  dt=2;
  nth=0;
  for thi=floor(min(windspdo)):dt:ceil(max(windspdo))-dt
      bs1=0; bs2=0;
      nth=nth+1;
  for p=1:nobs   
    obs=windspdo(p);
    dis_sta=(lon-lono(p)).^2+(lat-lato(p)).^2;    [xp,yp]=find(dis_sta==min(dis_sta(:)));  
    ens=squeeze(spd_ens(xp,yp,:));    
    
    prob1=length(find(ens>=thi))/pltensize;
    prob2=length(find(ens>=thi+dt))/pltensize;
    if obs>=thi; a1=1; else; a1=0; end    
    if obs>=thi+dt; a2=1; else; a2=0; end 
    bs1=bs1+(prob1-a1)^2/nobs;
    bs2=bs2+(prob2-a2)^2/nobs;
    
  end % for p=1:length(obs)  
%   bb1(nth)=bs1; bb2(nth)=bs2; thiii(nth)=thi;
      crps(ti)=crps(ti)+(bs1+bs2)*dt/2;

  end
end %ti
%%
figure; 
plot(crps);
