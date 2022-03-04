%function Qflux_mean(hr,expri)
%clear; 
%hr=18; expri='orig';  member=1;
% hr : time
% expri : experiment name
clear; hr=15:21; expri='orig';  expid=1; %test

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  %cmap=colormap_br;
cmap0=jet(31); %cmap=cmap0(8:20,:); cmap(3:4,:)=[1 1 1; 1 1 1];
cmap=colormap_br([3 4 6 8 9 10 11 12 13 ],:);
cmap(7:13,:)=cmap0(25:31,:);
load '/work/pwin/data/colormap_br2.mat'; 
cmap(9:13,:)=colormap_br2([21 19 17 15 13],:);
%cmap(11:13,:)=[0.9, 0.3, 0.8;
%               0.9, 0.5, 0.8;
%               0.9, 0.6, 0.7;];


L=[-300 -100 0 100 300 500 700 800 900 1000 1100 1200];
%----set---- 
vari='Qv flux';   filenam=[expri,'_Qvflux_'];  type='mean';  
if expid==1; indir=['/SAS004/pwin/wrfout/wrfout_morakot_',expri];
elseif expid==2; indir=['/SAS002/pwin/expri_241/morakot_en_',expri]; end

outdir=['/work/pwin/plot_cal/Qall/',expri,'/'];

lev=10;  % ~750hpa at the setting of Morakot
xp=77;  yp=37:158; % row 77: ~120E, coloum 37-158: ~21N-26N
%----

ni=0;
for ti=hr
  ni=ni+1;  
  s_hr=num2str(ti);  
  infile=[indir,'/wrfout_d03_2009-08-08_',s_hr,':00:00_mean'];
%----read netcdf data--------
  ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');    u0 =netcdf.getVar(ncid,varid);
   %varid  =netcdf.inqVarID(ncid,'V');    v0 =netcdf.getVar(ncid,varid);
   %varid  =netcdf.inqVarID(ncid,'W');    w0 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));  %Kg/Kg 
   varid  =netcdf.inqVarID(ncid,'P');       p =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb =netcdf.getVar(ncid,varid); 
%----calculate wind U, V and Speed---
   [nx ny nz]=size(qv);
   u=(u0(1:nx,:,:)+u0(2:nx+1,:,:)).*0.5;
   %v=(v0(:,1:ny,:)+v0(:,2:ny+1,:)).*0.5;   
%----calculate wind U, V and Speed---
   qvu=u.*qv;
    
   P=(pb+p);
   g=9.81;
%---  
   dP=P(:,:,1:lev-1)-P(:,:,2:lev);    
   qvu_dp= dP.*( (qvu(:,:,2:lev)+qvu(:,:,1:lev-1)).*0.5 ) ;    
   qvu_in=sum(qvu_dp,3)./g;
%---plot
%
   pvar=qvu_in;
   figure('position',[1800 100 600 500])
   m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
     if min(min(pvar(:,:)))<L(1); L2=[min(min(pvar(:,:))),L]; else L2=[L(1) L]; end
     [c hp]=m_contourf(x,y,pvar(:,:),L2);   set(hp,'linestyle','none');
     colorbar;   cm=colormap(cmap);    
     caxis([-1000 1000])
     hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
   m_grid('fontsize',12);
   m_coast('color','k');
   %m_gshhs_h('color','k');
   tit=[expri,'  ',vari,'  ',s_hr,'z  (',type,', lev',num2str(lev),' )'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_',type,'.png'];
   %print('-dpng',outfile,'-r350')    
%}
   netcdf.close(ncid)
%-------
   qvf(:,ni)=qvu_in(xp,yp);   
end 


vari='Qv flux';   filenam=[expri,'_qvflux_'];  type='mean';  

load '/work/pwin/data/colormap_br.mat';  %cmap=colormap_br;
cmap0=jet(31); %cmap=cmap0(8:20,:); cmap(3:4,:)=[1 1 1; 1 1 1];
cmap=colormap_br([3 4 6 8 9 10 11 12 13 ],:);
cmap(7:13,:)=cmap0(25:31,:);
load '/work/pwin/data/colormap_br2.mat'; 
cmap(9:13,:)=colormap_br2([21 19 17 15 13],:);
%cmap(11:13,:)=[0.9, 0.3, 0.8;
%               0.9, 0.5, 0.8;
%               0.9, 0.6, 0.7;];


C=[-500 -300 0 300 500 600 700 800 900 1000 1100 1200];
if min(min(qvf))<C(1); C2=[min(min(qvf)),C]; else C2=[C(1) C]; end


figure('position',[1800 50 700 550])
[c hp]=contourf(hr,y(xp,yp),qvf,C2);   %set(hp,'linestyle','none');
colorbar;   cm=colormap(cmap);  
hc=Recolor_contourf(hp,cm,C,'vert');  set(hc,'fontsize',13)
set(gca,'fontsize',13)
xlabel('Time (UTC)'); ylabel('latitude'); %ylabel('Model level');

tit=[expri,' ',type,'  ',vari,'  (120°E)'];
title(tit,'fontsize',15)
outfile=[outdir,filenam,'120E.png'];
print('-dpng',outfile,'-r300')   
