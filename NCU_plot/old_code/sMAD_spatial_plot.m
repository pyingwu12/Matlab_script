%function  sMAD_spatial_plot(plotid)

clear
%hr=12;  minu='00';  

plotid=9;  %!!1:Vr-V, 2:Vr-U, 3:Vr-qv, 4:Vr-qr,  7:Zh-V, 8:Zh-U....
if plotid<=6; vonam='Vr'; else; vonam='Zh'; end
vmnam0={'V';'U';'QVAPOR';'QRAIN';'T';'QCLOUD'};  % !!!!!!! same as function <Corr256n40allvari_fun>
if mod(plotid,6)==0; vmnam='QCLOUD'; else; vmnam=vmnam0{mod(plotid,6)}; end

%---set---
outdir=['/SAS011/pwin/201work/plot_cal/largens/LE0614'];
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
addpath('/SAS011/pwin/201work/plot_cal')
cmap=[ 0.95 0.95 0.95; 0.81 0.81 0.81 ; 0.65 0.65 0.65; 0.45 0.45 0.45 ;  0.25 0.25 0.25;  0.05 0.05 0.05];
%cmap=[ 117  33  10;  199  85  66;    217 154 159;     220 220 220;    150 150 150;     65 65 65]./255;
%cmap=[ 220 220 220; 150 150 150;  65 65 65;  217 154 159;  199  85  66;  117  33  10 ]./255;
%cmap=flipud(cmap);
L=[0.2 0.25 0.3 0.35 0.4];

%---
if strcmp(vmnam(1),'Q')==1;  s_vm=[vmnam(1),lower(vmnam(2))];  else  s_vm=vmnam; end
corrvari=[vonam,',',lower(s_vm)];
%
varinam=['SMADs of CORR(',vonam,', ',s_vm,')'];    filenam=['Corr-sMAD_'];
%
sub=12;
%sub2=sub*2+1;
plon=[118.4 121.8]; plat=[20.65 24.35];
%----------------------------------------------------
load('zhmean_40_LE0614.mat')
%---------------------------------------------------
hr=12;  minu='00'; expri='LE0614'; s_hr=num2str(hr,'%2.2d');
indir=['/SAS009/pwin/expri_largens/',expri];
infilenam='wrfmean40';    type='mean';
dom='02'; year='2008'; mon='06'; date='14';

infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
ncid = netcdf.open(infile,'NC_NOWRITE');
%varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
%varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
%varid  =netcdf.inqVarID(ncid,'QVAPOR');     qv =netcdf.getVar(ncid,varid);
%varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
%varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid);
varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);

%---
%g=9.81;
%P=(pb+p);   [nx ny nz]=size(qv);
%dP=P(:,:,1:nz-1)-P(:,:,2:nz);
%tpw= dP.*( (qv(:,:,2:nz)+qv(:,:,1:nz-1)).*0.5 ) ;
%TPW=sum(tpw,3)./g;

%u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
%v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
%int=20;  lev=10;
%xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
%uplot=u.unstag(1:int:nx,1:int:ny,lev);   vplot=v.unstag(1:int:nx,1:int:ny,lev);

%windmax=15;  scale=15;
%
%----------------------------------------------------
figure('position',[100 200 600 500])
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')

for irad=[3 4];
s_rad=num2str(irad);
%
load(['stnerr_',s_rad,'-0.5-53_12.mat']);  Var=err(1:2:end,plotid);
lon=lon(1:2:end); lat=lat(1:2:end);
plot_point(Var,lon,lat,cmap,L);

load(['stnerr_',s_rad,'-0.5-63_12.mat']);  Var=err(1:2:end,plotid);
lon=lon(1:2:end); lat=lat(1:2:end);
plot_point(Var,lon,lat,cmap,L);

load(['stnerr_',s_rad,'-0.5-73_12.mat']);  Var=err(:,plotid);
plot_point(Var,lon,lat,cmap,L);
%
%load(['stnerr_',s_rad,'-0.5-68_12.mat']);  Var=err(:,plotid); 
%hp=plot_point(Var,lon,lat,cmap,L);
%
load(['stnerr_',s_rad,'-0.5-83_12.mat']);  Var=err(:,plotid);
hp=plot_point(Var,lon,lat,cmap,L);

%load(['stnerr_',s_rad,'-0.5-78_12.mat']);  Var=err(:,plotid);
%hp=plot_point(Var,lon,lat,cmap,L);
%
load(['stnerr_',s_rad,'-0.5-93_12.mat']);  Var=err(:,plotid);
plot_point(Var,lon,lat,cmap,L);
%
load(['stnerr_',s_rad,'-0.5-103_12.mat']);  Var=err(:,plotid);
hp=plot_point(Var,lon,lat,cmap,L);

load(['stnerr_',s_rad,'-0.5-113_12.mat']);  Var=err(:,plotid);
plot_point(Var,lon,lat,cmap,L);

%load(['stnerr_',s_rad,'-1.4-38_12.mat']);  Var=err(1:2:end,plotid);
%lon=lon(1:2:end); lat=lat(1:2:end);
%plot_point(Var,lon,lat,cmap,L);

end

  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:45);
 % m_gshhs_h('color','k','LineWidth',0.8);
  %m_coast('color','k');
  cm=colormap(cmap);    caxis([L(1) L(length(L))]);
  hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);

lonrad=120.8471; latrad=21.9026;
 m_plot(lonrad,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',10)
% m_text(lonrad+0.09,latrad+0.08,'RCKT','color',[0.1 0.7 0.1],'fontsize',11,'FontWeight','bold')
lonrad=120.086; latrad=23.1467;
 m_plot(lonrad,latrad,'^','color',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',10)
% m_text(lonrad+0.09,latrad+0.08,'RCCG','color',[0.1 0.7 0.1],'fontsize',11,'FontWeight','bold')

%[c hp]=m_contour(x,y,zh_mean,[42 42],'color',[0.8 0.15 0.8],'LineWidth',1.2);
[c hp]=m_contour(x,y,zh_mean,[40 40],'color',[1 0.2 0.2],'LineWidth',1.1);
%[c hp]=m_contour(x,y,TPW,[65.5 65.5],'color',[0.2 0.3 0.9],'LineWidth',1.2);
%clabel(c,hp,'fontsize',12,'color',[0.2 0.3 0.9],'LabelSpacing',600);
%windbarbM_mapVer(xi,yi,uplot,vplot,scale,windmax,[0.05 0.02 0.5],0.8)
%[c hp]=m_contour(x,y,u.unstag(:,:,lev),[9.5 9.5],'color',[0.8 0.15 0.8],'LineWidth',1.2);
%[c hp]=m_contour(x,y,v.unstag(:,:,lev),[9.5 9.5],'color',[0.8 0.8 0.15],'LineWidth',1.2);

   s_hr=num2str(hr,'%.2d');
   %tit=[varinam,'  ',s_hr,'00UTC'];
   tit=[varinam];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',vonam,'-',lower(s_vm),'_sub',num2str(sub)];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);

%}

