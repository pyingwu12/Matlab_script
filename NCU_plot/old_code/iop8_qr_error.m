%function TPW_sprd(hr,expri)
clear
hr=2:14;  expri='vrzh128';  lev=10;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';    cmap=colormap_br;

% colormap_br3=[%128, 31,239;
%                14,  3,253;
%                56, 93,228;
%                38,131,246;
%                 8,175,255;
%                87,195,244;              
%               177,221,244;
%               255,255,255; 
%               255,246,135;
%               255,205, 29;
%               255,151,  0;
%               255, 82,  0;
%               246,  0,  0;
%               205, 12, 12;]./255;
%               %255,177,177]./255;
%  cmap=colormap_br3;
%----set---- 
vari='Qrain error';   filenam=[expri,'_qr-err_']; 
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
date=16;
%----
L=[-10 -8 -6 -4 -2 -0.5 0.5 2 4 6 8 10];
plon=[117.5 123]; plat=[20.5 25.8];
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
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qv  =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PB');      pb =double(netcdf.getVar(ncid,varid));
   netcdf.close(ncid) 
   %true
   infile=['/SAS007/pwin/expri_sz6414/true/wrfout_d03_2008-06-',s_date,'_',s_hr,':00:00'];
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qvt  =double(netcdf.getVar(ncid,varid));
   netcdf.close(ncid) 
%---
   [nx ny nz]=size(qv);        
   P=(pb+p);  g=9.81; 
   qverr=qvt-qv;
   q=qverr;   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   qdp= dP.*( (q(:,:,2:nz)+q(:,:,1:nz-1)).*0.5 ) ;    
   qrall=sum(qdp,3)./g;    
%---plot---

   plotvar=qrall;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color','k','LineWidth',0.8);     
   cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z (lev1-lev10)'];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,s_hr,'.png'];
   print('-dpng',outfile,'-r350')
  %}
%---    

end 
