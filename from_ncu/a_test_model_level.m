

clear

hr=0;   minu='00';   expri='largens';   infilenam='wrfout';    

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; %---set
g=9.81;
memsize=100;

mem=randi([1 256],1,memsize);

zg=0; pre=0;
for mi=mem;
%---
   ti=hr;   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   nen=num2str(mi,'%.3d');
   infile=[indir,'/pert',nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   if mi==mem(1)
    varid  =netcdf.inqDimID(ncid,'south_north'); [~, ny]=netcdf.inqDim(ncid,varid);
    varid  =netcdf.inqDimID(ncid,'west_east');   [~, nx]=netcdf.inqDim(ncid,varid);
    varid  =netcdf.inqDimID(ncid,'bottom_top');  [~, nz]=netcdf.inqDim(ncid,varid);
    varid  =netcdf.inqVarID(ncid,'HGT');   hgt  =netcdf.getVar(ncid,varid);
   end
   varid  =netcdf.inqVarID(ncid,'P');   p  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');   ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');   pb  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');   phb  =netcdf.getVar(ncid,varid);
   netcdf.close(ncid) 
   
   P=(p+pb)*10^-2;  
   pre=pre+P/memsize;
   
   P0=phb+ph;  PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;   zg=zg+(PH./g)/memsize/1000;
        
end
  fin=find(hgt<=0.5 & hgt>=-0.5);
  
  zg=reshape(zg,nx*ny,nz);     zg=zg(fin,:);
  pre=reshape(pre,nx*ny,nz);   pre=pre(fin,:);
 
  p_level=mean(pre,1)';  
  z_level=mean(zg,1)';  
  
  
  