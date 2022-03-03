clear


hr=3;

indir='/SAS002/zerocustom/TRMM/3hourly_3B42/'; outdir='/SAS011/pwin/201work/plot_cal/largens/';

addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';    cmap=colormap_rain;
L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300];

expri='TRMM';  varinam='accumulation rainfall';   filenam=[expri,'_accum_'];   

%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.3 121.8];  plat=[21 24.3];


%----
s_hr=num2str(hr,'%2.2d');
infile=[indir,'nc_3B42.20080616.',s_hr,'.7A.HDF.Z.nc'];
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'nlon');    lon =netcdf.getVar(ncid,varid,'double'); 
varid  =netcdf.inqVarID(ncid,'nlat');    lat =netcdf.getVar(ncid,varid,'double'); 
varid  =netcdf.inqVarID(ncid,'precipitation');    pre1 =netcdf.getVar(ncid,varid,'double'); 
%varid  =netcdf.inqVarID(ncid,'HQprecipitation');    preHQ =netcdf.getVar(ncid,varid,'double'); 
%varid  =netcdf.inqVarID(ncid,'IRprecipitation');    preIR =netcdf.getVar(ncid,varid,'double'); 
infile=[indir,'nc_3B42.20080616.06.7A.HDF.Z.nc'];
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'precipitation');    pre2 =netcdf.getVar(ncid,varid,'double'); 

acci=pre1+pre2;


[x y]=meshgrid(lon,lat);


%---plot---
plotvar=acci;   %plotvar(plotvar<=0)=NaN;
pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
 %
figure('position',[600 500 600 500])
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none'); 
%
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
%m_coast('color','k');
m_gshhs_h('color','k','LineWidth',0.8);
cm=colormap(cmap);    
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
%---
tit=[expri,'  ',varinam,'  ',s_hr,'z'];  
title(tit,'fontsize',15)
outfile=[outdir,filenam,s_hr];
%print('-dpng',outfile,'-r400') 
set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
system(['rm ',[outfile,'.pdf']]);    


