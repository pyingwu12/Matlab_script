clear all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')

file1='/work/scyang/WPS/met_em.d01.2006-09-14_00:00:00.nc';
file2='/work/scyang/WRFV2/test/em_real/wrfinput_d01';
%file2='/work/ailin/WPS/met_em/met_em.d01.2006-09-14_00:00:00.nc';
%file2='/work/ailin/WPS/met_em.d01.2006-09-14_00:00:00.nc';
S1=netcdf_var(file1,'PSFC',0);
lon=squeeze(netcdf_var(file1,'XLONG_M',0));
lat=squeeze(netcdf_var(file1,'XLAT_M',0));
S2=netcdf_var(file2,'PSFC',0);
subplot(2,2,1)
contourf(lon,lat,squeeze(S1*1.e-4),[9.8:0.02:10.2]);
caxis([9.8 10.2])
subplot(2,2,2)
contourf(squeeze(S2*1.e-4),[9.8:0.02:10.2]);
caxis([9.8 10.2])
subplot(2,2,3)
contourf(squeeze((S1-S2)*1.e-4));
