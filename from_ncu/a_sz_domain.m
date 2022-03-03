clear all;clc;close all;
javaaddpath('/SAS007/sz6414/read_netcdf4/netcdfAll-4.2.jar');
javaaddpath ('/SAS007/sz6414/read_netcdf4/mexcdf/snctools/classes');
addpath ('/SAS007/sz6414/read_netcdf4/mexcdf/mexnc');
addpath ('/SAS007/sz6414/read_netcdf4/mexcdf/snctools');

addpath('/SAS007/sz6414/m_map/');
%infile='/SAS009/sz6414/201706/Goddard/initial_field/17060100_forDA/cycle01/wrfinput_d01';
infile='/SAS005/pwin/expri_whatsmore/noda/wrfout_d01_2012-06-10_12:00:00';
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'XLONG');  lon1 =netcdf.getVar(ncid,varid,'double');
varid  =netcdf.inqVarID(ncid,'XLAT');   lat1 =netcdf.getVar(ncid,varid,'double');
%varid  =netcdf.inqVarID(ncid,'HGT');    HGT1 =netcdf.getVar(ncid,varid,'double');
varid  =netcdf.inqVarID(ncid,'SST');    sst =netcdf.getVar(ncid,varid,'double');
netcdf.close(ncid)
%HGT=squeeze(nc_varget(infile,'HGT'));
%infile='/SAS007/sz6414/plot/terr.nc4';
infile='/SAS007/sz6414/WRFV3.7.1_iSPPT_nc4/WPS/geo_em.d01.nc';
lon=squeeze(nc_varget(infile,'XLONG_M'));
lat=squeeze(nc_varget(infile,'XLAT_M'));
HGT=squeeze(nc_varget(infile,'HGT_M'));

coast_height=1;
%m_proj('Lambert','lon',[109 133],'lat',[11.5 35.5],'clongitude',121,'parallels',[40 10],'rectbox','on')
%m_proj('Lambert','lon',[117 125],'lat',[19.5 27.25],'clongitude',121,'parallels',[40 10],'rectbox','on')
m_proj('Lambert','lon',[99.7 143],'lat',[7 42],'clongitude',121,'parallels',[40 10],'rectbox','on')%200806
%m_proj('Lambert','lon',[109.5 136],'lat',[8 35],'clongitude',121,'parallels',[40 10],'rectbox','on')%201206
%m_coast('patch',[0 120/255 50/255]);
%m_gshhs_h('patch',[0 120/255 50/255]);
hold on
%[CS,CH]=m_contourf(lon,lat,HGT,[100,500:500:3000],'linestyle','none');
%[CS,CH]=m_contourf(lon,lat,HGT,[500:500:3000],'linestyle','none');
[CS,CH]=m_contourf(lon,lat,HGT,[coast_height,500:500:3500],'linestyle','none');
%[CS,CH]=m_contourf(lon1,lat1,HGT1,[1,500:250:2000],'linestyle','none');
colormap(m_colmap('greens',24));
brighten(.5);
%ax=m_contfbar(0.95,[.1 .8],CS,CH);
ax=m_contfbar(1,[.1 .8],CS,CH);
title(ax,{'m',''});
%m_grid('box','fancy','linestyle','-','gridcolor','k','backcolor',[.2 .65 1],'xtick',7);
%m_grid('box','fancy','linestyle','-','gridcolor','k','backcolor',[.2 .65 1],'xtick',5);
%m_grid('linestyle','-','gridcolor','k','backcolor',[.2 .65 1],'xtick',5);
%m_grid('linestyle','-','gridcolor','k','backcolor',[.2 .65 1],'xtick',8,'ytick',7);
m_grid('linestyle','-','gridcolor','k','backcolor',[.2 .65 1],'xtick',12,'ytick',9);
%m_line([115.8 116 125.8 126 115.8],[27.5 19 19 27.5 27.5],'color','k','linewi',2)
%m_text(115.9,27,'d02','fontweight','bold')
%m_line([116.6 116.9 125.1 125.4 116.6 116.9],[27.15 19.4 19.4 27.15 27.2 19.4],'color','k','linewi',2)
%m_text(116.7,26.65,'d02','fontweight','bold')
m_line([116.6 116.8 125.7 126 116.6 116.8],[27 19 19 27 27 19],'color','k','linewi',2)
m_text(116.8,26,'d03','fontweight','bold')
m_line([111 112.2 128.5 129.5 111 112.2],[31 15.5 15.5 31 31 15.5],'color','k','linewi',2)
m_text(111.7,30,'d02','fontweight','bold')
[CS,CH]=m_contour(lon,lat,HGT,[coast_height,coast_height],'k');

