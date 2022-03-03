function vr=vr_cal_wrf2obs(ncid,x,y,radloc,lev,nx,ny,range)
%-------------------------------
%  calculate Vr on model grids for a radar located at <radloc>
%-------------------------------
   g=9.81;  R=6.37122e6;   
%------------
%   varid  =netcdf.inqDimID(ncid,'west_east');    [~, nx]=netcdf.inqDim(ncid,varid);
%   varid  =netcdf.inqDimID(ncid,'south_north');  [~, ny]=netcdf.inqDim(ncid,varid);
%   varid  =netcdf.inqVarID(ncid,'XLONG');    x =netcdf.getVar(ncid,varid,'double');
%   varid  =netcdf.inqVarID(ncid,'XLAT');     y =netcdf.getVar(ncid,varid,'double');
   varid  =netcdf.inqVarID(ncid,'U');        u.stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'V');        v.stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]);
   varid  =netcdf.inqVarID(ncid,'W');        w.stag =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 2 1]);
   varid  =netcdf.inqVarID(ncid,'QRAIN');    qr =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'P');        p = netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'PB');       pb =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'PH');       ph = netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 2 1]);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 2 1]);
   varid  = netcdf.inqVarID(ncid,'PSFC');    psfc =netcdf.getVar(ncid,varid,'double');
   varid  =netcdf.inqVarID(ncid,'T');        t = netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny 1 1]);
%  netcdf.close(ncid)
%--------
   u.unstag=( u.stag(1:end-1,:)+u.stag(2:end,:) ).*0.5;
   v.unstag=( v.stag(:,1:end-1)+v.stag(:,2:end) ).*0.5;
   w.unstag=( w.stag(:,:,1)+w.stag(:,:,2) ).*0.5;
   P0=phb+ph;  PH=(P0(:,:,1)+P0(:,:,2)).*0.5;
   zg=PH/g;
   %
   temp=(300+t).*((p+pb)./1.e5).^(287/1005);
   den=(p+pb)./287./temp./(1+287.*qv./461.6);
   vt=(5.40*(psfc./pb).^0.4).*(den.*qr.*1.e3).^0.125;
%--------------------

   xrad=radloc(1);     yrad=radloc(2);   zrad=radloc(3); 
   xradd=xrad*pi/180;   yradd=yrad*pi/180;
      %
   xd=x*pi/180;  yd=y*pi/180;
   hdis = R * acos(sin(yd).*sin(yradd) + cos(yd).*cos(yradd).*cos(xd-xradd));
   xdis = R * acos(sin(yradd).*sin(yradd) + cos(yradd).*cos(yradd).*cos(xd-xradd));
   ydis = R * acos(sin(yd).*sin(yradd) + cos(yd).*cos(yradd).*cos(xradd-xradd));
   xdis(x<xrad)=-xdis(x<xrad);    ydis(y<yrad)=-ydis(y<yrad);
   dis= (hdis.^2 + (zg-zrad).^2).^0.5;
      %
   vr=(u.unstag.*(xdis)+v.unstag.*(ydis)+(w.unstag-vt).*(zg-zrad))./dis;
   vr(dis>range)=NaN;
   vr=real(vr);

