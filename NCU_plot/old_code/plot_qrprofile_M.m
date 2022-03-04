clear
%close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
load '/work/pwin/data/colormap_qr.mat'   
%-----------set filename---------------------------
type='mean';  clim=[0 2.5];
expri='MR15';   vari='qrain profile';   filenam='MR15_qrpro_';  
hm='19:00';  %time
num=size(hm,1);
%---
for ti=1:num;
   time=hm(ti,:);
   infile=['/SAS004/pwin/wrfout_morakot_MR15_1500/wrfout_d03_2009-08-08_',time,':00_mean'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');   
   varid  =netcdf.inqVarID(ncid,'Times');
   wrftime=netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');
   lon =netcdf.getVar(ncid,varid);   x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
   lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');
   qr  =(netcdf.getVar(ncid,varid))*10^3;
   nx=size(qr,1); ny=size(qr,2);
%------  
   pro=95; range=45:135;
   zlen=size(qr,3);
   [yy zz]=meshgrid(1:zlen,y(pro,:));
   figure('position',[500 100 600 500])
   [c hp]=contourf(zz(range,1:18),yy(range,1:18),squeeze(qr(pro,range,1:18)));
   set(hp,'linestyle','none');
   hc=colorbar;    caxis(clim);   cm=colormap(colormap_qr);
   tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',type,')'];
   title(tit,'fontsize',15)
   outfile=[filenam,time(1:2),time(4:5),'_',type,'.png'];
   saveas(gca,outfile,'png'); 
%}
end