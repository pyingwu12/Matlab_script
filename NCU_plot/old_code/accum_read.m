function accum_read(sth,acch,expri,expid,saveid)
% sth: start time
% acch: accumulation time
% expri: experiment name
% saveid: 1-for calculate score, 2-for plot, 3-both
load '/work/pwin/data/heighti.mat';
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---set---
if expid==1; indir=['/SAS004/pwin/wrfout_morakot_',expri];
elseif expid==2; indir=['/SAS002/pwin/expri_241/morakot_en_',expri]; end
outdir=['/work/pwin/plot_cal/Rain/',expri];
%---
for ti=sth
  s_sth=num2str(ti);
  for ai=acch
%===wrf---set filename---
    for mi=1:40;
      for j=1:2;
        hr=(j-1)*ai+ti;
        if hr==24
         s_date='09';  s_hr='00';
        else
         s_date='08';  s_hr=num2str(hr);
        end       
        nen=num2str(mi);
        if mi<=9
         if expid==1; infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
         elseif expid==2; infile=[indir,'/pert0',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];  end
        else
         if expid==1; infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
         elseif expid==2; infile=[indir,'/pert',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];  end
        end
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
%---interpolate and land---
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
      wrfacci{mi}=griddata(x,y,rain,xi,yj,'cubic');
      wrfacci{mi}(isnan(heighti)==1 | heighti<0)=NaN;  wrfacci{mi}(wrfacci{mi}<0)=0;        
%------------    
    netcdf.close(ncid)
    end % Member
%----    
    if saveid==1 || saveid==3
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
      obsacci(isnan(heighti)==1 | heighti<=0 )=NaN;  obsacci(obsacci<0)=0;
%       for j=1:81
%         for k=1:41
%           if heighti(j,k)<=0. || isnan(heighti(j,k))==1 || obsacci(j,k)<0
%            obsacci(j,k)=NaN;
%           end
%         end
%       end    
      save([outdir,'/obs_acci_',s_sth,s_hr,'.mat'],'wrfacci','obsacci')
    end
%-------  
    if saveid==2 || saveid==3 
      acci=wrfacci;
      save([outdir,'/acci_',s_sth,s_hr,'.mat'],'acci','xi','yj')
    end
    disp([expri,'"s ',s_sth,s_hr,'Z done'])
  end % accumulation interval
end % start hour

%end