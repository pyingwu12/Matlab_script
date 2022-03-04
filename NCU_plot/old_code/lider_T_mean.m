clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_jet.mat'; cmap=colormap_jet;

expri='e02';   hr=0;  plothgt=10;   %lev=12;
s_date='26';

%----set---- 
vari='Temperature mean';   filenam=[expri,'_Temp-mean_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
L=[16 19 22 25 25.5 26 26.3 26.6 26.9 27.2 27.5 27.8];
%L=[25 25.3 25.6 25.9 26.2 26.5 26.8 27.1 27.4 27.7 28 28.3];
plon=[119.3 122.5]; plat=[21.7 25.5];   
s_mon='10';
xp=50; yp=86;

for ti=hr
%---set filename---    
   if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end     
   infile=[indir,'/wrfout_d02_2016-10-',s_date,'_',s_hr,':00:00_mean'];     
  %----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'T');        theta   =netcdf.getVar(ncid,varid)+300;   
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'P');        p  =netcdf.getVar(ncid,varid)./100;
   varid  =netcdf.inqVarID(ncid,'PB');       pb =netcdf.getVar(ncid,varid)./100; 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
%-------
   kappa=0.286; %(R/cp)
   P=p+pb;
   T=theta.* ((P./1000).^kappa);   T=T-273;
%----
   [nx ny nz]=size(theta);
   g=9.81;
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)/g;   
   %---interpolation to 1km-height
   %hgt.iso=zeros(nx,ny)+plothgt;  
   hgt.iso=double(hgt.m)+plothgt;  
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(T(i,j,:));  var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
     end
   end     
   var.plot=var.iso;
%---plot
   pmin=double(min(min(var.plot)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,var.plot,L2);   set(hp,'linestyle','none'); hold on
   hx=m_plot(x(xp,yp),y(xp,yp),'xk','LineWidth',2,'MarkerSize',9);
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   cm=colormap(cmap);   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
%---
   tit=[expri,'  ',vari,'  ',s_mon,'/',s_date,' ',s_hr,'z  (',num2str(plothgt),'m)'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_date,s_hr,'_',num2str(plothgt),'.png'];
   print('-dpng',outfile,'-r400')  
end
