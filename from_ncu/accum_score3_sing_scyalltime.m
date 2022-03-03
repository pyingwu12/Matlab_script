function [POD SR]=accum_score3_sing_scyalltime(sth,acch,expri,tresh)
% sth: start time
% acch: accumulation time
% expri: experiment name
% tresh: tresh for ETS and bias

%clear; sth=[10 11 12]; acch=6; expri='BOTH';  tresh=15; 
%---set
dom='01'; year='2012'; mon='06'; date=10;  s_datexp='10';    % time setting
indir=['/SAS011/pwin/what_plot/',expri];
%---

%---
nt=0; ai=acch;
for tri=tresh
  nt=nt+1;    
%===wrf---set filename---
  for ti=sth
    s_ti=num2str(ti,'%2d');
  for j=1:2;
    hr=(j-1)*ai+ti;
    hrday=fix(hr/24);  hr=hr-24*hrday;    
    if date+hrday<10;  s_date=['0',num2str(date+hrday)];  else  s_date=num2str(date+hrday);  end
    s_hr=num2str(hr,'%2d'); 
    infile=[indir,num2str(ti,'%2d'),'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
%---read netcdf data--------
    ncid = netcdf.open(infile,'NC_NOWRITE');
    varid  =netcdf.inqVarID(ncid,'RAINC');    rc{j}  =double(netcdf.getVar(ncid,varid));
    varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc{j} =double(netcdf.getVar(ncid,varid));   
    if j==1;
     varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
     varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
     varid  =netcdf.inqVarID(ncid,'LANDMASK'); land =double(netcdf.getVar(ncid,varid));
    end
    netcdf.close(ncid);
  end  %j=1:2
  % make lakes on the land land 
  land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
  land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;   land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
  %
  rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});    
  rain(land==0 | x<120)=NaN;  rain(rain<0)=0;      
  eval(['wrfacci',s_ti,'=rain;']);    
%---obs--------
  for j=1:ai        
    %hr1=ti+j-1;    hrday=fix(hr1/24);  
    hr1=mod(ti+j-1,24);    r_hr1=num2str(hr1,'%2.2d');      
    hr2=mod(ti+j,24);    r_hr2=num2str(hr2,'%2.2d');      
    r_date=num2str(date+hrday,'%2.2d');
    infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/', ...
                          year,mon,r_date,'_',r_hr1,r_hr2,'_raingauge.dat']; 
    A=importdata(infile);  obsrain(:,j)=A(:,3);
    obsrain(obsrain(:,j)<0,j)=NaN;
  end        
  acc=sum(obsrain,2);   lon=A(:,1);  lat=A(:,2);
  lon=lon(isnan(acc)==0); lat=lat(isnan(acc)==0); acc=acc(isnan(acc)==0);
  %---interpolate and land---   
  acci=griddata(lon,lat,acc,x,y,'cubic');
  acci(land==0 | x<120)=NaN;  acci(acci<0)=0;
  eval(['obsacci',s_ti,'=acci;'])
  %eval(['fin',s_ti,'=find(isnan(obsacci',s_ti,') ==0 & isnan(wrfacci',s_ti,')==0);'])
  end %time
  wrfacci=cat(2,wrfacci10,wrfacci11,wrfacci12);
  obsacci=cat(2,obsacci10,obsacci11,obsacci12);
%-----score-------------   
  fin=find(isnan(obsacci) ==0 & isnan(wrfacci)==0);   
  [POD(nt) SR(nt)]=score3(obsacci(fin),wrfacci(fin),tri) ;
end %tresh
