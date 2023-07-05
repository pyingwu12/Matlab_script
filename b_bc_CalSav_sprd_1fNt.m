%
%---Specially for compare sameBC(n:50:100) and diffBC(n:n+20)---

clear; addpath('/data8/wu_py/MATLAB/m_map/')
close all

saveid=1;

expsize=1000; BCnum=50; ensize=20;

% expri='Hagibis05kme01'; infilename='201910101800';%hagibis
expri='Nagasaki05km'; infilename='202108131200';  %nagasaki 05 (Duc-san)
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san)
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
%
%
for imem=1:expsize 
  infile=[indir,'/',num2str(imem,'%.4d'),'/s',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    rain0=zeros(nx,ny,expsize,ntime);
    pmsl0=zeros(nx,ny,expsize,ntime);
    tpw0=zeros(nx,ny,expsize,ntime);
  end  
    rain0(:,:,imem,:) = ncread(infile,'rain');
%     pmsl0(:,:,imem,:) = ncread(infile,'pmsl');
%     tpw0(:,:,imem,:) = ncread(infile,'tpw');

  if mod(imem,100)==1; disp(['member ',num2str(imem),' done']); end
end
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);


% rain=rain0(:,:,:,1:10);
% save([expri,'_rain0_',infilename,'.mat'],'rain')

% disp('finished reading files')
%%
%{
vrnc_pmsl_sameBC=zeros(nx,ny,BCnum,ntime); vrnc_pmsl_diffBC=zeros(nx,ny,BCnum,ntime);
vrnc_pmsl_all=zeros(nx,ny,ntime);
vrnc_tpw_sameBC=zeros(nx,ny,BCnum,ntime);  vrnc_tpw_diffBC=zeros(nx,ny,BCnum,ntime);
vrnc_tpw_all=zeros(nx,ny,ntime);
vrnc_rain1_sameBC=zeros(nx,ny,BCnum,ntime); vrnc_rain1_diffBC=zeros(nx,ny,BCnum,ntime);
vrnc_rain1_all=zeros(nx,ny,ntime);
vrnc_rain3_sameBC=zeros(nx,ny,BCnum,ntime); vrnc_rain3_diffBC=zeros(nx,ny,BCnum,ntime);
vrnc_rain3_all=zeros(nx,ny,ntime);
%%
for ti=1:ntime 
    tic
  if ti>3  
    rain1=squeeze(rain0(:,:,ti,:)-rain0(:,:,ti-1,:));
    rain3=squeeze(rain0(:,:,ti,:)-rain0(:,:,ti-3,:));
  elseif ti>1
    rain1=squeeze(rain0(:,:,ti,:)-rain0(:,:,ti-1,:));
    rain3=zeros(nx,ny,expsize);    
  else
    rain1=zeros(nx,ny,expsize);
    rain3=zeros(nx,ny,expsize);
  end  
  pmsl=squeeze(pmsl0(:,:,ti,:));
  tpw=squeeze(tpw0(:,:,ti,:));
  toc
  tic
  vrnc_pmsl_all(:,:,ti) = var(pmsl,0,3,'omitnan');  
  vrnc_tpw_all(:,:,ti) = var(tpw,0,3,'omitnan');   
  vrnc_rain1_all(:,:,ti) = var(rain1,0,3,'omitnan'); 
  vrnc_rain3_all(:,:,ti) = var(rain3,0,3,'omitnan'); 
  %---    
  for iset=1:BCnum    
    member=iset:BCnum:expsize;     
    vari1=pmsl(:,:,member);  vrnc_pmsl_sameBC(:,:,iset,ti) = var(vari1,0,3,'omitnan'); 
    vari1=tpw(:,:,member);  vrnc_tpw_sameBC(:,:,iset,ti) = var(vari1,0,3,'omitnan'); 
    vari1=rain1(:,:,member);  vrnc_rain1_sameBC(:,:,iset,ti) = var(vari1,0,3,'omitnan'); 
    vari1=rain3(:,:,member);  vrnc_rain3_sameBC(:,:,iset,ti) = var(vari1,0,3,'omitnan'); 

    member=(iset-1)*ensize+1:iset*ensize;
    vari1=pmsl(:,:,member);  vrnc_pmsl_diffBC(:,:,iset,ti) = var(vari1,0,3,'omitnan'); 
    vari1=tpw(:,:,member);  vrnc_tpw_diffBC(:,:,iset,ti) = var(vari1,0,3,'omitnan');
    vari1=rain1(:,:,member);  vrnc_rain1_diffBC(:,:,iset,ti) = var(vari1,0,3,'omitnan'); 
    vari1=rain3(:,:,member);  vrnc_rain3_diffBC(:,:,iset,ti) = var(vari1,0,3,'omitnan');     
  end
toc
  disp([num2str(ti/ntime),' % done'])
  
end %ti
%%
save([expri,'_BC_var',infilename,'.mat'],'-v7.3','vrnc_pmsl_all','vrnc_tpw_all','vrnc_rain1_all','vrnc_rain3_all',...
    'vrnc_pmsl_sameBC','vrnc_tpw_sameBC','vrnc_rain1_sameBC','vrnc_rain3_sameBC',...
    'vrnc_pmsl_diffBC','vrnc_tpw_diffBC','vrnc_rain1_diffBC','vrnc_rain3_diffBC','lon','lat','data_time')


%}