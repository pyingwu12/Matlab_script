clear 


addpath('/work/pwin/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat';  %cmap=colormap_qr2; 
cmap=colormap_qr2([1 3 5 8 9 10 11 13 14 15 16],:); %cmap(1,:)=[1 1 1];

%---set---
hr=0;    expri='FNL-re-analysis';   %lev=8;%(wind level)   

vari='TPW';    filenam=[expri,'_tpw_'];   
indir='/SAS004/pwin/data/fnl';
outdir='/work/pwin/plot_cal/what/';
s_date='08';
%----
plon=[100 130]; plat=[10 35];
L=[10 20 30 40 50 55 60 64 68 72];

for ti=hr;
%===wrf---set filename---
   if ti<10;  s_hr=['0',num2str(ti)];  else  s_hr=num2str(ti); end
      infile=[indir,'/fnl_201206',s_date,'_',s_hr,'_00.nc'];
     
    ncid = netcdf.open(infile,'NC_NOWRITE');
    varid  =netcdf.inqVarID(ncid,'lon_0');    lon =netcdf.getVar(ncid,varid);
    varid  =netcdf.inqVarID(ncid,'lat_0');    lat =netcdf.getVar(ncid,varid);
    [x y]=meshgrid(lon,lat);  % mesh of 2-d grid point  
    varid  =netcdf.inqVarID(ncid,'PWAT_P0_L200_GLL0');    TPW =netcdf.getVar(ncid,varid);
   
   %---plot
   pmin=double(min(min(TPW)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[600 100 600 500])
   m_proj('mercator','lon',plon,'lat',plat)
   [c hp]=m_contourf(x,y,TPW',L2);   set(hp,'linestyle','none'); hold on
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',104:6:128,'ytick',10:5:35);
   m_coast('color','k','LineWidth',0.9);
   %m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);     caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)   
%---
   tit=[expri,'  ',vari,'  06',s_date,' ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_date,s_hr,'.png'];
   print('-dpng',outfile,'-r400') 
   print([outfile,'.pdf'],'-dpdf')

end       