%function TPW_mean(hr,expri,expid)
clear;  %close all
hr=10; expri='0614e01';  
% hr : time
% expri : experiment name
%
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat';  cmap=colormap_qr2([1 3 5 6 8 9 10 11 13 14 15 16 17],:);
load '/work/pwin/data/colormap_br.mat';   cmap2=colormap_br;    
%----set---- 
vari='TPW';   filenam=[expri,'_TPW_'];  
type1='mean';  type2='best';   type3='best-mean';
%indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_',expri,'mrcy'];
indir=['/SAS007/pwin/expri_reas_IOP8/MRC_e02_1012_mb'];
outdir=['/work/pwin/plot_cal/IOP8/Qall/',expri,'/'];
%----
plon=[118.5 122.5]; plat=[21.65 25.65];
L=[25 30 35 40 50 60 63 66 69 72 75 78];
Lbr=[-10 -8 -5 -3 -1.5 -0.5 0.5 1.5 3 5 8 10];
%----
for ti=hr
%---set filename---    
   if ti==24
     s_date='15';   s_hr='00';
   else
     s_date='14';   s_hr=num2str(ti);
   end     
   %infile1=[indir,'/output/analmean_d02_2008-06-',s_date,'_',s_hr,':00:00'];
   infile1=[indir,'/wrfavg_d02'];
%----read netcdf data--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QCLOUD');  qc  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QICE');    qi  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QSNOW');   qs  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QGRAUP');  qg  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb =netcdf.getVar(ncid,varid); 
%---
   qt=qr+qc+qv+qi+qg+qs;
   P=(pb+p);
   nz=size(qt,3); %ny=size(qt,2); nx=size(qt,1);
   g=9.81;
%---  
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qt(:,:,2:nz)+qt(:,:,1:nz-1)).*0.5 ) ;    
   TPW_m=sum(tpw,3)./g;
%-----------------------
   %varid  =netcdf.inqVarID(ncid,'U');
   % u  =netcdf.getVar(ncid,varid);
   %varid  =netcdf.inqVarID(ncid,'V');
   % v =netcdf.getVar(ncid,varid);
%---
   %nn=size(v,1);
   %umean1=(u(1:nn,:,:)+u(2:nn+1,:,:)).*0.5;
   %vmean1=(v(:,1:nn,:)+v(:,2:nn+1,:)).*0.5;     
%---plot set
   %xi=x(1:5:196,1:5:196);   yi=y(1:5:196,1:5:196);
   %uplot1=umean1(1:5:196,1:5:196,:);   vplot1=vmean1(1:5:196,1:5:196,:); 
%---plot
   L2=[min(min(TPW_m)),L];
   figure('position',[2000 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [ce hp]=m_contourf(x,y,TPW_m,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   colorbar;    cm=colormap(cmap);   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
   hold on
   %---vector & legend---
   %hq=m_quiver(xi,yi,uplot1(:,:,lev),vplot1(:,:,lev),1.5,'k');
   %set(hq,'LineWidth',1.5)
   %
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type1,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_',type1,'.png'];
   print('-dpng',outfile,'-r350')     
%=============================================   
   %infile2=[indir,'/MRwork/wrfinput_d02_best_',s_hr,':00'];
   infile2=[indir,'/wrfinput_d02_best'];
   ncid = netcdf.open(infile2,'NC_NOWRITE'); 
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QCLOUD');  qc  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QICE');    qi  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QSNOW');   qs  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QGRAUP');  qg  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb =netcdf.getVar(ncid,varid); 
%---
   qt=qr+qc+qv+qi+qg+qs;
   P=(pb+p);
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qt(:,:,2:nz)+qt(:,:,1:nz-1)).*0.5 ) ;    
   TPW_best=sum(tpw,3)./g;
   %-----------------------
   %varid  =netcdf.inqVarID(ncid,'U');
   % u  =netcdf.getVar(ncid,varid);
   %varid  =netcdf.inqVarID(ncid,'V');
   % v =netcdf.getVar(ncid,varid);
%---
   %nn=size(v,1);
   %umean2=(u(1:nn,:,:)+u(2:nn+1,:,:)).*0.5;
   %vmean2=(v(:,1:nn,:)+v(:,2:nn+1,:)).*0.5;     
   %uplot2=umean2(1:5:196,1:5:196,:);   vplot2=vmean2(1:5:196,1:5:196,:);
   %---plot   
   L2=[min(min(TPW_best)),L];
   figure('position',[2000 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [cb hp]=m_contourf(x,y,TPW_best,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   colorbar;     cm=colormap(cmap);   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
   hold on
   %---vector & legend---
   %hq=m_quiver(xi,yi,uplot2(:,:,lev),vplot2(:,:,lev),1.5,'k');
   %set(hq,'LineWidth',1.5)
   %
   tit=[expri,'  ',vari,' (',type2,')  ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_best.png'];
   print('-dpng',outfile,'-r350')  
%================================================ 

   TPW_bm=TPW_best-TPW_m;
   %u_bm=uplot2-uplot1; v_bm=vplot2-vplot1;
%---    
   Lbr2=[min(min(TPW_bm)),Lbr];
   figure('position',[2000 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,TPW_bm,Lbr2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
   colorbar;      cm=colormap(cmap2);   
   hc=Recolor_contourf(hp,cm,Lbr,'vert');  set(hc,'fontsize',13)
   hold on
   %---vector & legend---
   %hq=m_quiver(xi,yi,u_bm(:,:,lev),v_bm(:,:,lev),1.5,'k');
   %set(hq,'LineWidth',1.5)
   %
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type3,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_',type3,'.png'];
   print('-dpng',outfile,'-r350')    
%}
%---    
   netcdf.close(ncid)
end    
%}
%end
