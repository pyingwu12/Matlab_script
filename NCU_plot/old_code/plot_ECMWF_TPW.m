function plot_ECMWF_TPW(time,L,outdir) 

addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')

%clear

date='120610';  %time='12';   
%date='080616';  time='00';  
qscale=6;  wtxt=0.2;   %lev=850; %wind level
%qscale:the standard size of all wind arrow, wtxt: the value of the wind arrow lengend
qflev=31:37;

%----
%outdir='/SAS011/pwin/201work/plot_cal/plot_ECMWF_ana';
%load '/work/pwin/data/colormap_qr2.mat';   %cmap=colormap_qr2([1 3 8 9 10 13 14 15],:);
%load '/work/pwin/data/colormap_grads.mat';  cmap=colormap_grads([1 3 4 6 8 9 11 12 13],:);
load '/work/pwin/data/colormap_grads.mat';  cmap=colormap_grads;
%----  
filenam='ECana_tpw';  
%plon=[80 145];  plat=[0 50];  
%plon=[90 135];  plat=[5 40];   
plon=[106 125];  plat=[12 32];   
g=9.81;  int=6;

%
infile=['/SAS010/pwin/EC_plot/EC_',date,time,'.nc'];
%----read file-------
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'longitude');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
varid  =netcdf.inqVarID(ncid,'latitude');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
varid  =netcdf.inqVarID(ncid,'level');     level =double(netcdf.getVar(ncid,varid)); 

varid  =netcdf.inqVarID(ncid,'q');     q =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  q=(q.*scale + add);  
  
varid  =netcdf.inqVarID(ncid,'u');     u =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  u=u.*scale + add;  
varid  =netcdf.inqVarID(ncid,'v');     v =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  v=v.*scale + add;  
  
varid  =netcdf.inqVarID(ncid,'d');    div =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  div=(div.*scale + add); 
%
%------total precipitable water--------
nz=size(level,1);
dP=(level(2:nz)-level(1:nz-1))*100;  % pa  
dummp=(q(:,:,2:nz)+q(:,:,1:nz-1)).*0.5;
for i=1:nz-1
 tpw(:,:,i)=dP(i)*dummp(:,:,i);
end
TPW=sum(tpw,3)./g;
%lev=300; nlev=find(level==lev);   TPW=sum(tpw(:,:,nlev:end),3)./g;      

%--------Q vapor flux---------
qfluxu=u.*q;  % Kg/kg * m/s
qfluxv=v.*q;
%---
mqfu=mean(qfluxu(:,:,qflev),3);        % !!! 1000, 975, 950, 925, 900, 875, 850
mqfv=mean(qfluxv(:,:,qflev),3);        % !!! set the levels by <qflev>
%mqfspd=( mqfu.^2 + mqfv.^2 ).^0.5;

%--------------
%spd=( u.^2 + v.^2 ).^0.5;
%-------moisture divergence-----
qdiv=div.*q;  %s^-1*Kg/Kg
qdiv=qdiv.*10^7;
mqdiv=mean(qdiv(:,:,qflev),3);
%mqdiv=qdiv(:,:,31);

%----------------
[yj xi]=meshgrid(y,x);

%---plot setting---;
xplot=xi(1:int:end,1:int:end);        yplot=yj(1:int:end,1:int:end);
uplot=mqfu(1:int:end,1:int:end);      vplot=mqfv(1:int:end,1:int:end);
%
%L=[15 20 25 30 35 40 45 50 55 60 65 70];
%L=[42 45 48 51 54 57 60 63 66 69 72 75];
% L=[40 45 50 55 60 65 70 75];
plotvar=TPW;
pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
%----
figure('position',[1000 650 650 500])
m_proj('miller','lon',plon,'lat',plat)
%---shade----
[c hp]=m_contourf(xi,yj,plotvar,L2);   set(hp,'linestyle','none');
hold on
%---contour: water vapor divergence---
%[c2 hc]=m_contour(xi,yj,mqdiv,[-2 -2],'LineStyle','--','color',[0.05 0.1 0.02],'LineWidth',1);
 [c2 hc]=m_contour(xi,yj,-mqdiv,[2 2],'LevelStep',1,'color',[0.9 0.9 0.9],'LineWidth',1);
%m_text(90.5,39,'white line: qv conv.=2*10^-^7 Kg/Kg*S^-^1','color',[0.9 0.9 0.9],'fontsize',10)
%[c2 hc]=m_contour(xi,yj,spd(:,:,nlev),[12 16],'LineStyle','-','color',[0.9 0.9 0.9],'LineWidth',1);
% [c2 hc]=m_contour(xi,yj,mqfspd,[0.2 0.2],'LineStyle','-','color',[0.9 0.9 0.9],'LineWidth',1.8);
% clabel(c2,hc,'fontsize',9,'color',[0.9 0.9 0.9]);
%---
%m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',80:10:140,'ytick',10:10:45); 
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
m_coast('color',[0.15 0.15 0.2],'LineWidth',1);
%---wind vector----
h1 = m_quiver(xplot,yplot,uplot,vplot,0,'k') ; % the '0' turns off auto-scaling
hU = get(h1,'UData');   hV = get(h1,'VData') ;
set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',0.8); 
%-wind legend--
wlgndc=[0.9 0.1 0.1];
h1 = m_quiver(plon(2)-diff(plon)*0.11,plat(1)+diff(plat)*0.09,wtxt,0,0,'color',wlgndc) ; % the '0' turns off auto-scaling
hU = get(h1,'UData');   hV = get(h1,'VData') ;
set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.5,'MaxHeadSize',300); 
set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on') 
m_text(plon(2)-diff(plon)*0.105,plat(1)+diff(plat)*0.06,num2str(wtxt),'color',wlgndc,'fontsize',11)
m_text(plon(2)-diff(plon)*0.17,plat(1)+diff(plat)*0.025,'(Kg/Kg*m/s)','color',wlgndc,'fontsize',9)
%-------------
cm=colormap(cmap);    caxis([L2(1) L(length(L))])    
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
title(hc,'TPW(Kg/m^2)','fontsize',12);
%---------
tit=['20',date,' ',time,'z EC TPW'];
title(tit,'fontsize',15)
outfile=[outdir,'/',filenam,'_',date,time];
% print('-dpng',outfile,'-r400')   
set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
system(['rm ',[outfile,'.pdf']]);

