clear; 
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_sprd.mat'; cmap=colormap_sprd;

expri='e02';  s_date='26';   hr=6;  
%----set---- 
vari='PBLH spread';   filenam=[expri,'_PBLH-sprd_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
%---
L=[70 80 90 100 120 140 160 180 200 220 240 260 280 300];
plon=[119.3 122.5]; plat=[21.7 25.5];  
s_mon='10';
%xp=72; yp=131;
xp=50; yp=86;

for ti=hr
%---set filename---    
   if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end   
   for mi=1:40  
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/pert0',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     else
       infile=[indir,'/pert',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     end        
  %----read netcdf data--------
     ncid = netcdf.open(infile,'NC_NOWRITE');
     if mi==1;
     varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
     varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
     [nx ny]=size(x);
     end
     varid  =netcdf.inqVarID(ncid,'PBLH');     pblh=double(netcdf.getVar(ncid,varid));
     PBLH(:,mi)=reshape(pblh,nx*ny,1); 
%---
   netcdf.close(ncid)
   end %member
   %
   sprd.line=spread(PBLH);
   sprd.resh=reshape(sprd.line,nx,ny);
   var.plot=sprd.resh;
%---plot
   pmin=double(min(min(var.plot)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,var.plot,L2);   set(hp,'linestyle','none'); hold on
   %hx=m_plot(x(xp,yp),y(xp,yp),'xk','LineWidth',2,'MarkerSize',9);
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);   
   cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
%---
   tit=[expri,'  ',vari,'  ',s_mon,'/',s_date,' ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_mon,s_date,s_hr,'.png'];
   print('-dpng',outfile,'-r400')   
end
%} 

