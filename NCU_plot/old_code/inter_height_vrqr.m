clear

hr=16; expri='MRcycle06';
indir=['/SAS002/pwin/expri_241/morakot_',expri];  %%%
%indir=['/SAS002/pwin/expri_241/morakot_newda_1518_vrzh_900'];  %%%


xrad=120.0860; yrad=23.1467; zrad=38;
%----set---- 
outdir=['/work/pwin/plot_cal/Corr./',expri,'/'];
height=1*10^3;
g=9.81;
%----
for ti=hr
   s_hr=num2str(ti);
%---set filename---    
   for mi=1:40
     nen=num2str(mi);
     if mi<=9
      infile=[indir,'/cycle0',nen,'/fcst_d03_2009-08-08_',s_hr,':00:00'];
      %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
     else
      infile=[indir,'/cycle',nen,'/fcst_d03_2009-08-08_',s_hr,':00:00'];
      %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
     end

%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'T');       t  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PSFC');      psfc0  =(netcdf.getVar(ncid,varid));
   %P=p+pb;
   varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'U');   u0  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'V');   v0  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'W');   w0  =(netcdf.getVar(ncid,varid));
%---
   [nx ny]=size(lon); nz=size(u0,3);
   u=(u0(1:nx,:,:)+u0(2:nx+1,:,:)).*0.5;
   v=(v0(:,1:ny,:)+v0(:,2:ny+1,:)).*0.5; 
   w=(w0(:,:,1:nz)+w0(:,:,2:nz+1)).*0.5;
%---
   %[nx ny nz]=size(t); %nz=size(qr,3);   
   P0=(phb+ph);
   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=PH/g;
   
   for i=1:nz; 
       psfc(:,:,i)=psfc0(:,:); 
       x3(:,:,i)=x(:,:); 
       y3(:,:,i)=y(:,:); 
   end
   
   temp=(300+t).*((p+pb)./1.e5).^(287/1005);
   den=(p+pb)./287./temp./(1+287.*qv./461.6);
   vt=(5.40*(psfc./pb).^0.4).*(den.*qr.*1.e3).^0.125;
   dis= ((x3-xrad).^2 + (y3-yrad).^2 + (zg-zrad).^2).^0.5 ;
   vr=(u.*(x3-xrad)+v.*(y3-yrad)+(w-vt).*(zg-zrad))./dis;
%---
%
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(vr(i,j,:));
     VR_1km(i,j,mi)=interp1(X,Y,height,'linear');
     Y=squeeze(qr(i,j,:));
     QR_1km(i,j,mi)=interp1(X,Y,height,'linear');
     end
   end
   %}
   netcdf.close(ncid)
   disp(['member ',nen,' OK'])
   end
   save([outdir,'bgrd_VRQR_1km_',s_hr],'x','y','VR_1km','QR_1km')
end
  