%-------------------------------------------
%A=load('/SAS004/pwin/data/obs_201206/obs_d03_2012-06-10_06:00:00');
A=load('/SAS007/sz6414/IOP8/data4SO/DA_data_HWQC/obs_d03_2008-06-16_01:45:00');
sst(:,:)=1;

%ralocx1=121.6201; ralocy1=23.9903;
%D=A(A(:,1)==1,:);
%[maxran1 maxloc1]=max(D(:,4));
%maxlon1=D(maxloc1,5);
%maxlat1=D(maxloc1,6);
%r1=( (maxlon1-ralocx1)^2 + (maxlat1-ralocy1)^2 )^0.5 ;
%-------------
%ralocx2=121.7725; ralocy2=25.0725;
%E=A(A(:,1)==2,:);
%[maxran2 maxloc2]=max(E(:,4));
%maxlon2=E(maxloc2,5);
%maxlat2=E(maxloc2,6);
%r2=( (maxlon2-ralocx2)^2 + (maxlat2-ralocy2)^2 )^0.5 ;
%--------------
ralocx3=120.8471; ralocy3=21.9026;
D=A(A(:,1)==3,:);
[maxran1 maxloc1]=max(D(:,4));
maxlon3=D(maxloc1,5);
maxlat3=D(maxloc1,6);
r3=( (maxlon3-ralocx3)^2 + (maxlat3-ralocy3)^2 )^0.5 ;
%----------------
ralocx4=120.086; ralocy4=23.1467;
B=A(A(:,1)==4,:);
[maxran4 maxloc4]=max(B(:,4));
maxlon4=B(maxloc4,5);
maxlat4=B(maxloc4,6);
r4=( (maxlon4-ralocx4)^2 + (maxlat4-ralocy4)^2 )^0.5 ;
for i=1:length(lon1(:,1))
   for j=1:length(lon1(1,:))
%     if ((lon1(i,j)-ralocx1).^2+(lat1(i,j)-ralocy1).^2).^0.5 < r1 || ((lon1(i,j)-ralocx2).^2+(lat1(i,j)-ralocy2).^2).^0.5 < r2 ||...
      if  ((lon1(i,j)-ralocx3).^2+(lat1(i,j)-ralocy3).^2).^0.5 < r3 || ((lon1(i,j)-ralocx4).^2+(lat1(i,j)-ralocy4).^2).^0.5 < r4
        sst(i,j)=0;
     end
   end
end
m_contour(lon1,lat1,sst,[1,1],'color',[0.4,0.4,0.4],'linewidth',2)
%m_plot(ralocx1,ralocy1,'^r','MarkerFaceColor','r','MarkerSize',6);
%m_text(ralocx1+0.4,ralocy1,'RCHL','fontweight','bold');
%m_plot(ralocx2,ralocy2,'^r','MarkerFaceColor','r','MarkerSize',6);
%m_text(ralocx2+0.4,ralocy2,'RCWF','fontweight','bold');
m_plot(ralocx3,ralocy3,'^r','MarkerFaceColor','r','MarkerSize',6);
m_text(ralocx3+0.4,ralocy3-0.5,'RCKT','fontweight','bold');
m_plot(ralocx4,ralocy4,'^r','MarkerFaceColor','r','MarkerSize',6);
m_text(ralocx4-3.3,ralocy4-0.5,'RCCG','fontweight','bold');

title('200806 domain','fontsize',15,'fontweight','bold')
print_sz('/SAS007/sz6414/wpsdom/200806domain_d01')
