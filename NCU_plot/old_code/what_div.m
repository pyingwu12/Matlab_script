clear

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat';  %cmap=colormap_qr2; 
load '/work/pwin/data/colormap_br.mat';   cmap=colormap_br;
%---set---
hr=13;    expri='vr124';   lev=15;%(wind level)   

vari='wind div.';   filenam=[expri,'_div_'];   
%indir=['/SAS002/pwin/expri_241/morakot_sing_',expri,'_1800'];
%outdir=['/work/pwin/plot_cal/Qall/',expri];
%indir=['/SAS002/pwin/expri_241/morakot_sing_',expri];
%outdir=['/work/pwin/plot_cal/morakot/',expri,'/'];
indir=['/SAS009/pwin/expri_whatsmore/',expri];
outdir=['/work/pwin/plot_cal/what/',expri,'/'];
s_date='10';
dom='01';
dx=3000; dy=3000;
%----
plon=[119.3 122.7]; plat=[21.65 25.65];
%plon=[119.3 121.8]; plat=[22 24.8];

L=[-4 -3 -2.0 -1.0 -.5  -0.3  0.3  0.5 1 2 3 4];

for ti=hr;
%===wrf---set filename---         
   s_hr=num2str(ti);
      %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];
      infile=[indir,'/wrfout_d',dom,'_2012-06-',s_date,'_',s_hr,':00:00'];
%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);   y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');       ustag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');       vstag =netcdf.getVar(ncid,varid);
   %---    
   truelat1 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT1')); 
   truelat2 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT2'));
   cen_lon =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LON'));
   cen_lat =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LAT'));
 
   netcdf.close(ncid)
%---
  [nx ny]=size(lon);
   div= ( ustag(2:nx+1,:,:)-ustag(1:nx,:,:) )./dx +  ( vstag(:,2:ny+1,:)-vstag(:,1:ny,:) )./dy ;
   div=div*10^3;
   
   %---plot
   plotvar=div(:,:,lev);   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',cen_lon,'parallels',[truelat1 truelat2],'rectbox','on')
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none'); hold on
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   %m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);     caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)        
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_sing.png'];
   print('-dpng',outfile,'-r400')  

end       
      