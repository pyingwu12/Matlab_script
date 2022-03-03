%close all
clear 
addpath('/work/pwin/m_map1.4/')
javaaddpath('/SAS007/sz6414/read_netcdf4/netcdfAll-4.2.jar');
javaaddpath ('/SAS007/sz6414/read_netcdf4/mexcdf/snctools/classes');
addpath ('/SAS007/sz6414/read_netcdf4/mexcdf/mexnc');
addpath ('/SAS007/sz6414/read_netcdf4/mexcdf/snctools');


%---------plot-----------------------------
%indir='/SAS002/pwin/expri_cct';
%infilr='/SAS009/sz6414/IOP8/Goddard/DA/e18const_all3v4/cycle01';
%indir='/SAS005/pwin/expri_shao/WRFV3/';
indir='/SAS007/pwin/expri_largens/WRF_shao';
%indir='/SAS007/pwin/expri_sz6414/e18_ensfcst_0020/pert01';
%indir='/SAS002/pwin/expri_241/morakot_sing_noda';
%indir='/SAS009/pwin/expri_whatsmore/vr124';
%indir='/SAS002/pwin/expri_SC/2008IOP8_e01';
%indir='/SAS005/pwin/expri_lider/bonnie';
%indir='/SAS002/pwin/expri_IOP8/IOP8_0614e01';

year='2008'; mon='06'; date='16';  hr='00';  expri='shao';
%year='2009'; mon='08'; date='09';  hr='00';  expri='cct';

%---d01---
infile=[indir,'/wrfout_d01_',year,'-',mon,'-',date,'_',hr,':00:00'];
ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'XLONG');     x01 =double(netcdf.getVar(ncid,varid));
     varid  =netcdf.inqVarID(ncid,'XLAT');      y01 =double(netcdf.getVar(ncid,varid));
%---d02---
infile=[indir,'/wrfout_d02_',year,'-',mon,'-',date,'_',hr,':00:00'];
ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'XLONG');      x02 =double(netcdf.getVar(ncid,varid));
     varid  =netcdf.inqVarID(ncid,'XLAT');       y02 =double(netcdf.getVar(ncid,varid));

%---d03---
%infile=[indir,'/wrfout_d03_',year,'-',mon,'-',date,'_',hr,':00:00'];
%ncid = netcdf.open(infile,'NC_NOWRITE');
%     varid  =netcdf.inqVarID(ncid,'XLONG');      x03 =double(netcdf.getVar(ncid,varid));
%     varid  =netcdf.inqVarID(ncid,'XLAT');       y03 =double(netcdf.getVar(ncid,varid));
%
%---d04---
% infile=[indir,'/wrfout_d04_',year,'-',mon,'-',date,'_',hr,':00:00'];
% ncid = netcdf.open(infile,'NC_NOWRITE');
%      varid  =netcdf.inqVarID(ncid,'XLONG');      x04 =double(netcdf.getVar(ncid,varid));
%      varid  =netcdf.inqVarID(ncid,'XLAT');       y04 =(netcdf.getVar(ncid,varid));

 truelat1 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT1')); 
 truelat2 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT2'));
 cen_lon =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LON'));
 cen_lat =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LAT'));
 netcdf.close(ncid)
%---terrain---
infile='/SAS004/pwin/data/WPS/geo_em.d01.nc';
%infile='/SAS007/sz6414/plot/terr.nc4';
lon=squeeze(nc_varget(infile,'XLONG_M'));
lat=squeeze(nc_varget(infile,'XLAT_M'));
hgt=squeeze(nc_varget(infile,'HGT_M'));

%================================================= 

  A=load(['/SAS004/pwin/data/obs_sz6414/obs_d03_',year,'-',mon,'-',date,'_',hr,':00:00']);
%  A=load('/SAS004/pwin/data/obs_morakot/obs_d03_2009-08-08_16:00:00');
% 
the=0:0.01:2*pi;

