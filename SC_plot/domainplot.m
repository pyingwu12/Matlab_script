%
%   plot the fcst and analysis errors
%
clear all
%close all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')

% fiure setting
%geolocation setting
lono=111.5:2.0:135.0;
lato=13.0:2.0:33.0;


xlon  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG',1);
ylat  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT',1);
znu  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','ZNU',1);
dlon=0.5;
dlat=0.5;
%lon1=min(min(xlon));
%lon2=max(max(xlon));
%lat1=min(min(ylat));
%lat2=max(max(ylat));
lon1=90;
lon2=160;
lat1=-5;
lat2=50;
[lon,lat]=meshgrid([lon1:dlon:lon2],[lat1:dlat:lat2]);

tag='2006-09-15_12:00:00'
maindir='../output/';
%maindir='../output/';
file_b=strcat([maindir,'wrffcst_d01_'],tag)
file_a=strcat([maindir,'wrfanal_d01_'],tag)
%file_b='../output/wrfoutput_nc_b';
%file_a='../output/wrfoutput_nc_a';
file_t=strcat('../work/wrf_3dvar_input_d01_',tag)
%file_t='../work/wrfout_d01_2006-09-14_00:00:00';
figure(1);clf
i=1;
    infile=file_t;
    tit=['WRF Domain'];
    %% read the files
    Ps=netcdf_var(infile,'PSFC',0);
    for z=1:length(znu)
        pressure(z,:,:)=5000.0+(squeeze(Ps(1,:,:))-5000.0)*znu(z); 
    end
  
    %P=netcdf_var(infile,'P',0);
    %PB=netcdf_var(infile,'PB',0);
    %pressure=P+PB;
    T=netcdf_var(infile,'T',0);
    th=squeeze(T(1,1,:,:))+300.0;
    pi=(pressure(1,:,:)/1.0e5).^(287.0/1004.0);

    mask=netcdf_var(infile,'XLAND',0);
    land=find(mask==1);
    Tk=squeeze(pi).*th;
    S=Tk-273.16;
    %S(land)=NaN;
    lons=xlon;
    lats=ylat;
    si=S;
    %clevs=[20:0.5:30]
    %clevs=[8.5:0.15:9.7,9.8:0.02:10.2];
    %clevs=[9.88:0.02:10.2];
    %si=squeeze(S(1,:,:))*1.e-4;
    %x1=0.05+(ii-1)*1.05*dx;
    %y1=0.5-((iplt-ii)/2)*1.1*dy;
    %axes('position',[x1 y1 dx dy])
    m_proj('lambert','long',[lon1 lon2],'lat',[lat1 lat2]); hold on
    m_grid('linest','none','box','fancy','tickdir','in');
    %[c,h]=m_contourf(xlon,ylat,squeeze(si),clevs); caxis([clevs(1) clevs(end)]);hold on
    [c,h]=m_contourf(xlon,ylat,squeeze(S),20);
    %[c,h]=contourf(xlon,ylat,squeeze(si)',clevs); caxis([clevs(1) clevs(end)]);hold on
    set(h,'linestyle','none')
    %m_grid('box','fancy','tickdir','in');
    m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    %m_text(120.0,36.2,tit,'horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
    %m_grid('tickdir','in');
       for xo=lono
       for yo=lato
           m_text(xo,yo,'+','horizontalalignment','center','VerticalAlignment','middle','fontsize',12,'fontweight','bold')
       end
       end
    
