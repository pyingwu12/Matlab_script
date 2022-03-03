%
%   plot the fcst and analysis errors
%
clear all
clf
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

%expmain='/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/'; % truth for exp06
%file_t=strcat([expmain,'../initial/init_pert18/wrf_3dvar_input_d01_'],tag)

expmain='/mnt/ddal01/WRFEXPS/exp07/TRUTH/';
file0='wrfinput_d01_148177_43200_10'
xlon_u=getnc([expmain,file0],'XLONG_U');
ylat_u=getnc([expmain,file0],'XLAT_U');
xlon_v=getnc([expmain,file0],'XLONG_V');
ylat_v=getnc([expmain,file0],'XLAT_V');
xlon  =getnc([expmain,file0],'XLONG');
ylat  =getnc([expmain,file0],'XLAT');
eta  = getnc([expmain,file0],'ZNU');

tag='2006-09-16_00:00:00'
maindir{1}='/mnt/ddal01/ailin/exp07B/e01/output/';
maindir{2}='/mnt/ddal01/ailin/exp07B/e01/output/';
%maindir{2}='../varloc_test/control/';
%maindir{1}='../varloc_test/test_T/';
%maindir='../exp06/e00_initial2/';
%file_b=strcat([maindir,'wrffcst_d01_'],[tag,''])
%file_b=strcat([maindir{1},'wrffcst_d01_'],[tag,''])
%file_a=strcat([maindir{2},'wrffcst_d01_'],[tag,''])
file_b=strcat([maindir{1},'wrffcst_d01_'],[tag,''])
file_a=strcat([maindir{2},'wrfanal_d01_'],[tag,''])
file_t=strcat([expmain,'wrf_3dvar_input_d01_'],[tag,'_10'])
var={'T';'U';'V';'QVAPOR';'PSFC'};
dx=0.43; dy=0.42;

err=zeros(size(lon,1),size(lon,2),2,4);
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
    elseif(i==4)
      tit=strcat('INCREMENT');
      iplt=4;
    end

    %% read the files
    if(i<=3)
    %S=netcdf_var(infile,var(j),0);
       %S=getnc(infile,'U');
       %i1=1:size(S,3)-1;
       %i2=2:size(S,3);
       %u=squeeze(0.5*(S(2,:,i1)+S(2,:,i2)));
       %clear S;
       %S=getnc(infile,'V');
       %j1=1:size(S,2)-1;
       %j2=2:size(S,2);
       %v=squeeze(0.5*(S(2,j1,:)+S(2,j2,:)));
       %S=getnc(infile,'T');
       %si=squeeze(S(2,:,:));
       [utmp,vtmp,w,th,qv,temp,slp,pressure]=getnc_vars(infile,1,xlon,ylat,eta);
       si=sqrt(squeeze(utmp(2,:,:)).^2+squeeze(vtmp(2,:,:)).^2);
    end

    ii=mod(iplt,2);
    if(ii==0);ii=2;end
    x1=0.05+(ii-1)*1.05*dx;
    y1=0.5-((iplt-ii)/2)*1.1*dy;
    axes('position',[x1 y1 dx dy])
    m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
    m_grid('linest','none','box','fancy','tickdir','in');
    hold on
    [c,h]=m_contourf(xlon,ylat,squeeze(si),[0:1.25:25]); 
    caxis([0 25]);hold on
    set(h,'linestyle','none')
    [c,h]=m_contour(xlon,ylat,slp,[975:3:1010]); 
    %[c,h]=m_contour(xlon,ylat,squeeze(pressure(1,:,:))*1.e-2,[975:3:1010]); 
    set(h,'edgecolor','k')
    %[c,h]=m_contourf(xlon,ylat,squeeze(si+300.0),[290:1:310]); 
    %caxis([290 310]);hold on
    %m_quiver(xlon,ylat,u,v);
    %m_grid('box','fancy','tickdir','in');
    m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    %m_text(xc,yc,'X','horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
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
