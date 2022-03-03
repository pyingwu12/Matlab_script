%
%   plot the fcst and analysis errors
%
clear all
clf
%close all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
rad=pi/180.0;
Re=6357.00;

% fiure setting
%geolocation setting
lon1=110;
lon2=135;
dlon=0.5;
lat1=11;
lat2=35;
dlat=0.5;
[lon,lat]=meshgrid([lon1:dlon:lon2],[lat1:dlat:lat2]);
lono=111.5:2.0:135.0;
lato=13.0:2.0:33.0;

expmain='/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/';
xlon_u=getnc([expmain,'wrfinput_d01'],'XLONG_U');
ylat_u=getnc([expmain,'wrfinput_d01'],'XLAT_U');
xlon_v=getnc([expmain,'wrfinput_d01'],'XLONG_V');
ylat_v=getnc([expmain,'wrfinput_d01'],'XLAT_V');
xlon  =getnc([expmain,'wrfinput_d01'],'XLONG');
ylat  =getnc([expmain,'wrfinput_d01'],'XLAT');
mask=getnc([expmain,'wrfinput_d01'],'LANDMASK');

tag='2006-09-16_06:00:00'
maindir{1}='../exp06/e25_rlocv01/';
file_t=strcat([expmain,'../initial/init_pert18/wrf_3dvar_input_d01_'],tag)
var={'T';'U';'V';'QVAPOR';'PSFC'};
dx=0.43; dy=0.42;

div=NaN*zeros(size(xlon,1),size(xlon,2));
vor=NaN*zeros(size(xlon,1),size(xlon,2));
%spread=zeros(size(lon,1),size(lon,2),2,2);
%set(gcf,'position',[0.55 0.4 0.2 0.8],'unit','normal')
for i=1:1
    if(i==2)
      infile=file_b;
      tit=strcat('BACKGROUND');
      iplt=1;
    elseif(i==3)
      infile=file_a;
      tit=strcat('ANALYSIS');
      iplt=2;
    elseif(i==1)
      infile=file_t;
      tit=strcat('TRUTH');
      iplt=3;
    end

    %% read the files
    if(i<=3)
    %S=netcdf_var(infile,var(j),0);
       S=getnc(infile,'U');
       i1=1:size(S,3)-1;
       i2=2:size(S,3);
       u=squeeze(0.5*(S(1,:,i1)+S(1,:,i2)));
       clear S;
       S=getnc(infile,'V');
       j1=1:size(S,2)-1;
       j2=2:size(S,2);
       v=squeeze(0.5*(S(1,j1,:)+S(1,j2,:)));
       %si=sqrt(u.^2+v.^2);
       for i=2:size(xlon,1)-1
       for j=2:size(ylat,2)-1
           ry=Re*rad*(ylat(i+1,j)-ylat(i-1,j));
           rx=Re*cos(rad*ylat(i,j))*rad*(xlon(i,j+1)-xlon(i,j-1));
           dudx=(u(i,j+1)-u(i,j-1))/abs(rx);
           dvdx=(v(i,j+1)-v(i,j-1))/abs(rx);
           dvdy=(v(i+1,j)-v(i-1,j))/abs(ry);
           dudy=(u(i+1,j)-u(i-1,j))/abs(ry);
           div(i,j)=(1-mask(i,j))*(dudx+dvdy);
           vor(i,j)=(1-mask(i,j))*(dvdx-dudy);
       end
       end
    end

    clear si
    clear S;
    clear lons;
    clear lats;
    set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 10 8])
end
Date=tag(1:10);
Time=tag(12:19);
text(1.5,0.5,['Date: ',Date],'unit','normal','fontsize',14)
text(1.5,0.4,['Time: ',Time],'unit','normal','fontsize',14)

cols=colormap(jet(20));
cols(10:11,:)=1.0;
colormap(cols);
subplot(2,1,1)
div(find(div>0.06))=0.06;
div(find(div<-0.06))=-0.06;
vor(find(vor>0.06))=0.06;
vor(find(vor<-0.06))=-0.06;
m_proj('miller','long',[110 140],'lat',[11. 36]); hold on
m_grid('linest','none','box','fancy','tickdir','in');
[c,h]=m_contourf(xlon,ylat,1.e3*div,[-60:6:60]);
caxis([-60 60])
set(h,'linestyle','none')
h=colorbar('ytick',[-60:12:60],'yticklabel',num2str([-60:12:60]'));
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
title('Divergence (x10^{-3})','fontsize',12)
subplot(2,1,2)
m_proj('miller','long',[110 140],'lat',[11. 36]); hold on
m_grid('linest','none','box','fancy','tickdir','in');
[c,h]=m_contourf(xlon,ylat,1.e3*vor,[-60:6:60]);
set(h,'linestyle','none')
caxis([-60 60])
h=colorbar('ytick',[-60:12:60],'yticklabel',num2str([-60:12:60]'));
title('Vorticity (x10^{-3})','fontsize',12)
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
eval(['print -dpsc divvor_',tag(1:13),'.ps'])
