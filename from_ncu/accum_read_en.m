function [acci x y]=accum_read_en(ti,ai,expri,ensize,seaid)
%----------------------------
% Read ensemble rainfall data for a specific accumulation interval
%----------------------------
% clear  
%  expri='e18_ensfcst_0020';  ensize=36; seaid=1;
% ti=00; ai=12;

%---experimental setting---
indir=['/SAS004/pwin/wrfout/wrfout_morakot_',expri];
%indir=['/SAS007/pwin/expri_sz6414/',expri];
%indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_',expri];       % path of the experiments
%indir=['/SAS009/pwin/expri_largens/',expri];
%indir=['/SAS007/sz6414/IOP8/Goddard/forecast/',expri];
dom='03'; year='2009'; mon='08'; date=08;    % time setting
dirnam='pert';

%load '/work/pwin/data/heighti.mat';   [xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);

%===wrf---set filename---
for mi=1:ensize;
  for j=1:2; 
    hr=(j-1)*ai+ti;
    hrday=fix(hr/24);  hr=hr-24*hrday;    
    s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
    %nen=num2str(mi,'%.3d');  
    nen=num2str(mi,'%.2d');  
    %infile=[indir,'/',dirnam,nen,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00']; 
    infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00_',nen]; 
%------read netcdf data--------
    ncid = netcdf.open(infile,'NC_NOWRITE');
    varid  =netcdf.inqVarID(ncid,'RAINC');       rc{j}  =netcdf.getVar(ncid,varid); 
    varid  =netcdf.inqVarID(ncid,'RAINNC');      rnc{j} =netcdf.getVar(ncid,varid); 
    netcdf.close(ncid)
  end
  if mi==1
  ncid = netcdf.open(infile,'NC_NOWRITE');
  varid  =netcdf.inqVarID(ncid,'XLONG');      lon =netcdf.getVar(ncid,varid);   x=double(lon);
  varid  =netcdf.inqVarID(ncid,'XLAT');       lat =netcdf.getVar(ncid,varid);   y=double(lat);
  varid  =netcdf.inqVarID(ncid,'LANDMASK');   land =netcdf.getVar(ncid,varid);  
  % make lakes on the land land
  land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
  land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;   land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
  netcdf.close(ncid)
  end  
%-----tick sea and let <0 =0------
  rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
  if seaid==0;  rain(land==0 | x<120)=NaN;  end
  rain(rain<0)=0;   acci{mi}=rain;    
  % acci=0 cannot be NaN, cause the function calPM.m assume the lenght of NaN is the same
  %------

end % Member
