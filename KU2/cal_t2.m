function t2all=cal_t2(dir,expri,ym,stday,sth,lenh,minu,dom,bdy,typst,ccc)
%ccc=':';

%expri='test88'; time='2018062100'; sth=16;  lenh=48;  dom='01';
%typst='mean';  bdy=0;

indir=[dir,'/',expri]; 
%---setting
if isempty(ccc); ccc=':'; end
year=ym(1:4); mon=ym(5:6); 
infilenam='wrfout'; 
%---
t2all=size(lenh*length(minu),1);  nti=0;
for ti=1:lenh
  hr=sth+ti-1;    hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');

  for tmi=minu
    nti=nti+1;    s_min=num2str(tmi,'%2.2d');     
    %------read netcdf data--------
    infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    if exist(indir,'dir') && ~exist(infile,'file') 
      %disp([infile,' is no exist']); 
      t2all(nti)=NaN;
    else
      t2 = ncread(infile,'T2'); 
      switch(typst)
      case('mean')
       t2all(nti)=mean(mean(t2(bdy+1:end-bdy,bdy+1:end-bdy)));
      case('max')
       t2all(nti)=max(max(t2(bdy+1:end-bdy,bdy+1:end-bdy)));
      case('min')
       t2all(nti)=min(min(t2(bdy+1:end-bdy,bdy+1:end-bdy)));
      end %switch   
    end %if exist
  end %tmi
end %ti