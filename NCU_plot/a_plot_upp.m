

clear

hr=3;   expri='e04';

%------
dom='d02';
L=[11 12 13 13.5 14 14.5 14.85 15 15.72 16];
indir='/SAS004/pwin/system/UPP/UPPV2.2/postprd';  outdir=['/work/pwin/plot_cal/largens/',expri];
%--
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr3.mat';  cmap=colormap_qr3; 
%
varinam='cloud top height';    filenam=[expri,'_cloudtopH_']; 
plon=[118.3 121.8];  plat=[21 24.3];

%---
for ti=hr
   s_hr=num2str(ti,'%2.2d');
   infile=[indir,'/wrfprs_',dom,'_',s_hr,'_',expri,'.nc'];

   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'g3_lon_1');          x =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'g3_lat_0');          y =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT_GDS3_CTL_10');   cth =(netcdf.getVar(ncid,varid))*1e-3; 
   cth(cth<0)=NaN;
%---plot
   plotvar=cth;   
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
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1); title(hc,'10^-^3gpm')
%---
   tit=[expri,'  ',varinam,'  ',s_hr,'z'];   
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,'/',filenam,s_hr];
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]);      



end