ralocx4=120.086; ralocy4=23.1467;
B=A(A(:,1)==4,:);
[maxran4 maxloc4]=max(B(B(:,4)<270,4));
maxlon=B(maxloc4,5);
maxlat=B(maxloc4,6);

r4=( (maxlon-ralocx4)^2 + (maxlat-ralocy4)^2 )^0.5 ;

yr4=(r4-0.1)*cos(the)+ralocy4;
xr4=r4*sin(the)+ralocx4;

%--------
ralocx3=120.8471; ralocy3=21.9026;
C=A(A(:,1)==3,:);
[maxran3 maxloc3]=max(C(:,4));
maxlon3=C(maxloc3,5);
maxlat3=C(maxloc3,6);

r3=( (maxlon3-ralocx3)^2 + (maxlat3-ralocy3)^2 )^0.5 ;

yr3=(r3-0.1)*cos(the)+ralocy3;
xr3=r3*sin(the)+ralocx3;
% 
% %---
% ralocx1=121.6201; ralocy1=23.9903;
% D=A(A(:,1)==1,:);
% [maxran1 maxloc1]=max(D(:,4));
% maxlon1=D(maxloc1,5);
% maxlat1=D(maxloc1,6);
% 
% r1=( (maxlon1-ralocx1)^2 + (maxlat1-ralocy1)^2 )^0.5 ;
% 
% yr1=(r1-0.1)*cos(the)+ralocy1;
% xr1=r1*sin(the)+ralocx1;
% 
% %---
% ralocx2=121.7725; ralocy2=25.0725;
% E=A(A(:,1)==2,:);
% [maxran2 maxloc2]=max(E(:,4));
% maxlon2=E(maxloc2,5);
% maxlat2=E(maxloc2,6);
% 
% r2=( (maxlon2-ralocx2)^2 + (maxlat2-ralocy2)^2 )^0.5 ;
% 
% yr2=(r2-0.1)*cos(the)+ralocy2;
% xr2=r2*sin(the)+ralocx2;
%----------------------------
sst=ones(size(x02));
for i=1:size(x02,1)
   for j=1:size(x02,1)
%     if ((lon1(i,j)-ralocx1).^2+(lat1(i,j)-ralocy1).^2).^0.5 < r1 || ((lon1(i,j)-ralocx2).^2+(lat1(i,j)-ralocy2).^2).^0.5 < r2 ||...
%      if  ((x02(i,j)-ralocx3).^2+(y02(i,j)-ralocy3).^2).^0.5 < r3 || ((x02(i,j)-ralocx4).^2+(y02(i,j)-ralocy4).^2).^0.5 < r4 || ...
%      if  ((x02(i,j)-ralocx3).^2+(y02(i,j)-ralocy3).^2).^0.5 < r3 || ((x02(i,j)-ralocx4).^2+(y02(i,j)-ralocy4).^2).^0.5 < r4 || ...
%              ((x02(i,j)-ralocx2).^2+(y02(i,j)-ralocy2).^2).^0.5 < r2
     if  ((x02(i,j)-ralocx3).^2+(y02(i,j)-ralocy3).^2).^0.5 < r3 || ((x02(i,j)-ralocx4).^2+(y02(i,j)-ralocy4).^2).^0.5 < r4 
        sst(i,j)=0;
     end
   end
end


%==================================================

%----
figure('position',[100 200 900 750])
%m_proj('miller','lon',d01x,'lat',d01y)
m_proj('Lambert','lon',double([x01(1,1) x01(end,1)]),'lat',double([y01(1,1) y01(1,end)]),'clongitude',cen_lon,'parallels',[truelat1 truelat2],'rectbox','on')

coast=1; %hgt(hgt<coast-0.5)=NaN;
[c hp]=m_contourf(lon,lat,hgt,[coast,500:500:3500],'linestyle','none'); hold on
cm=colormap(m_colmap('greens',24));  brighten(.7);
m_contour(lon,lat,hgt,[coast coast],'k','linewidth',0.9)
hc=colorbar('linewidth',1.1,'fontsize',16);
%title(hc,'m','position',[0.5 -150 0],'fontsize',18)
xlabel(hc,'m')

