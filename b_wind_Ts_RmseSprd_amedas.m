clear
% close all

saveid=0;

pltensize=100;  

randmem=0; %0: plot member 1~pltensize; else:randomly choose members

expri='Hagibis05kme02'; infilename='201910101800'; %pltime=25:6:49;  %hagibis05
pltime=1:3:25;
% expri='Hagibis01kme06'; infilename='201910111800'; pltime=1:6:25;  %hagibis01

expsize=1000; 
%
ntime=length(pltime);
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
indir_obs='/data8/wu_py/Data/obs/';
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  10-m wind speed'];   fignam=[expri,'_WindRankHist_'];
%---
%%

% plon=[138 142]; plat=[33 36.5];
plon=[100 160]; plat=[20 50];


if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end

rmse_enm=zeros(ntime,1); winsprd=zeros(ntime,1);
for ti=1:ntime
  if ti==1
  infile=[indir,'/',num2str(member(1),'%.4d'),'/',infilename,'.nc'];  
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
  
  pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime(ti)));
  infileo=[indir_obs,'amds_',datestr(pltdate,'YYYY'),datestr(pltdate,'mm'),datestr(pltdate,'dd'),...
                            datestr(pltdate,'HH'),datestr(pltdate,'MM'),'.txt'];                
  A=importdata(infileo);  
  lono0=A(:,7); lato0=A(:,8); 
  fin=find(lono0>=plon(1) & lono0<=plon(2) & lato0>=plat(1) & lato0<=plat(2) )  ;
  lono=A(fin,7); lato=A(fin,8); windiro=A(fin,10); windspdo=A(fin,9);
 
  %%
  mse_enm=0; sprd0=zeros(length(lono),1);
  for p=1:length(lono)     
    obs=windspdo(p);
    dis_sta=(lon-lono(p)).^2+(lat-lato(p)).^2;    [xp,yp]=find(dis_sta==min(dis_sta(:))); 
    %
    ens=squeeze(spd_ens(xp,yp,:));
    
    mse_enm=mse_enm+(mean(ens)-obs)^2/length(lono);    
    sprd0(p)=sum((ens-mean(ens)).^2)/pltensize;
  
  end % for p=1:length(obs)  
  rmse_enm(ti) = sqrt(mse_enm); 
  winsprd(ti) = sqrt(sum(sprd0)/length(lono));

end %ti

figure
plot(rmse_enm); hold on
plot(winsprd)