%-------------------------------------------------------
% Caculate QXXXX(mixing ratio) flux integrated between low level (<2.5km/lev10)
% and plot the time series of North-Southen profile
%-------------------------------------------------------
clear
hr=2:8;  expri='vrzh128';  lev=10;  lon.line=120;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  %cmap=colormap_qr2([6 1 3 5 8 9 10 11 13 14 15 16 17],:); cmap(1,:)=[1 1 1];
cmap=colormap_rain;
%----set---- 
vari='QRAIN';   filenam=[expri,'_',vari,'-t_'];  
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
date=16;
%----
%L=[-40 -30 -20 -15 -10 -5 -1 1 5 10 20 30 40 50];
L=[1 3 6 10 14 18 22 26 30 35 40 45 50 55 60 65];
%L=[5 15 30 50 70 90 110 130 150 170 200 250 300 350 400 450];
g=9.81; 
 lat.line=23;
%---
tn=0;
for ti0=hr
   tn=tn+1;  
%---set filename---
   hrday=fix(ti0/24);  ti=ti0-24*hrday;  s_date=num2str(date+hrday);    %%%
   if ti<10;  s_hr=['0',num2str(ti)];  else  s_hr=num2str(ti);  end   %%%      
   infile=[indir,'/wrfout_d03_2008-06-',s_date,'_',s_hr,':00:00'];   
   if tn==1; s_hr0=s_hr; end
%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon.m =netcdf.getVar(ncid,varid);    x=double(lon.m);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat.m =netcdf.getVar(ncid,varid);    y=double(lat.m);
   varid  =netcdf.inqVarID(ncid,vari);     q.ori  =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');        p =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PB');       pb =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'U');        u.stag  =netcdf.getVar(ncid,varid);
   netcdf.close(ncid) 
%---    
   [nx ny nz]=size(q.ori);
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   %
   dis= ( (y-lat.line).^2 + (x-lon.line).^2 );
   [mid mxI]=min(dis);
   [dmin yp]=min(mid);
   xp=mxI(yp); 
   %
   q.flux=q.ori.*u.unstag;
   P=(pb+p);  dP=P(:,:,1:lev-1)-P(:,:,2:lev);    
   q.int0=dP.* ((q.flux(:,:,2:lev)+q.flux(:,:,1:lev-1)).*0.5) ;    
   q.int=sum(q.int0,3)./g;
   %
   q.line(tn,:)=q.int(xp,:);
end
%---plot---
   plot.var=q.line';   
   [plot.x plot.y]=meshgrid(hr,y(xp,:));
   pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[200 100 700 500])
   [c hp]=contourf(plot.x,plot.y,plot.var,L2);   set(hp,'linestyle','none'); hold on
   cm=colormap(cmap);   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
   hold on
   line([hr(1),hr(length(hr))],[22 22],'color',[0.6 0.6 0.6],'LineStyle','--')
   %
   set(gca,'YLim',[21 25],'fontsize',13,'LineWidth',1)      
   xlabel('time (UTC)'); ylabel('latitude')   
   %
   tit=[expri,'  ',vari,' time-series  ',s_hr0,'z-',s_hr,'z  ( ',num2str(mean(x(xp,:))),'°E )'];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,s_hr,'_',num2str(round(mean(x(xp,:)))),'.png'];
   print('-dpng',outfile,'-r400')   
   
   