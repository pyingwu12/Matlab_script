%function plot_ECMWF(date,time)
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')

clear

date='120610';  time='00';   
%lev=200;  qscale = 0.05; zint=40;  wtxt=50;
%lev=500;  qscale = 0.08; zint=40;
%lev=850;  qscale = 0.1; zint=20;
lev=925;  qscale = 0.15;  zint=40; wtxt=15;

%Lq=[0.1 0.5 1 2 3 4 5 6 7 8 9]; 
%Lq=[2 4 6 8 10 12 14 16 18 20 22];

%----
infile=['/SAS010/pwin/EC_plot/EC_',date,time,'.nc'];
outdir='/work/pwin/plot_cal/plot_ECMWF_ana';

%load '/work/pwin/data/colormap_qr2.mat';  cmapq=colormap_qr2([1 3 5 8 9 10 11 13 14 15 16 17],:); 

%----  
filenam='ECana_div';  
plon=[95 140];  plat=[10 45];   
g=9.81;
int=10;

%-----------
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'longitude');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
varid  =netcdf.inqVarID(ncid,'latitude');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
varid  =netcdf.inqVarID(ncid,'level');     level =netcdf.getVar(ncid,varid);  

varid  =netcdf.inqVarID(ncid,'d');    div =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  div=(div.*scale + add).*10^5;
varid  =netcdf.inqVarID(ncid,'u');     u =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  u=u.*scale + add;
varid  =netcdf.inqVarID(ncid,'v');     v =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  v=v.*scale + add;
varid  =netcdf.inqVarID(ncid,'z');     z =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  z=(z.*scale + add)./g;

%----------------
[yj xi]=meshgrid(y,x);
[nx ny]=size(xi);
nlev=find(level==lev);

spd=( u.^2 + v.^2 ).^0.5;
%---plot setting---
zg=z(:,:,nlev);
xplot=xi(1:int:nx,1:int:ny);        yplot=yj(1:int:nx,1:int:ny);
uplot=u(1:int:nx,1:int:ny,nlev);    vplot=v(1:int:nx,1:int:ny,nlev);
%----
%%
cmap=[198 226 255; 255 255 255; 255 235 200]./255;
L=[-1 1]; 

plotvar=div(:,:,nlev);
pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
%---shade
figure('position',[100 500 650 500])
m_proj('miller','lon',plon,'lat',plat)
[c hp]=m_contourf(xi,yj,plotvar,L2);   set(hp,'linestyle','none');
hold on
%---
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',100:10:140,'ytick',10:10:45); 
m_coast('color',[0.4 0.4 0.4],'LineWidth',1.1);
%---wind vector
h1 = m_quiver(xplot,yplot,uplot,vplot,0,'k') ; % the '0' turns off auto-scaling
hU = get(h1,'UData');   hV = get(h1,'VData') ;
set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',0.8); 
%---geopotential high---
[c2 hc]=m_contour(xi,yj,zg,'LevelStep',zint,'color',[0.05 0.1 0.02],'LineWidth',1);
clabel(c2,hc,'fontsize',10,'color',[0.1 0.1 0.1]);

%[c3 hc2]=m_contour(xi,yj,spd(:,:,nlev),[55 55],'LineStyle','--','color',[1 0.1 0.1],'LineWidth',1.8);
%clabel(c3,hc2,'fontsize',12,'color',[1 0.1 0.1]);
%--------------
h1 = m_quiver(135,13,wtxt,0,0,'r') ; % the '0' turns off auto-scaling
hU = get(h1,'UData');   hV = get(h1,'VData') ;
set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.3,'MaxHeadSize',300); 
set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on') 
m_text(135,11.5,[num2str(wtxt),'m/s'],'color','r','fontsize',12)
%-------------
cm=colormap(cmap);    caxis([L2(1) L(length(L))])    
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
title(hc,'div.(10^-^5s^-^1)','fontsize',12);
%---------
tit=['20',date,' ',time,'z  ',num2str(lev),'hPa  EC'];
title(tit,'fontsize',15)
outfile=[outdir,'/',filenam,'_',date,time,'_',num2str(lev),''];
%print('-dpng',outfile,'-r400') 
%
set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
system(['rm ',[outfile,'.pdf']]);
  