%function TPW_sprd(hr,expri)
clear
hr=2:6;  expri='nodafcst'; 

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat';  %cmap=colormap_qr2([1 3 5 6 8 9 10 11 13 14 15 16 17],:);
cmap=colormap_qr2;
%----set---- 
vari='QVAPOR';   filenam=[expri,'_',vari,'-pro_']; 
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
date=16;
%----
L=[0.5 1 3 5 7 9 11 13 15 18 22 26 30 35 40 80];
plon=[117.5 123]; plat=[20.5 25.8];
zgi=[10,50,100:100:14000]';  g=9.81;
latp=23; lonp=120.5;
%----
for ti0=hr
%---set filename---
   hrday=fix(ti0/24);  ti=ti0-24*hrday;  s_date=num2str(date+hrday);    %%%
   if ti<10;  s_hr=['0',num2str(ti)];  else  s_hr=num2str(ti);  end   %%%      
   infile=[indir,'/wrfout_d03_2008-06-',s_date,'_',s_hr,':00:00'];   
%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,vari);     q.ori  =double(netcdf.getVar(ncid,varid))*1000;
   varid  =netcdf.inqVarID(ncid,'PH');       ph =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'U');        u.stag  =netcdf.getVar(ncid,varid);
   netcdf.close(ncid) 
%---
   
   [nx ny nz]=size(q.ori);
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   %
   dis= ( (y-latp).^2 + (x-lonp).^2 );
   [mid mxI]=min(dis);
   [dmin yp]=min(mid);
   xp=mxI(yp); 
   %
   P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)./g;
   q.flux=q.ori.*u.unstag;   
   var=q.flux;
%---interpolation to z-axis----
   for j=1:ny
     X=squeeze(zg(xp,j,:));
     Y=squeeze(var(xp,j,:));
     var_prof(:,j)=interp1(X,Y,zgi,'linear');
   end
%---plot---
   plotvar=var_prof;   plotvar(plotvar==0)=NaN;
   [xi zi]=meshgrid(y(xp,:),zgi);
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
      %
   figure('position',[200 100 700 500])
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none'); hold on
   cm=colormap(cmap);   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
      %
   plot(y(xp,:),hgt(xp,:),'k','LineWidth',1.5);
   set(gca,'XLim',[20 27],'fontsize',13,'LineWidth',1)      
   xlabel('latitude'); ylabel('height(m)')
      %
   tit=[expri,'  ',vari,'  ',s_hr,'z  ( ',num2str(mean(x(xp,:))),'°E )'];
   title(tit,'fontsize',15)
   %outfile=[outdir,filenam,'profsn_',s_hr,'_',type,'.png'];
   %print('-dpng',outfile,'-r400')   

end 
