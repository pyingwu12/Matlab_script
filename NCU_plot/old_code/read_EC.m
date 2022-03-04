
infile='/SAS010/pwin/20120610-11.nc';

ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'longitude');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
varid  =netcdf.inqVarID(ncid,'latitude');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
varid  =netcdf.inqVarID(ncid,'d');     div =double(netcdf.getVar(ncid,varid));
div=(div.*1.03060734799443e-08 +  1.87634415635203e-05).*10^-5;
varid  =netcdf.inqVarID(ncid,'u');     u =double(netcdf.getVar(ncid,varid));
u=u.*0.00304756154655026 + 46.9444295883673;
varid  =netcdf.inqVarID(ncid,'v');     v =double(netcdf.getVar(ncid,varid));
v=v.*0.00207261403382289 + 3.69694648106903;
varid  =netcdf.inqVarID(ncid,'z');     z =double(netcdf.getVar(ncid,varid));
z=z.*7.5451769647544 + 242735.061395893;
g=9.81;  zg=z(:,:,finlevel,tint)./g;
varid  =netcdf.inqVarID(ncid,'q');     q =double(netcdf.getVar(ncid,varid));
q=(q.*3.94924975746902e-07 + 0.0129293396636954).*1000;
varid  =netcdf.inqVarID(ncid,'level');     level =netcdf.getVar(ncid,varid);    
[yj xi]=meshgrid(y,x);
save('/work/pwin/plot_cal/what/EC.m','xi','yj','div','u','v','zg','q')