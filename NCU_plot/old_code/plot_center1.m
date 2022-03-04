clear
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
%load '/work/pwin/data/heighti.mat';

%-----------set filename---------------------------
h=18;
 if h==24
  date='09';
  hr='00';
 else
  date='08';   
  hr=num2str(h);
 end
 infile=['/SAS004/pwin/wrfout_morakot_d03enMR15/wrfout_d03_2009-08-',date,'_',hr,':00:00_01'];   
ncid = netcdf.open(infile,'NC_NOWRITE');
% 
varid  =netcdf.inqVarID(ncid,'Times');
 time=netcdf.getVar(ncid,varid);
varid  =netcdf.inqVarID(ncid,'XLONG');
 lon =netcdf.getVar(ncid,varid);
 x=double(lon);
varid  =netcdf.inqVarID(ncid,'XLAT');
 lat =netcdf.getVar(ncid,varid);
 y=double(lat);    
varid  =netcdf.inqVarID(ncid,'LANDMASK');  %land or not
 landm =netcdf.getVar(ncid,varid) ;
 landm=double(landm);  
 
for i=1:40;    
   
   en=num2str(i);
   if i<=9
    infile=['/SAS004/pwin/wrfout_morakot_d03enMR15_1500/wrfout_d03_2009-08-',date,'_',hr,':00:00_0',en];
   else
    infile=['/SAS004/pwin/wrfout_morakot_d03enMR15_1500/wrfout_d03_2009-08-',date,'_',hr,':00:00_',en];
   end
% ------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
% 
   varid  =netcdf.inqVarID(ncid,'PH');  % perturbation geopotential
    ph  =netcdf.getVar(ncid,varid);     
   varid  =netcdf.inqVarID(ncid,'PHB'); % base-state geopotential
    phb =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'T');   % perturbation potential temperature (theta-t0)
    the =netcdf.getVar(ncid,varid);
    the=permute(the,[3 2 1]);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   % Water vapor mixing ratio
    qv =netcdf.getVar(ncid,varid);  
    qv=permute(qv,[3 2 1]);
   varid  =netcdf.inqVarID(ncid,'P');   % perturbation pressure
    p  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');  % BASE STATE PRESSURE
    pb =netcdf.getVar(ncid,varid);     


pre=p+pb;  %pressure
pre=permute(pre,[3 2 1]); %change dimension


zg0=(ph+phb)/9.81;  
zg=0.5*(zg0(:,:,1:end-1)+zg0(:,:,2:end)); %height
zg=permute(zg,[3 2 1]);

temp=wrf_tk(pre,300.0+the,'K'); %temperature (theta is perturbation, so add 300) 

slp0=calc_slp(pre,zg,temp,qv);
slp{i}=double(permute(slp0,[2 1]));
disp(['member',num2str(i),' is OK'])
end



save(['slp_',hr,'.mat'],'slp','x','y','landm')

