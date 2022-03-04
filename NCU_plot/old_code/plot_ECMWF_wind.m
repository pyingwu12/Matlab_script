addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')

clear

%date='120610';  time='12'; 
date='080616';  time='00';   
lev=700;  qscale = 0.15; zint=40;  wtxt=15;

%----
infile=['/SAS010/pwin/EC_plot/EC_',date,time,'.nc'];
outdir='/SAS011/pwin/201work/plot_cal/plot_ECMWF_ana';

%----  
filenam='ECana_W';  
%plon=[80 145];  plat=[0 50];   
plon=[95 140];  plat=[10 45];   
g=9.81;
int=10;

%-----------
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'longitude');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
varid  =netcdf.inqVarID(ncid,'latitude');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
varid  =netcdf.inqVarID(ncid,'level');     level =netcdf.getVar(ncid,varid); 
  
varid  =netcdf.inqVarID(ncid,'z');     z =double(netcdf.getVar(ncid,varid));
  z=(z.*7.5451769647544 + 242735.061395893)./g;
  
varid  =netcdf.inqVarID(ncid,'u');     u =double(netcdf.getVar(ncid,varid));
  u=u.*0.00304756154655026 + 46.9444295883673;
varid  =netcdf.inqVarID(ncid,'v');     v =double(netcdf.getVar(ncid,varid));
  v=v.*0.00207261403382289 + 3.69694648106903;  
  
spd=( u.^2 + v.^2 ).^0.5;

varid  =netcdf.inqVarID(ncid,'w');     w =double(netcdf.getVar(ncid,varid));
  w=(w.*0.000166350004901589 + -1.00113317042481);
  
%----------------
[yj xi]=meshgrid(y,x);
[nx ny]=size(xi);
nlev=find(level==lev);

%---plot setting---
zg=z(:,:,nlev);
xplot=xi(1:int:nx,1:int:ny);        yplot=yj(1:int:nx,1:int:ny);
uplot=u(1:int:nx,1:int:ny,nlev);    vplot=v(1:int:nx,1:int:ny,nlev);
%----
%%
cmap=[180 245 245; 255 255 255; 255 245 170;]./255;
L=[-0.1 0.1]; 
plotvar=w(:,:,nlev);
pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
%---shade
figure('position',[100 500 600 500])
m_proj('miller','lon',plon,'lat',plat)
[c hp]=m_contourf(xi,yj,plotvar,L2);   set(hp,'linestyle','none');
hold on
%---
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',70:20:140); 
m_coast('color',[0.4 0.4 0.4],'LineWidth',1.1);
%---geopotential high---
[c2 hc]=m_contour(xi,yj,zg,'LevelStep',zint,'color',[0.05 0.1 0.02],'LineWidth',1);
clabel(c2,hc,'fontsize',10,'color',[0.1 0.1 0.1]);
%---wind vector
h1 = m_quiver(xplot,yplot,uplot,vplot,0,'k') ; % the '0' turns off auto-scaling
hU = get(h1,'UData');   hV = get(h1,'VData') ;
set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',0.8); 
%----
%m_text(145,52,'w(Pa/s)','fontsize',12)

%--------------
h1 = m_quiver(135,13,wtxt,0,0,'r') ; % the '0' turns off auto-scaling
hU = get(h1,'UData');   hV = get(h1,'VData') ;
set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.3,'MaxHeadSize',300); 
set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on') 
m_text(135,11.5,[num2str(wtxt),'m/s'],'color','r','fontsize',12)
%-------------
cm=colormap(cmap);    caxis([L2(1) L(length(L))])    
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1) 
title(hc,'w(Pa/s)','fontsize',12);
%---------
tit=['20',date,' ',time,'z  ',num2str(lev),'hPa  EC'];
title(tit,'fontsize',15,'FontWeight','bold')
outfile=[outdir,'/',filenam,'_',date,time,'_',num2str(lev),'_new'];
%print('-dpng',outfile,'-r400')   
% set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
% system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
% system(['rm ',[outfile,'.pdf']]); 