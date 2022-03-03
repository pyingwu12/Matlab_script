%
%   plot the fcst and analysis errors
%
clear all
%close all
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

expmain='/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/';
%m_coast('patch',[1 .85 .7]);
%xlon_u=netcdf_var([expmain,'wrfinput_d01'],'XLONG_U',1);
%ylat_u=netcdf_var([expmain,'wrfinput_d01'],'XLAT_U',1);
%xlon_v=netcdf_var([expmain,'wrfinput_d01'],'XLONG_V',1);
%ylat_v=netcdf_var([expmain,'wrfinput_d01'],'XLAT_V',1);
%xlon  =netcdf_var([expmain,'wrfinput_d01'],'XLONG',1);
%ylat  =netcdf_var([expmain,'wrfinput_d01'],'XLAT',1);
xlon_u=getnc([expmain,'wrfinput_d01'],'XLONG_U');
ylat_u=getnc([expmain,'wrfinput_d01'],'XLAT_U');
xlon_v=getnc([expmain,'wrfinput_d01'],'XLONG_V');
ylat_v=getnc([expmain,'wrfinput_d01'],'XLAT_V');
xlon  =getnc([expmain,'wrfinput_d01'],'XLONG');
ylat  =getnc([expmain,'wrfinput_d01'],'XLAT');

tag='2006-09-14_12:00:00'
maindir='../exp06/e26RIPA/';
%maindir='../output/';
%maindir='../varloc_test/control/';
%maindir='../exp06/e00_initial2/';
%file_b=strcat([maindir,'wrfanal_d01_'],[tag,''])
file_b=strcat([maindir,'wrffcst_d01_'],[tag,''])
%file_b=strcat([maindir,'wrfinit_d01_'],[tag,'.1'])
%file_b=strcat(['/work/scyang/WRFEXPS/exp06/e02/wrfanal_d01_'],[tag,''])
%file_a=strcat(['/work/scyang/WRFEXPS/exp06/e04/wrfanal_d01_'],[tag,''])
file_a=strcat([maindir,'wrfanal_d01_'],[tag,''])
%file_a=strcat([maindir,'wrfsmth_d01_'],[tag,'.1'])
%file_b=strcat(['wrf_3dvar_input_d01_'],[tag,'.avg'])
%file_a=strcat(['wrf_3dvar_input_d01_'],[tag,'.avg.initial1'])
%file_b=strcat([maindir,'wrfinit_d01_'],[tag,'.1'])
%file_a=strcat([maindir,'wrfsmth_d01_'],[tag,'.1'])
%file_b='../output/wrfoutput_nc_b';
%file_a='../output/wrfoutput_nc_a';
%file_t=strcat('../work/wrf_3dvar_input_d01_',tag)
file_t=strcat([expmain,'../initial/init_pert18/wrf_3dvar_input_d01_'],tag)
var={'T';'U';'V';'QVAPOR';'PSFC'};

%S1_V=netcdf_var('background.nc','V',0);
%S2_V=netcdf_var('analysis.nc','V',0);

dx=0.43; dy=0.4;

err=zeros(size(lon,1),size(lon,2),2,4);
%spread=zeros(size(lon,1),size(lon,2),2,2);

