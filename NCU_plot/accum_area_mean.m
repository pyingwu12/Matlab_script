function mrain=accum_area_mean(year,mon,date,s_datexp,sth,expri,araid)

%clear;  
%year='2012';  mon='06';  date=10;  s_datexp='10'; sth=12:23;   expri='obs';   araid=1;    

dom='02';  
%
if strcmp(expri,'obs')==1; moidx=0; else moidx=1; end             
switch(moidx)
 case(0)  %!!!!!!!!!!!!!!!!!
   %infile='/SAS007/pwin/expri_sz6414/szvrzh124/wrfout_d03_2008-06-16_02:00:00';
   %infile='/SAS009/pwin/expri_whatsmore/vr124/wrfout_d01_2012-06-10_12:00:00';    
   infile='/SAS007/pwin/expri_largens/WRF_shao/wrfout_d02_2008-06-15_18:00:00';
 case(1)
   %indir=['/SAS007/pwin/expri_sz6414/',expri];
   %indir=['/SAS009/pwin/expri_whatsmore/',expri]; 
   indir=['/SAS009/pwin/expri_largens/',expri]; 
   %
   s_date=num2str(date,'%2.2d');   s_hr=num2str(sth(1),'%2.2d'); 
   infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
end
%
%---read model land data---
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'XLONG');     lon =netcdf.getVar(ncid,varid);   x=double(lon);
varid  =netcdf.inqVarID(ncid,'XLAT');      lat =netcdf.getVar(ncid,varid);   y=double(lat);
varid  =netcdf.inqVarID(ncid,'LANDMASK');  land=double(netcdf.getVar(ncid,varid)); 
land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;   land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
%---chose area-------
if     araid==0;  xmi=120;     xma=122.1;   ymi=21.8;   yma=25.4;     % all taiwan
elseif araid==1;  xmi=120.8;   xma=121.35;  ymi=23.95;  yma=24.45;    % what 1
%elseif araid==1;  xmi=120.95;  xma=121.24;  ymi=24.05;  yma=24.35;    % what 1 by what
elseif araid==2;  xmi=120.5;   xma=121.05;  ymi=22.95;  yma=23.6;     % what 2
%elseif araid==2;  xmi=120.62;  xma=120.95;  ymi=23;     yma=23.4;     % what 2 by what
elseif araid==3;  xmi=120.5;   xma=121.05;  ymi=22.3;   yma=22.94;    % what 3
%elseif araid==3;  xmi=120.6;   xma=120.9;  ymi=22.58;   yma=22.95;    % what 3 by what
    
elseif araid==4;  xmi=120;     xma=121;     ymi=22;     yma=23.5;      % SW py
elseif araid==5;  xmi=120;     xma=120.7;   ymi=22.4;   yma=23.4;      % SW sz
elseif araid==6;  xmi=121.15;  xma=121.55;  ymi=24.7;   yma=25;        % IOP8 north
end

%---
mrain=zeros(length(sth),1);
nti=0;
for ti=sth 
  nti=nti+1;  
  switch(moidx)  
   case(1)
     for j=1:2;
       %---set file name---  
       hr=(j-1)+ti;
       hrday=fix(hr/24);  hr=hr-24*hrday;    
       s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
       infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
       %---read data--------
       ncid = netcdf.open(infile,'NC_NOWRITE');
       varid  =netcdf.inqVarID(ncid,'RAINC');    rc{j}  =netcdf.getVar(ncid,varid);
       varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc{j} =netcdf.getVar(ncid,varid);
       netcdf.close(ncid);
     end     
     rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
     acci=rain;
     %-----tick sea and let <0 =0 -----
     acci(land==0 | x<120)=NaN;   acci(acci<0)=0;        
   case(0)
     hr1=ti;    hrday=fix(hr1/24);  
     hr1=hr1-24*hrday;    r_hr1=num2str(hr1,'%2.2d');      
     hr2=mod(ti+1,24);    r_hr2=num2str(hr2,'%2.2d');      
     r_date=num2str(date+hrday,'%2.2d');
     infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/', ...
                            year,mon,r_date,'_',r_hr1,r_hr2,'_raingauge.dat']; 
     A=importdata(infile);  acc=A(:,3);  lon=A(:,1);  lat=A(:,2);
     acc(acc<0)=NaN;     
     lon=lon(isnan(acc)==0); lat=lat(isnan(acc)==0); acc=acc(isnan(acc)==0);        
     %---interpolate and land---   
     acci=griddata(lon,lat,acc,x,y,'cubic');
     acci(land==0 | x<120)=NaN;   acci(acci<0)=0;   
  end
   
  acci=acci(isnan(acci)==0 & x>=xmi & x<=xma & y>=ymi & y<=yma);
  if isempty(acci==1); mrain(nti)=0;  else  mrain(nti)=mean(mean(acci));   end    
end


