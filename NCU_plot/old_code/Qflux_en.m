function Qflux_en(hr,expri,member)
%clear; 
%hr=18; expri='orig';  member=1;
% hr : time
% expri : experiment name
%hr=18; expri='DA1518vrzh';  %test

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat'
%----set---- 
vari='Qv flux and Div.';   filenam=[expri,'_QvU_'];  type='member';  
%indir=['/SAS002/pwin/expri_241/morakot_en_',expri];
indir=['/SAS004/pwin/wrfout_morakot_',expri];
outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];
lev=8;
dx=4500; dy=4500;
%----
cmap=colormap_br;
L=[ -3 -2.5 -2 -1.5 -1 -0.5 -0.25 0.1 0.1 0.25 0.5 1 1.5 2 2.5 3   ]*10^-2;
cmap(9,:)=[1 1 1]; 
%----
for ti=hr
  s_hr=num2str(ti);  
  %infile=[indir,'/wrfout_d03_2009-08-08_',s_hr,':00:00_mean'];
     for mi=member
     nen=num2str(mi);
     if mi<=9
      %infile=[indir,'/pert0',nen,'/wrfout_d03_2009-08-08_',s_hr,':00:00'];
      infile=[indir,'/wrfout_d03_2009-08-08_',s_hr,':00:00_0',nen];
     else
      %infile=[indir,'/pert',nen,'/wrfout_d03_2009-08-08_',s_hr,':00:00'];
      infile=[indir,'/wrfout_d03_2009-08-08_',s_hr,':00:00_',nen];
     end
%----read netcdf data--------
  ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');    u0 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');    v0 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'W');    w0 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));
 

%----calculate wind U, V and Speed---
   [nx ny nz]=size(qv);
   u=(u0(1:nx,:,:)+u0(2:nx+1,:,:)).*0.5;
   v=(v0(:,1:ny,:)+v0(:,2:ny+1,:)).*0.5;   
   w=(w0(:,:,1:nz)+w0(:,:,2:nz+1)).*0.5;
%----calculate wind U, V and Speed---
   Qvu=u.*qv;
   Qvv=v.*qv; 
   %---
   qdivx=zeros(size(qv)); qdivy=zeros(size(qv));
   qdivx(2:nx-1,:,:)=(Qvu(3:nx,:,:)-Qvu(1:nx-2,:,:))/(2*dx);
   qdivy(:,2:ny-1,:)=(Qvv(:,3:ny,:)-Qvv(:,1:ny-2,:))/(2*dy);
   div=(qdivx+qdivy).*10^3;
%====plot set====
   xi=x(1:5:196,1:5:196);   yi=y(1:5:196,1:5:196);
   uplot=Qvu(1:5:196,1:5:196,:);   vplot=Qvv(1:5:196,1:5:196,:);
%---plot
%
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
     L2=[min(min(div(:,:,lev))),L];
     [c hp]=m_contourf(x,y,div(:,:,lev),L2);   set(hp,'linestyle','none');
     colorbar;   cm=colormap(cmap);    %caxis([-0.04 0.04])
     hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
   hold on
%---vector & legend---
     % Max, legend
     s=(uplot.^2+vplot.^2).^0.5; 
     Ma=max(max(s(:,:,lev)));   Mav=1;  
     uplot(28,12,lev)=Mav;   vplot(28,12,lev)=0;
     m_text(122.65,21.95,num2str(Mav),'color','k');
   hq=m_quiver(xi,yi,uplot(:,:,lev),vplot(:,:,lev),1.5,'k');
   set(hq,'LineWidth',1.2)
%---
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k');
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type,nen,', lev',num2str(lev),' )'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_m',nen,'.png'];
   saveas(gca,outfile,'png');  
%}
   netcdf.close(ncid)
     end
end 