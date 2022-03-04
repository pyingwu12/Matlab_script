function iop8_accum_read(sth,acch,expri,saveid)
% sth: start time
% acch: accumulation time
% expri: experiment name
% saveid: 1-for calculate score, 2-for plot, 3-both
%clear; sth=2; acch=12; expri='truerun'; saveid=3;

%---set---
%indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_',expri];
indir='/SAS007/pwin/expri_sz6414/e18_ensfcst_0020';
outdir=['/work/pwin/plot_cal/IOP8/',expri];
memsize=36;
date=16;

%---
for ti=sth
  if ti<=10;  s_sth=['0',num2str(ti)];  else  s_sth=num2str(ti);  end
  for ai=acch
%===wrf---set filename---
    for mi=1:memsize;
      for j=1:2;
        hr=(j-1)*ai+ti;
        hrday=fix(hr/24);  hr=hr-24*hrday;  s_date=num2str(date+hrday);    %%%
        if hr<10;  s_hr=['0',num2str(hr)];  else  s_hr=num2str(hr);  end   %%%
        nen=num2str(mi);
        if mi<=9
          infile=[indir,'/pert0',nen,'/wrfout_d03_2008-06-',s_date,'_',s_hr,':00:00'];  
        else
          infile=[indir,'/pert',nen,'/wrfout_d03_2008-06-',s_date,'_',s_hr,':00:00']; 
        end
%------read netcdf data--------
        ncid = netcdf.open(infile,'NC_NOWRITE');
        varid  =netcdf.inqVarID(ncid,'XLONG');      lon =netcdf.getVar(ncid,varid);      x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');       lat =netcdf.getVar(ncid,varid);      y=double(lat);
        varid  =netcdf.inqVarID(ncid,'LANDMASK');   land =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'RAINC');      rc{j}  =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'RAINNC');     rnc{j} =netcdf.getVar(ncid,varid);
      end
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
%-----land-----          
      land(x>120.5 & x<120.8 & y>23.2 & y<23.5)=1;
      rain(land==0 | x<120)=NaN;  rain(rain<0)=0;
      wrfacci{mi}=rain;    
%-----
    netcdf.close(ncid)
    end % member
%----    
    if saveid==1 || saveid==3
%===obs===read and add data
      for j=1:ai
         %hour1=ti+j-1+8;
         %hrday=fix(hour1/24);  hour1=hour1-24*hrday;    s_date=num2str(date+hrday);    %%%
         %if hour1<=10;  hr1=['0',num2str(hour1)];  else hr1=num2str(hour1);  end   %%%
         hour2=ti+j+8;      
         hrday=fix(hour2/24);  hour2=hour2-24*hrday;  s_date=num2str(date+hrday);    %%%
         if hour2<=10;  hr2=['0',num2str(hour2)];  else  hr2=num2str(hour2);  end   %%%          
         %infile=['/SAS004/pwin/data/obs_rain/raingauge_20080614/200806',date,'_',hr1,hr2,'_raingauge.dat'];
         infile=['/SAS007/sz6414/IOP8/rain_obs/hrRain_200806',s_date,hr2,'.txt'];
         A=importdata(infile);  obsrain(:,j)=A(:,3);
         obsrain(obsrain(:,j)<0,j)=NaN;
      end
      acc=sum(obsrain,2);
      %lat=A(:,1);  lon=A(:,2); % for 06/14 obs
      lat=A(:,2);  lon=A(:,1);
      lon=lon(isnan(acc)==0); lat=lat(isnan(acc)==0); acc=acc(isnan(acc)==0);
%---interpolate and land---
      obsacci=griddata(lon,lat,acc,x,y,'cubic');
      obsacci(land==0 | x<120)=NaN;  obsacci(obsacci<0)=0;
      %----
      save([outdir,'/obs_acci_',s_sth,s_hr,'.mat'],'wrfacci','obsacci')
    end
%-------  
    if saveid==2 || saveid==3 
      acci=wrfacci;
      xi=x; yj=y;
      save([outdir,'/acci_',s_sth,s_hr,'.mat'],'acci','xi','yj')
    end
    disp([expri,'"s ',s_sth,s_hr,'Z done'])
  end % accumulation interval
end % start hour
%}
%end