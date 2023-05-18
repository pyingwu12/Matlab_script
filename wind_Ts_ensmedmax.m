clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

pltensize=20;    
randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
%
% expnam='Hagibis05kme02'; infilename='201910101800';%hagibis05
expnam='Hagibis01kme06'; infilename='201910111800';%hagibis01
expsize=1000; 
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
infile_hm=['/obs262_data01/wu_py/Experiments/',expnam,'/mfhm.nc',];

outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam=[expnam,'  Max. wind speed'];   fignam=[expnam,'_wind-max_'];   unit='m/s';
%---
land = double(ncread(infile_hm,'landsea_mask'));
%%
%---read ensemble
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
for imem=1:pltensize     
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
  if imem==1
    lon = double(ncread(infile,'lon'));
    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));
    [nx, ny]=size(lon);
    spd10_ens0=zeros(nx,ny,pltensize,length(data_time));      
  end  
  u10 = ncread(infile,'u10m');
  v10 = ncread(infile,'v10m');
  spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5; 
  if mod(imem,100)==0; disp(['Member ',num2str(imem),' done']); end
end  %imem
disp('finish read files')

 %% obs
 obs_lag=18; 

year='2019'; mon='10'; days=11:12; hrs=0:23; minu='00';
indir_o='/data8/wu_py/Data/obs/';

nti=0;
for dy=days
  for hr=hrs
  nti=nti+1;  
  
  infile=[indir_o,'amds_',year,mon,num2str(dy,'%.2d'),num2str(hr,'%.2d'),minu,'.txt'];
  A=importdata(infile);   
  if nti==1;  lon=A(:,7); lat=A(:,8); sta_num_ini=A(:,1); wind_dir(:,nti)=A(:,10); wind_speed(:,nti)=A(:,9);
  else
    for ista=1:size(A,1)
      fi=find(sta_num_ini==A(ista,1), 1);      
      if isempty ( fi )==1
      sta_num_ini(end+1)=A(ista,1);  lon(end+1)=A(ista,7); lat(end+1)=A(ista,8);
      wind_dir(end+1,1:nti-1)=NaN;   wind_speed(end+1,1:nti-1)=NaN;
      wind_dir(end,nti)=A(ista,10);  wind_speed(end,nti)=A(ista,9);        
      else        
      wind_dir(fi,nti)=A(ista,10);
      wind_speed(fi,nti)=A(ista,9);
      end
    end % for ista
  end %if nti==1  
  
  end % hrs
end %days
omax= max(wind_speed,[],1);
 %%
 
%  ens_med_landmax=zeros(length(data_time),1);
landr1=1;
landr2=0.9;
landr=1;
%
 for ti=1:length(data_time)     
     
  temp=squeeze(median(squeeze(spd10_ens0(:,:,:,ti)),3)); 
  temp(land<landr)=NaN;   
  ens_med_landmax(ti)=max(temp(:));
  
  clear temp
  temp=squeeze(max(squeeze(spd10_ens0(:,:,:,ti)),3)); 
  temp(land<landr)=NaN;   
  ens_max_landmax(ti)=max(temp(:));
  
  clear temp
  temp=squeeze(quantile(squeeze(spd10_ens0(:,:,:,ti)),0.75,3)); 
  temp(land<landr)=NaN;   
  ens_quantlandmax(ti)=max(temp(:));
  
if mod(ti,5)==0; disp(data_time(ti)); end
 end
 
 %
figure
plot(1:48,omax); hold on
 plot(obs_lag+1:obs_lag+1+24,ens_med_landmax)
   
 plot(obs_lag+1:obs_lag+1+24,ens_max_landmax)
  plot(obs_lag+1:obs_lag+1+24,ens_quantlandmax)