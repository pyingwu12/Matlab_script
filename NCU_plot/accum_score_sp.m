function [scc rmse ETS bias]=accum_score_sing(sth,acch,expri,araid,tresh)
% sth: start time
% acch: accumulation time
% expri: experiment name
% tresh: tresh for ETS and bias

%clear; sth=2; acch=5; expri='e11'; araid=4;  tresh=15; 
%---set
dom='02'; year='2008'; mon='06'; date=16;  s_datexp='16';    % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];     % path of the experiments
%indir=['/SAS009/pwin/expri_cctmorakot/',expri];
%indir=['/SAS009/pwin/expri_morakotEC/',expri];
%indir=['/SAS002/pwin/expri_241/morakot_sing_',expri];
%indir=['/SAS009/pwin/expri_whatsmore/',expri];
%indir=['/SAS007/pwin/expri_sz6414/',expri];
indir=['/SAS009/pwin/expri_largens/',expri];
%---
if araid==1;      xmi=120.8;   xma=121.35;  ymi=23.95;  yma=24.45; 
elseif araid==2;  xmi=120.5;   xma=121.05;  ymi=22.95;  yma=23.6; 
elseif araid==3;  xmi=120.5;   xma=121.05;  ymi=22.3;   yma=22.94;
    
elseif araid==4;  xmi=120;     xma=121;     ymi=22;     yma=23.5; 
elseif araid==5;  xmi=120;     xma=120.7;   ymi=22.4;   yma=23.4; 
elseif araid==6;  xmi=121.15;  xma=121.55;  ymi=24.7;   yma=25; 
end

%---
nt=0;
for tri=tresh
 for ti=sth;
  for ai=acch;
    nt=nt+1;    
%===wrf---set filename---
    for j=1:2;
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;    
      s_date=num2str(date+hrday,'%2.2d');     s_hr=num2str(hr,'%2.2d');   %%%    
      infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
%---read netcdf data--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'RAINC');    rc{j}  =double(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc{j} =double(netcdf.getVar(ncid,varid));      
      if j==1
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
    wrfacci=rain;    
%---obs--------
    for j=1:ai+2       %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FOR PAPER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
      hr1=ti+j-1;    hrday=fix(hr1/24);  
      hr1=hr1-24*hrday;    r_hr1=num2str(hr1,'%2.2d');      
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
    obsacci=griddata(lon,lat,acc,x,y,'cubic');
    obsacci(land==0 | x<120)=NaN;  obsacci(obsacci<0)=0;
%-----score-------------   
    if araid~=0;  fin=find(isnan(obsacci) ==0 & isnan(wrfacci)==0 & x>xmi & x<xma & y>ymi & y<yma);
    else          fin=find(isnan(obsacci) ==0 & isnan(wrfacci)==0);    end
    [scc(nt) rmse(nt) ETS(nt) bias(nt)]=score(obsacci(fin),wrfacci(fin),tri) ;
  end % ai=acch
 end %ti=sth
end %tresh
