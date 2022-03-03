function incr_mean=TPWqx_incr_mean(hm,expri,vari,dom,day)

%expri='e02';  vari='QVAPOR';
%hm=['00:00';'00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00'];
year=day(1:4); mon=day(5:6); date=day(7:8);    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  
%
num=size(hm,1);  g=9.81; 
incr_mean=zeros(1,num);

%----
for ti=1:num;
%---set time and filename---    
   time=hm(ti,:);
%---set filename---
   infile1=[indir,'/output/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqDimID(ncid,'bottom_top');    [~, nz]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,vari);      qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
  %---integrate TPW---
   P=(pb+p);  
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
   TPW1=sum(tpw,3)./g;
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,vari);      qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
  %---integrate TPW---
   P=(pb+p);   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
   TPW2=sum(tpw,3)./g; 
%------------------    
   incr=TPW2-TPW1;      
   incr_mean(ti)=mean(mean(incr)); 
end    
