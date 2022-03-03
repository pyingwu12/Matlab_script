%-------------------------------------------------------
% Plot Zh mean or single (DA cycle & forecasting time)
%-------------------------------------------------------

clear all
close all

hm='00:00';   expri='largens';   sw=0.5;   zmind=0;
%---DA or forecast time---
infilenam='wrfmean';  type='mean'; %!notice
%infilenam='wrfout';   type='sing'; 
%infilenam='fcstmean';  type=infilenam(1:4); %!notice

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/work/pwin/data/largens_wrf2obs_',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[-14 -10 -7 -3 -1 0 1 3 7 10 14];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_vr.mat';  cmap=colormap_vr([1 3 4 5 6 8 9 11 12 13 14 15],:); 
%---
varinam='Vr';    filenam=[expri,'_vr_'];  
if zmind~=0;  filenam=['zm_',filenam];  end
num=size(hm,1);
plon=[117.5 122.5]; plat=[20.5 25.65];

%---
for ti=1:num;
  time=hm(ti,:);   
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile); 
  lon=A(:,5); lat=A(:,6);  vr=A(:,8); 
  %----
  indir=['/SAS009/pwin/expri_largens/',expri];  lev=12; int=12;
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    x =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'XLAT');     y =double(netcdf.getVar(ncid,varid));
  varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
  varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
  netcdf.close(ncid)
   [nx ny]=size(x); nz=size(u.stag,3);
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;
   uplot=u.unstag(1:int:nx,1:int:ny,lev);   vplot=v.unstag(1:int:nx,1:int:ny,lev);
   xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
   filenam=['wind_',filenam];
  %---
%  plotvar=vr;
  for swi=sw
%    swi2=fix(swi); fin=find(ela>swi2 & ela<swi2+1);
    fin=find(vr~=-9999 & A(:,2)==swi);
    plot_lon=lon(fin); plot_lat=lat(fin);  plot_vr=vr(fin);
    hc=plot_radar(plot_vr,plot_lon,plot_lat,cmap,L,zmind,plon,plat);
    %---model wind---
    windmax=15;  scale=15; vcolor=[0 0 0];
    windbarbM_mapVer(xi,yi,uplot,vplot,scale,windmax,vcolor,1.3)
    windbarbM_mapVer(plon(1)+0.24,plat(1)+0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1.3)
    m_text(plon(1)+0.25,plat(1)+0.2,[num2str(windmax),' m/s'],'color',[0.8 0.05 0.1],'fontsize',14)
    %----------------
%    tit=[expri,'  ',varinam,'  ',time(1:2),time(4:5),'z  (',type,' ',num2str(swi),')'];
%    title(tit,'fontsize',15)
    tit='Radial wind (ensemble mean)';
    title(tit,'fontsize',18,'Position',[-0.016 0.0455],'FontWeight','bold')
    %
    outfile=[outdir,'/',filenam,time(1:2),time(4:5),'_',type,'_',num2str(swi)];
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 600 ',outfile,'.pdf ',outfile,'.png']);
%     system(['rm ',[outfile,'.pdf']]);  
  end
%}
end
