%
%   plot the fcst and analysis errors
%
clear all
close all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')

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


%m_coast('patch',[1 .85 .7]);
%xlon_u=netcdf_var('/work/scyang/WRFEXPS/work/wrfinput_d01','XLONG_U',1);
%ylat_u=netcdf_var('/work/scyang/WRFEXPS/work/wrfinput_d01','XLAT_U',1);
%xlon_v=netcdf_var('/work/scyang/WRFEXPS/work/wrfinput_d01','XLONG_V',1);
%ylat_v=netcdf_var('/work/scyang/WRFEXPS/work/wrfinput_d01','XLAT_V',1);
%xlon=netcdf_var('/work/scyang/WRFEXPS/work/wrfinput_d01','XLONG',1);
%ylat=netcdf_var('/work/scyang/WRFEXPS/work/wrfinput_d01','XLAT',1);
xlon_u=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG_U',1);
ylat_u=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT_U',1);
xlon_v=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG_V',1);
ylat_v=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT_V',1);
xlon  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG',1);
ylat  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT',1);

tag='2006-09-14_18:00:00'
maindir='../output/';
%maindir='../output/';
file_b=strcat([maindir,'wrffcst_d01_'],tag)
file_a=strcat([maindir,'wrfanal_d01_'],tag)
%file_b='../output/wrfoutput_nc_b';
%file_a='../output/wrfoutput_nc_a';
file_t=strcat('../work/wrf_3dvar_input_d01_',tag)
var={'T';'U';'V';'PSFC'};


%S1_V=netcdf_var('background.nc','V',0);
%S2_V=netcdf_var('analysis.nc','V',0);

dx=0.43; dy=0.42;

err=zeros(size(lon,1),size(lon,2),2,4);
%spread=zeros(size(lon,1),size(lon,2),2,2);

for j=2:4
figure(j);clf
%set(gcf,'position',[0.55 0.4 0.2 0.8],'unit','normal')
for i=1:3
    if(i==2)
      infile=file_b;
      tit=['BACKGROUND, ',var(j)];
      iplt=1;
    elseif(i==3)
      infile=file_a;
      tit=['ANALYSIS, ',var(j)];
      iplt=2;
    elseif(i==1)
      infile=file_t;
      tit=['TRUTH, ',var(j)];
      iplt=3;
    end

    %% read the files
    S=netcdf_var(infile,var(j),0);

    switch( cell2mat(var(j)) )
    case('U')
       lons=xlon_u;
       lats=ylat_u;
       clevs=-20:2.:20;
       clevs_c=-20:2:20;
       i1=1:size(S,4)-1;
       i2=2:size(S,4);
       si=0.5*(S(1,1,:,i1)+S(1,1,:,i2));
    case('V')
       lons=xlon_v;
       lats=ylat_v;
       clevs=-20:2.:20;
       clevs_c=-20:2:20;
       j1=1:size(S,3)-1;
       j2=2:size(S,3);
       si=0.5*(S(1,1,j1,:)+S(1,1,j2,:));
    case('T')
       lons=xlon;
       lats=ylat;
       clevs=-2:0.2:2;
       clevs_c=-10:1:10;
       si=S(1,1,:,:);
    case('PSFC')
       lons=xlon;
       lats=ylat;
       clevs=-1.5:0.15:1.5;
       clevs_c=8.5:0.075:10.25;
       si=S(1,:,:)*1.e-4;
    case('W')
            lons=xlon;
            lats=ylat;
            clevs=-2:0.2:2;
    end

    
    %if(length(size(S))==4)
    %   si=griddata(lons',lats',squeeze(S(1,2,:,:))',lon,lat,'v4');
    %else
    %    si=griddata(lons',lats',squeeze(S(1,:,:))',lon,lat,'v4')*1.e-4;
    %end
    if(i==1)
       si_t=si;
    %else
    %   err(:,:,i-1,j) =si-si_t;
    end 

    ii=mod(iplt,2);
    if(ii==0);ii=2;end
       x1=0.05+(ii-1)*1.05*dx;
       y1=0.5-((iplt-ii)/2)*1.1*dy;
       axes('position',[x1 y1 dx dy])
       m_proj('lambert','long',[lon1 lon2],'lat',[lat1 lat2]);
       m_grid('linest','none','box','fancy','tickdir','in');
       hold on
      
       [c,h]=m_contourf(xlon,ylat,squeeze(si)',clevs); caxis([clevs_c(1) clevs_c(end)]);hold on
       set(h,'linestyle','none')
    if (i> 1) 
       [c,h]=m_contour(xlon,ylat,squeeze(si-si_t)',[clevs(2)-clevs(1):clevs(2)-clevs(1):clevs(end)]); hold on
       set(h,'edgecolor','k')
       [c,h]=m_contour(xlon,ylat,squeeze(si-si_t)',[clevs(1):clevs(2)-clevs(1):clevs(1)-clevs(2)]); hold on
       set(h,'edgecolor','k','linestyle','--')
    end
       %m_grid('box','fancy','tickdir','in');
       m_coast('color',[0.2 .2 0.2],'linewidth',2.0); 
       m_text(120.0,33.2,tit,'horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')

    %m_grid('tickdir','in');
       %if (cell2mat(var(j))=='NOPLOT' )
       %   for xo=lono
       %   for yo=lato
       %       m_text(xo,yo,'+','horizontalalignment','center','VerticalAlignment','middle','fontsize',12,'fontweight','bold')
       %   end
       %   end
       %end
    
    clear si
    clear S;
    clear lons;
    clear lats;
end
h=colorbar('horiz');
set(h,'position',[0.5,0.425,dx 0.025])
end
Date=tag(1:10);
Time=tag(12:19);
text(1.5,0.5,['Date: ',Date],'unit','normal','fontsize',14)
text(1.5,0.4,['Time: ',Time],'unit','normal','fontsize',14)
