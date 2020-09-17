function acci=cal_accum_hrly(dir,expri,ymdm,sth,lenh,dom,bdy,typst,ccc)
%ccc defult ":"  dir,expri,ymdm,sth,lenh,dom,bdy,typst,ccc

%expri='test38'; time='2018062100'; sth=18;  lenh=4;  dom='01'; typst='mean';

indir=[dir,'/',expri]; 
%---setting
if isempty(ccc); ccc=':'; end
year=ymdm(1:4); mon=ymdm(5:6); stday=str2double(ymdm(7:8)); s_min=ymdm(9:10);
infilenam='wrfout'; 

acci=size(lenh,1); 
for ti=1:lenh
  rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2); exi=0;
  for j=1:2
    hr=(j-1)*1+ti+sth-1;
    hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
    %------read netcdf data--------
    infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    if exist(indir,'dir') && ~exist(infile,'file')       
      exi=1;  break;
    else        
      rc{j} = ncread(infile,'RAINC');
      rsh{j} = ncread(infile,'RAINSH');
      rnc{j} = ncread(infile,'RAINNC');
    end
  end %j=1:2
  if exi~=0
    acci(ti)=NaN; 
  else           
    rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
    switch(typst)
    case('mean')
      acci(ti)=mean(mean(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('sum')
      acci(ti)=sum(sum(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
      acci(ti)=max(max(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    end
  end  
end