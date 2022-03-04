clear
sth=15; acch=1; expri='MRcycle03';
% sth: start time
% acch: accumulation time
% expri: experiment name
% saveid: 1-for calculate score, 2-for plot, 3-both
load '/work/pwin/data/heighti.mat';
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---set---
indir=['/SAS002/pwin/expri_241/morakot_sing_',expri,'_1521'];
%---
for ti=sth
  s_sth=num2str(ti);
  for ai=acch
%===wrf---set filename---
      for j=1:2;
        hr=(j-1)*ai+ti;
        if hr==24
         s_date='09';  s_hr='00';
        else
         s_date='08';  s_hr=num2str(hr);
        end       
        infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];
%------read netcdf data--------
        ncid = netcdf.open(infile,'NC_NOWRITE');
        varid  =netcdf.inqVarID(ncid,'XLONG');
         lon =netcdf.getVar(ncid,varid);
         x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');
         lat =netcdf.getVar(ncid,varid);
         y=double(lat);
        varid  =netcdf.inqVarID(ncid,'RAINC');
         rc{j}  =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'RAINNC');
         rnc{j} =netcdf.getVar(ncid,varid);
      end
%-----interpolation------
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
      wrfacci=griddata(x,y,rain,xi,yj,'cubic');
%-----land-----
      for j=1:81
        for k=1:41
          if heighti(j,k)<=0. || isnan(heighti(j,k))==1 
           wrfacci(j,k)=NaN;
          elseif wrfacci(j,k)<0
           wrfacci(j,k)=0;   
          end
        end
      end
%------------    
    netcdf.close(ncid)
%----    
%===obs===read and add data
      for j=1:ai
        hr1=num2str(ti+j-1);
        if ti+j==24; hr2='00'; else hr2=num2str(ti+j); end      
        infile=['/work/pwin/data/raingauge_new_1hr_20090808/20090808',hr1,hr2,'_raingauge.dat'];
        A=importdata(infile);  obsrain(:,j)=A(:,3);
        fin= obsrain(:,j)<0; obsrain(fin,j)=0;
      end
      acc=sum(obsrain,2);
      lat=A(:,1);  lon=A(:,2);
%---interpolate and land---
      obsacci=griddata(lon,lat,acc,xi,yj,'cubic');
      for j=1:81
        for k=1:41
          if heighti(j,k)<=0. || isnan(heighti(j,k))==1 || obsacci(j,k)<0
           obsacci(j,k)=NaN;
          end
        end
      end
%-------
      fin=find(isnan(obsacci) ==0 & isnan(wrfacci)==0 & wrfacci>=0 & obsacci>=0);
      [scc rmse]=score(obsacci(fin),wrfacci(fin))
%-------
  end % accumulation interval
end % start hour
