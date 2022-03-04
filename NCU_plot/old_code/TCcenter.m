clear
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
%load '/work/pwin/data/heighti.mat';


expri='MRcycle09'; expid=2;
if expid==1; indir=['/SAS004/pwin/wrfout_morakot_',expri];
elseif expid==2; indir=['/SAS002/pwin/expri_241/morakot_en_',expri]; end


%-----------set filename---------------------------
h=17;

 if h==24
  s_date='09';
  s_hr='00';
 else
  s_date='08';   
  s_hr=num2str(h);
 end
 infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_mean'];
 
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
 
for mi=1:40;    
   
   nen=num2str(mi);
    if mi<=9
     if expid==1; infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
     elseif expid==2; infile=[indir,'/pert0',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];  end
    else
     if expid==1; infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
     elseif expid==2; infile=[indir,'/pert',nen,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];  end
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
slp{mi}=double(permute(slp0,[2 1]));
disp(['member',num2str(mi),' is OK'])
end



save(['slp_',s_hr,'.mat'],'slp','x','y','landm')



