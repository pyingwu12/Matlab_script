clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_jet.mat'; cmap=colormap_jet;

expri='e02';   s_date='26';  hr=0;  
%----set---- 
vari='PBLH mean';   filenam=[expri,'_PBLH-mean_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
%--
L=[10 13 16 20 25 30 35 40 45 50 55 60]*10;
plon=[119.3 122.5]; plat=[21.7 25.5];  
s_mon='10';
%xp=72; yp=131;
xp=50; yp=86;

for ti=hr
%---set filename---    
   if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end
   infile=[indir,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00_mean']; 
   %----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PBLH');    pblh=(netcdf.getVar(ncid,varid));
   netcdf.close(ncid)
%---
   var.plot=pblh;
%---plot
   pmin=double(min(min(var.plot)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[200 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,var.plot,L2);   set(hp,'linestyle','none'); hold on
   caxis([L2(1) L(length(L))]) 
   cm=colormap(colormap_jet);    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1) 
   %
   hx=m_plot(x(xp,yp),y(xp,yp),'xk','LineWidth',2,'MarkerSize',9);
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);   
%---
   tit=[expri,'  ',vari,'  ',s_mon,'/',s_date,' ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_mon,s_date,s_hr,'.png'];
   print('-dpng',outfile,'-r400')   
   %}
end
