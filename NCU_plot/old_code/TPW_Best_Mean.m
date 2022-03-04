%function TPW_mean(hr,expri,expid)
clear
%close all
hr=16; expri='MRcycle06';  best='37';  expid=2;
% hr : time
% expri : experiment name
%
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat'
load '/work/pwin/data/colormap_br.mat';  
%colormap_br(9,:)=[1 1 1]; colormap_br(12,:)=[1 0.7065 0.1608]; colormap_br(6,:)=[0.4 0.7843 0.9012]; 
%colormap_br(15,:)=[0.8059 0.1569 0.0400];
cmap2=colormap_br;    
%----set---- 
vari='TPW';   filenam=[expri,'_TPW_'];  
type1='mean';  type2=['best m',best];   type3=['b',best,'-m'];
if expid==1; indir=['/SAS004/pwin/wrfout_morakot_',expri];
elseif expid==2; indir=['/SAS002/pwin/expri_241/morakot_',expri]; end
outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];
%----
%plon=[111 136]; plat=[12 36];
plon=[118.5 122.5]; plat=[21.65 25.65];
cmap=colormap_qr2;
L=[40 44 48 52 56 60 64 68 71 74 77 80 83 86 89 92];
Lbr=[-10 -8 -5 -3 -2 -1 1 2 3 5 8 10];
lev=8;
%----
for ti=hr
%---set filename---    
   if ti==24
     s_date='09';   s_hr='00';
   else
     s_date='08';   s_hr=num2str(ti);
   end     
   infile1=[indir,'/anal_d03_2009-08-',s_date,'_',s_hr,':00:00_mean'];
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
   [c hp]=m_contourf(x,y,TPW_m,L2);   set(hp,'linestyle','none');
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
   infile2=[indir,'/cycle',best,'/anal_d03_2009-08-',s_date,'_',s_hr,':00:00'];
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
   %---    
   L2=[min(min(TPW_best)),L];
   figure('position',[2000 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,TPW_best,L2);   set(hp,'linestyle','none');
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
   outfile=[outdir,filenam,s_hr,'_',best,'.png'];
   print('-dpng',outfile,'-r350')  
%================================================   
   %
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
%---    
   netcdf.close(ncid)
end    
%}
%end
