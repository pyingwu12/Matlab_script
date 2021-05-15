function lhfxall=cal_lhfx(dir,expri,ymdm,sth,lenh,dom,bdy,typst,ccc)
%ccc=':';

%expri='test88'; time='2018062100'; sth=16;  lenh=48;  dom='01';typst='mean';  bdy=0;

indir=[dir,'/',expri]; 
%---setting
if isempty(ccc); ccc=':'; end
year=ymdm(1:4); mon=ymdm(5:6); stday=str2double(ymdm(7:8)); s_min=ymdm(9:10);
infilenam='wrfout'; 

%---
lhfxall=size(lenh,1); 
for ti=1:lenh    
  hr=sth+ti-1;
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
  %------read netcdf data--------
  infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  if exist(indir,'dir') && ~exist(infile,'file') 
    %disp([infile,' is no exist']); 
    lhfxall(ti)=NaN;
  else 
    lhfx = ncread(infile,'LH'); 
    switch(typst)
    case('mean')
     lhfxall(ti)=mean(mean(lhfx(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
     lhfxall(ti)=max(max(lhfx(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('min')
     lhfxall(ti)=min(min(lhfx(bdy+1:end-bdy,bdy+1:end-bdy)));
    end %switch   
  end %if exist
end %time