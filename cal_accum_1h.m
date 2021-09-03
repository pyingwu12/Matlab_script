function acci=cal_accum_1h(dir,expri,ymd,sth,minu,lenh,dom,bdy,typst,ccc)
%ccc defult ":"  

%expri='test38'; time='2018062100'; sth=18;  lenh=4;  dom='01'; typst='mean';

indir=[dir,'/',expri]; 
%---setting
if isempty(ccc); ccc=':'; end
year=ymd(1:4); mon=ymd(5:6); stday=str2double(ymd(7:8)); %s_min=ymd(9:10);
infilenam='wrfout'; 

acci=size(lenh*length(minu),1); nti=0;

for ti=1:lenh
  for tmi=minu
    nti=nti+1;
    rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2); exi=0;  
    s_min=num2str(tmi,'%2.2d');
    for j=1:2
      hr=(j-1)*1+ti+sth-1;  s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
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
      acci(nti)=NaN; 
    else           
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
      switch(typst)
      case('mean')
        acci(nti)=mean(mean(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
      case('sum')
        acci(nti)=sum(sum(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
      case('max')
        acci(nti)=max(max(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
      end
    end  
  end % tmi
end %ti