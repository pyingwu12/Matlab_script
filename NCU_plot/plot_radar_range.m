%close all
clear 
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')


A=load('/SAS004/pwin/data/obs_sz6414/obs_d03_2008-06-16_02:00:00');

the=0:0.01:2*pi;


ralocx4=120.086; ralocy4=23.1467;
B=A(A(:,1)==4,:);
[maxran4 maxloc4]=max(B(:,4));
maxlon=B(maxloc4,5);
maxlat=B(maxloc4,6);

r4=( (maxlon-ralocx4)^2 + (maxlat-ralocy4)^2 )^0.5 ;

yr4=(r4-0.1)*cos(the)+ralocy4;
xr4=r4*sin(the)+ralocx4;


ralocx3=120.8471; ralocy3=21.9026;
C=A(A(:,1)==3,:);
[maxran3 maxloc3]=max(C(:,4));
maxlon3=C(maxloc3,5);
maxlat3=C(maxloc3,6);

r3=( (maxlon3-ralocx3)^2 + (maxlat3-ralocy3)^2 )^0.5 ;

yr3=(r3-0.1)*cos(the)+ralocy3;
xr3=r3*sin(the)+ralocx3;

%%

%======
indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_0614e01'];
outdir=['/work/pwin/plot_cal/IOP8/'];
L=[100 250 500 1000 1200 1500 2000 2500 3000];

%colormap_tern=[221 239 253; 182 217 154; 217 233 160; 250 215 151; 226 169 115; 185 142 108 ]./255;
%{
colormap_tern=[121 168  39;
               130 200  39;
               175 214  89;
               217 239 123;
               240 220 124;
               243 196  54;
               243 150  75;
               245 112  38;
               225 105  41
               186 107  31]./255;
%}
load '/work/pwin/data/colormap_tern.mat'
cmap=colormap_tern;

%---
infile=[indir,'/wrfout_d02_2008-06-14_12:00:00_mean'];
%----read netcdf data--------
  ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'HGT');    hgt =netcdf.getVar(ncid,varid);
   hgt(hgt<=0.01)=NaN;
%---plot
   figure('position',[200 100 600 500])
   m_proj('Lambert','lon',[116.4 125.3],'lat',[19 27.5],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
     if min(min(hgt(:,:)))<L(1); L2=[min(min(hgt(:,:))),L]; else L2=[L(1) L]; end
     [c hp]=m_contourf(x,y,hgt,L2);   set(hp,'linestyle','none'); hold on
     colorbar;   cm=colormap(cmap); hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
     m_plot(ralocx4,ralocy4,'^k','MarkerFaceColor',[0 0 0],'MarkerSize',6.5)
     m_plot(xr4,yr4,'k','LineWidth',2)

     m_plot(ralocx3,ralocy3,'^b','MarkerFaceColor',[0 0 1],'MarkerSize',6.5)
     m_plot(xr3,yr3,'b','LineWidth',2);
%---
   m_grid('fontsize',12);
   %m_coast('color','k');
   %m_gshhs_h('color','k');
   tit='Radar observation range with terrain';
   title(tit,'fontsize',15)
   outfile=[outdir,'radar_range'];
   %print('-dpng',outfile,'-r350')  
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
   netcdf.close(ncid)
   
   %%


%{
%----
figure('position',[100 100 600 500])
%m_proj('miller','lon',[90 150],'lat',[0 60])
m_proj('Lambert','lon',[117 125],'lat',[19.8 27.5],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')

m_plot(x04,y04,'or','MarkerFaceColor',[1 0 0],'MarkerSize',5); hold on
m_plot(xr4,yr4,'r')

m_plot(x03,y03,'or','MarkerFaceColor',[1 0 0],'MarkerSize',5)
m_plot(xr3,yr3,'r');


%m_grid('box','fancy','tickdir','in');
m_grid('fontsize',12);
%m_coast('color','k');
m_gshhs_h('color','k');

%utfile='domain_lider.png';
%print('-dpng',outfile,'-r350')   

%}

