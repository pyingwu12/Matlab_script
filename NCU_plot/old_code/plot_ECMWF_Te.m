addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')

clear

%date='120610';  time='00'; 
date='080616';  time='00';  
lev=850;  qscale = 0.15; zint=30;  wtxt=15;

%----
infile=['/SAS010/pwin/EC_plot/EC_',date,time,'.nc'];
outdir='/SAS011/pwin/201work/plot_cal/plot_ECMWF_ana';

%----  
filenam='ECana_the';  
%plon=[95 140];  plat=[10 45];   
plon=[90 135];  plat=[5 40];   
g=9.81;
int=3;

%-----------
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'longitude');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
varid  =netcdf.inqVarID(ncid,'latitude');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
varid  =netcdf.inqVarID(ncid,'level');     level =double(netcdf.getVar(ncid,varid)); 

varid  =netcdf.inqVarID(ncid,'q');     q =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  q=(q.*scale + add);  %** Kg/Kg
  
varid  =netcdf.inqVarID(ncid,'t');     t =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  t=(t.*scale + add);  %**K
  
varid  =netcdf.inqVarID(ncid,'z');     z =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  z=(z.*scale + add)./g;
  
varid  =netcdf.inqVarID(ncid,'u');     u =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  u=u.*scale + add;
varid  =netcdf.inqVarID(ncid,'v');     v =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  v=v.*scale + add;  
  
%spd=( u.^2 + v.^2 ).^0.5;  
  
%%
 cp=1005;  % J/(K*kg)
 Lat=2430; % J/g
 Lc=2.5e6; % J/Kg
 R=287.43;
 eps=0.622; % esp=Rd/Rv=Mv/Md
% Te= t + Lat*q ./ cp  ;
% the = Te .* (1000/lev)^(R/cp) -273;

 nlev=find(level==lev);
 ev=q(:,:,nlev)./eps.*level(nlev);   %partial pressure of water vapor
 theta = t .* (1000/lev)^(R/cp);     %potential temprature
 Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor
 A=1.26e-3;  % K^-1
 B=5.14e-4;  % K^-1
 Tlcl=(1-A.*Td)./(1./Td+B.*log(t(:,:,nlev)./Td)-A);    
 the=theta(:,:,nlev).*exp(Lc.*q(:,:,nlev)./(cp.*Tlcl));
 the=the-273;

%----------------
[yj xi]=meshgrid(y,x);
[nx ny]=size(xi);

%---plot setting---
zg=z(:,:,nlev);
xplot=xi(1:int:nx,1:int:ny);        yplot=yj(1:int:nx,1:int:ny);
uplot=u(1:int:nx,1:int:ny,nlev);    vplot=v(1:int:nx,1:int:ny,nlev);
%----
%%
cmap=[255 255 255; 232 224 224; 215 170 180; 180 125 130 ]./255;
%L=[70 75 80]; 
L=[65 70 75]; 
plotvar=the;
pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
%---shade
figure('position',[100 500 650 500])
m_proj('miller','lon',plon,'lat',plat)
[c hp]=m_contourf(xi,yj,plotvar,L2);   set(hp,'linestyle','none');
hold on
%---
% [c3 hc2]=m_contour(xi,yj,spd(:,:,nlev),[12.5 12.5],'LineStyle','--','color',[0.1 0.3 0.8],'LineWidth',1.8);
% clabel(c3,hc2,'fontsize',12,'color',[0.1 0.3 0.88]);
%-
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',80:10:140,'ytick',10:10:45); 
m_coast('color',[0.3 0.4 0.3],'LineWidth',1);
%---geopotential high---
[c2 hc]=m_contour(xi,yj,zg,'LevelStep',zint,'color',[0.05 0.11 0.02],'LineWidth',1);
clabel(c2,hc,'fontsize',10,'color',[0.1 0.1 0.1]);
%---wind vector
% h1 = m_quiver(xplot,yplot,uplot,vplot,0,'k') ; % the '0' turns off auto-scaling
% hU = get(h1,'UData');   hV = get(h1,'VData') ;
% set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',0.8); 

windmax=20;
windbarbM_mapVer(xplot,yplot,uplot,vplot,13,windmax,[0.08 0.05 0.11],0.7)
windbarbM_mapVer(130.5,6,windmax,0,20,windmax,[0.8 0.05 0.1],1)
m_text(130.8,6,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)

%-------
% h1 = m_quiver(135,13,wtxt,0,0,'r') ; % the '0' turns off auto-scaling
% hU = get(h1,'UData');   hV = get(h1,'VData') ;
% set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.3,'MaxHeadSize',300); 
% set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on') 
% m_text(135,11.5,[num2str(wtxt),'m/s'],'color','r','fontsize',12)
%-------------
cm=colormap(cmap);    caxis([L2(1) L(length(L))])    
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1) 
title(hc,'thetae(^oC)','fontsize',12);
%---------
tit=['20',date,' ',time,'z  ',num2str(lev),'hPa  EC'];
title(tit,'fontsize',15)
outfile=[outdir,'/',filenam,'_',date,time,'_',num2str(lev)];
%print('-dpng',outfile,'-r400')   
set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
system(['rm ',[outfile,'.pdf']]);