%m_plot(x01(:,1),y01(:,1),'color',[0 0 0],'linewi',1.5); hold on
%m_plot(x01(1,:),y01(1,:),'color',[0 0 0],'linewi',1.5)
%m_plot(x01(:,end),y01(:,end),'color',[0 0 0],'linewi',1.5)
%m_plot(x01(end,:),y01(end,:),'color',[0 0 0],'linewi',1.5)
m_plot(x02(:,1),y02(:,1),'color',[0 0 0],'linewi',1.8); hold on
m_plot(x02(1,:),y02(1,:),'color',[0 0 0],'linewi',1.8)
m_plot(x02(:,end),y02(:,end),'color',[0 0 0],'linewi',1.8)
m_plot(x02(end,:),y02(end,:),'color',[0 0 0],'linewi',1.8)

%m_plot(x03(:,1),y03(:,1),'color',[0 0 0],'linewi',1.5); hold on
%m_plot(x03(1,:),y03(1,:),'color',[0 0 0],'linewi',1.5)
%m_plot(x03(:,end),y03(:,end),'color',[0 0 0],'linewi',1.5)
%m_plot(x03(end,:),y03(end,:),'color',[0 0 0],'linewi',1.5)

m_text((x01(1,end)+0.5),(y01(1,end)-0.8),'D01','fontsize',20,'FontWeight','bold');
m_text((x02(1,end)+0.5),(y02(1,end)-0.75),'D02','fontsize',20,'FontWeight','bold');
%m_text((x03(1,end)+0.5),(y03(1,end)-0.8),'3km','fontsize',15,'FontWeight','bold');
%-------------------------
m_grid('fontsize',18,'LineStyle','-.','LineWidth',1.1,'backcolor',[0.3 0.7 1],'xtick',100:5:140,'ytick',5:5:45);
handles=findobj(gca,'tag','m_grid_xticklabel');
delete(handles(1));
%m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
%m_coast('color','k');
%m_gshhs_h('color','k','linewi',1.1);
% 
%---------------
    m_plot(ralocx4,ralocy4,'ok','MarkerFaceColor',[1 0 0],'MarkerSize',6); 
%    m_plot(xr4,yr4,'r','LineWidth',1.3)
% 
    m_plot(ralocx3,ralocy3,'ok','MarkerFaceColor',[0 0 1],'MarkerSize',6)
%    m_plot(xr3,yr3,'b','LineWidth',1.3);
%
%    m_plot(ralocx1,ralocy1,'og','MarkerFaceColor',[0 1 0],'MarkerSize',5)
%    m_plot(xr1,yr1,'g','LineWidth',1.3);
%       
%    m_plot(ralocx2,ralocy2,'ok','MarkerFaceColor',[0 0 0],'MarkerSize',4)
%    m_plot(xr2,yr2,'b','LineWidth',1.3);
%-
    m_contour(x02,y02,sst,[1,1],'color',[0.35,0.35,0.4],'linewidth',2.1,'linestyle','-')  %radar range
%    m_text(ralocx2+0.3,ralocy2-0.2,'RCWF','color',[0 0 0],'fontsize',11);
    m_text(ralocx4+0.3,ralocy4-0.2,'RCCG','color',[1 0 0],'fontsize',15,'FontWeight','bold');
    m_text(ralocx3+0.3,ralocy3-0.2,'RCKT','color',[0 0 1],'fontsize',15,'FontWeight','bold');

%---------------
%title([expri,' domain'],'fontsize',15)

outfile=['domain_',expri];
%print('-dpng',[expri,outfile,'.png'],'-r400')  
%print([expri,outfile,'.pdf'],'-dpdf')
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 600 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 

%}
