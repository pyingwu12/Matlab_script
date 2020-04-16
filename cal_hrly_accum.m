function acci=cal_hrly_accum(expri,time,sth,lenh,dom,typst,ccc)
%ccc defult ":"

%expri='test38'; time='2018062100'; sth=18;  lenh=4;  dom='01'; typst='mean';

indir=['/HDD003/pwin/Experiments/expri_test/',expri]; 
%---setting
if isempty(ccc); ccc=':'; end
year=time(1:4); mon=time(5:6); date=str2double(time(7:8)); minu=time(9:10);
pridh=sth:sth+lenh-1;
infilenam='wrfout'; 

%tic
%---
nti=0;  acci=size(length(pridh),1); 
for ti=pridh
   nti=nti+1;
   rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2); 
   exi=0;
   for j=1:2
      hr=(j-1)+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
      if exist(indir,'dir') && ~exist(infile,'file') 
        %disp([infile,' is no exist']); 
        exi=1;  break;
      else        
        rc{j} = ncread(infile,'RAINC');
        rsh{j} = ncread(infile,'RAINSH');
        rnc{j} = ncread(infile,'RAINNC');
      end
   end %j=1:2
   if exi~=0
       acci(nti)=NaN;
   else
   rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
   switch(typst)
    case('mean')
     acci(nti)=mean(mean(rain));
    case('sum')
     acci(nti)=sum(sum(rain));
    case('max')
     acci(nti)=max(max(rain));
   end  
   end
end
%toc