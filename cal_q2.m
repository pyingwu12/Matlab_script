function q2all=cal_q2(expri,time,sth,lenh,dom,bdy,typst,ccc)
%ccc=':';

%expri='test88'; time='2018062100'; sth=16;  lenh=48;  dom='01';
%typst='mean';  bdy=0;

indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri]; 
%---setting
if isempty(ccc); ccc=':'; end
year=time(1:4); mon=time(5:6); date=str2double(time(7:8)); minu=time(9:10);
pridh=sth:sth+lenh-1;
infilenam='wrfout'; 

%---
nti=0;  q2all=size(length(pridh),1); 
for ti=pridh
   nti=nti+1;
   hr=ti;
   hrday=fix(hr/24);  hr=hr-24*hrday;
   s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
   %------read netcdf data--------
   infile = [indir,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
   if exist(indir,'dir') && ~exist(infile,'file') 
      %disp([infile,' is no exist']); 
      q2all(nti)=NaN;
   else 
      q2 = ncread(infile,'Q2'); q2=q2*1e3;   
      switch(typst)
      case('mean')
       q2all(nti)=mean(mean(q2(bdy+1:end-bdy,bdy+1:end-bdy)));
      case('max')
       q2all(nti)=max(max(q2(bdy+1:end-bdy,bdy+1:end-bdy)));
      case('min')
       q2all(nti)=min(min(q2(bdy+1:end-bdy,bdy+1:end-bdy)));
      end %switch   
   end %if exist
end %time