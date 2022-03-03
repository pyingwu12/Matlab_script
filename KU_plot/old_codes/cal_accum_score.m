function [scc, rmse, ETS, bias]=cal_accum_score(indir,expri1,expri2,ymdm,sthrs,acch,dom,thres,ccc)

% calculate SCC etc. of <acch> hour accum. rainfall from <sthrs> 
% expri: experiment directory name
% ymdm: year, month, date, and minute
% sthrs: staring times of accumulation rainfall (vector)
% acch: accumulated period length

%---setting
year=ymdm(1:4); mon=ymdm(5:6); stday=str2double(ymdm(7:8)); minu=ymdm(9:10);

infilenam='wrfout'; 
%indir='/mnt/HDD008/pwin/Experiments/expri_twin/';
if isempty(ccc); ccc=':'; end

%---
nti=0; scc=zeros(1,length(sthrs)); rmse=zeros(1,length(sthrs)); ETS=zeros(1,length(sthrs)); bias=zeros(1,length(sthrs)); 
for ti=sthrs
  for ai=acch
  nti=nti+1;  rall1=cell(1,2); rall2=cell(1,2); 
  for j=1:2
    hr=(j-1)*ai+ti;
    hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
    %------read netcdf data--------
    infile1 = [indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
    rall1{j} = ncread(infile1,'RAINC');
    rall1{j} = rall1{j} + ncread(infile1,'RAINSH');
    rall1{j} = rall1{j} + ncread(infile1,'RAINNC');
    %---
    infile2 = [indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
    rall2{j} = ncread(infile2,'RAINC');
    rall2{j} = rall2{j} + ncread(infile2,'RAINSH');
    rall2{j} = rall2{j} + ncread(infile2,'RAINNC');   
  end %j=1:2
  rain1=double(rall1{2}-rall1{1});
  rain2=double(rall2{2}-rall2{1});
 %--------------------
  [nx, ny]=size(rain1);
  [scc(nti), rmse(nti), ETS(nti), bias(nti)]=cal_score(reshape(rain1,nx*ny,1),reshape(rain2,nx*ny,1),thres);
  end
end %ti