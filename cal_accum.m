function rain=cal_accum(expri,ymdm,sthrs,acch,dom,bdy,typst,ccc)
%ccc defult ":"
%ymdm: year, month, date, minute
% calculate <acch> hour accum. rainfall from <sth> 


%expri='test38'; time='2018062100'; sth=18;  lenh=4;  dom='01'; typst='mean';

%---setting
year=ymdm(1:4); mon=ymdm(5:6); stday=str2double(ymdm(7:8)); minu=ymdm(9:10);
%indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri]; 
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; 
infilenam='wrfout'; 
if isempty(ccc); ccc=':'; end

%tic
%---
nti=0;  rain=size(length(sthrs),1); 
for ti=sthrs
   nti=nti+1;
   rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2); 
   exi=0;
   for j=1:2
      hr=(j-1)*acch+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
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
       rain(nti)=NaN;
   else
   rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
   switch(typst)
    case('mean')
     rain(nti)=mean(mean(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('sum')
     rain(nti)=sum(sum(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
     rain(nti)=max(max(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
   end  
   end
end
%toc