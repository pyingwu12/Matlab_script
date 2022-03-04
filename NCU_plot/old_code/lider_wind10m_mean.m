clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_wind.mat';  cmap=colormap_wind([1 3 5 6 8 10 11 12 13 14 15 17],:);
 
expri='e02';  hr=0; s_date='26';

vari='10m wind mean';   filenam=[expri,'_wind10m_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
L=[0.05  1 1.3  1.6 2  2.5 3  3.5 4  4.5 5];
plon=[119.3 122.5]; plat=[21.7 25.5];
%
for ti=hr
%---set filename---    
   if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end    
   infile=[indir,'/wrfout_d02_2016-10-',s_date,'_',s_hr,':00:00_mean'];  
  %----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');       u.stag  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'V');       v.stag  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');     hgt.m =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
%---
   [nx ny]=size(x); 
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;       
   %sp=(u.unstag.^2+v.unstag.^2).^0.5;   
   %---
   g=9.81;  nz=size(ph,3)-1;
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)/g;   
   %
   hgt.iso=double(hgt.m)+10;    
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(u.unstag(i,j,:));    u.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'pchip');
     Y=squeeze(v.unstag(i,j,:));    v.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'pchip');
     end
   end
   sp.iso=(u.iso.^2+v.iso.^2).^0.5;  
   
   %}   
%---plot
   int=6;
   xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
   u.plot=u.iso(1:int:nx,1:int:ny,:);   v.plot=v.iso(1:int:nx,1:int:ny,:);       
   %
   plot.var=sp.iso;   plot.var(plot.var==0)=NaN;
   pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,sp.iso,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   cm=colormap(cmap);%([2 4 5 6 7 8 10 11 12 13 14 16],:));   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
   hold on
%---vector & legend---
qscale = 0.03 ; % scaling factor for all vectors
h1 = m_quiver(xi,yi,u.plot,v.plot,0,'k') ; % the '0' turns off auto-scaling
hU = get(h1,'UData') ;
hV = get(h1,'VData') ;
set(h1,'UData',qscale*hU,'VData',qscale*hV)
   set(h1,'LineWidth',1.2)
%---
   tit=[expri,'  ',vari,'  ',s_date,'-',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_date,s_hr,'.png'];
   print('-dpng',outfile,'-r400')    
end
