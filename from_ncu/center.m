function [locx locy]=center(ncid)

   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);  
   varid  =netcdf.inqVarID(ncid,'LANDMASK');  %land or not
    landm =netcdf.getVar(ncid,varid) ;
    landm=double(landm);  
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
%---cal SLP
   pre=p+pb;  %pressure
   pre=permute(pre,[3 2 1]); %change dimension

   zg0=(ph+phb)/9.81;  
   zg=0.5*(zg0(:,:,1:end-1)+zg0(:,:,2:end)); %height
   zg=permute(zg,[3 2 1]);

   temp=wrf_tk(pre,300.0+the,'K'); %temperature (theta is perturbation, so add 300) 

   slp0=calc_slp(pre,zg,temp,qv);
   slp=double(permute(slp0,[2 1]));
%---Find center
   slp(landm>0)=NaN;
   xr=[118 121];   yr=[24 27];   
   xg=x(x>=xr(1)& x<=xr(2) & y>=yr(1) & y<=yr(2)); 
   yg=y(x>=xr(1)& x<=xr(2) & y>=yr(1) & y<=yr(2));
   slp=slp(x>=xr(1)& x<=xr(2) & y>=yr(1) & y<=yr(2));
 
   [mslp mI]=min(slp);
   locx=xg(mI);
   locy=yg(mI);

end
   
  

  
  