for j=[5]
figure(j+5);clf
%figure(j);clf
%set(gcf,'position',[0.55 0.4 0.2 0.8],'unit','normal')
for i=1:4
    if(i==2)
      infile=file_b;
      tit=strcat('BACKGROUND Err, ',var{j});
      iplt=1;
    elseif(i==3)
      infile=file_a;
      tit=strcat('ANALYSIS Err, ',var{j});
      iplt=2;
    elseif(i==1)
      infile=file_t;
      tit=strcat('TRUTH, ',var{j});
      iplt=3;
    elseif(i==4)
      tit=strcat('improvement, ',var{j});
      iplt=4;
    end

    %% read the files
    if(i<=3)
    %S=netcdf_var(infile,var(j),0);
    S=getnc(infile,var{j});
    end
    nz=1;
    %switch( cell2mat(var(j)) )
    switch( var{j} )
    case('U')
       lons=xlon_u;
       lats=ylat_u;
       clevs=-20:2:20;
       i1=1:size(S,3)-1;
       i2=2:size(S,3);
       if(i<=3)
       si=0.5*(S(nz,:,i1)+S(nz,:,i2));
       clevs=-10:1:10;
       else
       clevs=-5:1:5;
       end
       if(i==1); clevs=-20:2:20;end
    case('V')
       lons=xlon_v;
       lats=ylat_v;
       clevs=-20:2:20;
       j1=1:size(S,2)-1;
       j2=2:size(S,2);
       if(i<=3)
       si=0.5*(S(nz,j1,:)+S(nz,j2,:));
       clevs=-10:1:10;
       else
       clevs=-5:1:5;
       end
       if(i==1); clevs=-20:2:20;end
    case('T')
       lons=xlon;
       lats=ylat;
       %clevs=-10:1:10;
       if(i<=3)
       si=S(nz,:,:)+300;
       clevs=-2:0.2:2;
       else
       clevs=-1:0.1:1;
       end
       if(i==1); clevs=-10+305:0.15:5+305;end
    case('QVAPOR')
       lons=xlon;
       lats=ylat;
       clevs=0:1:25;
       if(i<=3)
       si=S(1,:,:)*1.e3;
       end
    case('PSFC')
       lons=xlon;
       lats=ylat;
       if(i<=3)
       si=S(:,:)*1.e-4;
        clevs=-0.05:0.005:0.05;
       else
        clevs=-0.05:0.005:0.05;
       end
       if(i==1);clevs=[9.8:0.02:10.2];end
    end

    if(i==1)
       si_t=si;
       %if(cell2mat(var(j)) =='PSFC')
       %if(strfind(var{j},'PSFC'))
       %   xc=125.0;yc=20.0;

       %   ind1=find( abs(xlon-xc)<=3.0);
       %   ind2=find( abs(ylat(ind1)-yc)<=3.0);
       %   ind=ind1(ind2);
       %   xs=xc-1.5:0.25:xc+1.5;
       %   ys=yc-1.5:0.25:yc+1.5;
       %   [xg,yg]=meshgrid(xs,ys);
       %   pss=reshape(si_t,size(si_t,1)*size(si_t,2),1);
       %   psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'linear');
       %   [psfc_c,ic]=min(reshape(psi,size(psi,1)*size(psi,2),1) );
       %   iy=mod(ic,size(psi,2))
       %   ix=(ic-iy)/size(psi,2)+1
       %   xc=xg(iy,ix);
       %   yc=yg(iy,ix);
       %end
    elseif(i==2)
       si_f=si;
       si=si_f-si_t;
    elseif(i==3)
       si_a=si;
       si=si_a-si_t;
    elseif(i==4)
       si=abs(si_a-si_t)-abs(si_f-si_t);
    end

    ii=mod(iplt,2);
    if(ii==0);ii=2;end
    x1=0.05+(ii-1)*1.05*dx;
    y1=0.5-((iplt-ii)/2)*1.18*dy;
    axes('position',[x1 y1 dx dy])
    m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
    m_grid('linest','none','box','fancy','tickdir','in');
    hold on
    [c,h]=m_contourf(xlon,ylat,squeeze(si),clevs); caxis([clevs(1) clevs(end)]);hold on
    set(h,'linestyle','none')
    %m_grid('box','fancy','tickdir','in');
    m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    %m_text(xc,yc,'X','horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
    m_text(0.5*(lon1+lon2),lat2+0.012*(lat2-lat1),[tit,' (z=',num2str(nz),')'],'horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
    
    clear si
    clear lons;
    clear lats;
    set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 10 8])
    %eval(['print -dpsc -f',num2str(j),' f',num2str(j),tag(1:13),'z',num2str(nz),'.ps'])
end
%h=colorbar('horiz');
%set(h,'position',[0.5,0.425,dx 0.025])
end
Date=tag(1:10);
Time=tag(12:19);
text(1.5,0.5,['Date: ',Date],'unit','normal','fontsize',14)
text(1.5,0.4,['Time: ',Time],'unit','normal','fontsize',14)

