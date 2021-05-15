function q2all=cal_q2(dir,expri,ymdm,sth,lenh,dom,bdy,typst,ccc)
%ccc=':';

%expri='test88'; time='2018062100'; sth=16;  lenh=48;  dom='01';
%typst='mean';  bdy=0;

indir=[dir,'/',expri]; 
%---setting
if isempty(ccc); ccc=':'; end
year=ymdm(1:4); mon=ymdm(5:6); stday=str2double(ymdm(7:8)); s_min=ymdm(9:10);
infilenam='wrfout'; 

%---
q2all=size(lenh,1); 
for ti=1:lenh    
  hr=sth+ti-1;
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
  %------read netcdf data--------
  infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  if exist(indir,'dir') && ~exist(infile,'file') 
    %disp([infile,' is no exist']); 
    q2all(ti)=NaN;
  else 
    q2 = ncread(infile,'Q2'); q2=q2*1e3;   
    switch(typst)
    case('mean')
     q2all(ti)=mean(mean(q2(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
     q2all(ti)=max(max(q2(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('min')
     q2all(ti)=min(min(q2(bdy+1:end-bdy,bdy+1:end-bdy)));
    end %switch   
  end %if exist
end %time