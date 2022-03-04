addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')

clear

%date='120610';  time='00';   
date='080616';  time='00';  
qscale=0.1; zint=40;  wtxt=15;   lev=850; %wind level
qflev=31:37;

%----
outdir='/SAS011/pwin/201work/plot_cal/plot_ECMWF_ana';

%load '/work/pwin/data/colormap_qr2.mat';   %cmap=colormap_qr2([1 3 8 9 10 13 14 15],:);
  
load '/work/pwin/data/colormap_grads.mat';  cmap=colormap_grads;

%----  
filenam='ECana_tpw';  
%plon=[80 145];  plat=[0 50];  
plon=[90 135];  plat=[5 40];   
g=9.81;
int=3;
%%
%qmean=zeros(1440,721,37); umean=zeros(1440,721,37); vmean=zeros(1440,721,37); dmean=zeros(1440,721,37);
%tim={'06';'12';'18';'00'};
%for ti=1:4
infile=['/SAS010/pwin/EC_plot/EC_',date,time,'.nc'];
%-----------
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'longitude');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
varid  =netcdf.inqVarID(ncid,'latitude');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
varid  =netcdf.inqVarID(ncid,'level');     level =double(netcdf.getVar(ncid,varid)); 

varid  =netcdf.inqVarID(ncid,'q');     q =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  q=(q.*scale + add);    %qmean=qmean+q./4;
  
varid  =netcdf.inqVarID(ncid,'u');     u =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  u=u.*scale + add;   %umean=umean+u./4;
varid  =netcdf.inqVarID(ncid,'v');     v =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  v=v.*scale + add;   %vmean=vmean+v./4;
  
varid  =netcdf.inqVarID(ncid,'d');    div =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
  div=(div.*scale + add);  %dmean=dmean+div./4;
  
  
varid  =netcdf.inqVarID(ncid,'t');     t =double(netcdf.getVar(ncid,varid));
scale = netcdf.getAtt(ncid,varid,'scale_factor');  add = netcdf.getAtt(ncid,varid,'add_offset');
t=(t.*scale + add);  %**K

%end
 nlev=find(level==lev);

%%  

 cp=1005;  % J/(K*kg)
 Lat=2430; % J/g
 Lc=2.5e6; % J/Kg
 R=287.43;
 eps=0.622; % esp=Rd/Rv=Mv/Md

 ev=q(:,:,nlev)./eps.*level(nlev);   %partial pressure of water vapor
 theta = t .* (1000/lev)^(R/cp);     %potential temprature
 Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor
 A=1.26e-3;  % K^-1
 B=5.14e-4;  % K^-1
 Tlcl=(1-A.*Td)./(1./Td+B.*log(t(:,:,nlev)./Td)-A);    
 the=theta(:,:,nlev).*exp(Lc.*q(:,:,nlev)./(cp.*Tlcl));
 the=the-273;

%------precipitable water--------
nz=size(level,1);
dP=(level(2:nz)-level(1:nz-1))*100;  % pa  
dummp=(q(:,:,2:nz)+q(:,:,1:nz-1)).*0.5;
for i=1:nz-1
 tpw(:,:,i)=dP(i)*dummp(:,:,i);
end
TPW=sum(tpw,3)./g;
%lev=300; 
%nlev=find(level==lev);   %TPW=sum(tpw(:,:,nlev:end),3)./g;      

%----Q vapor flux----
qfluxu=u.*q;  % Kg/kg * m/s
qfluxv=v.*q;
%---
mqfu=mean(qfluxu(:,:,qflev),3);        %% !!! 1000, 975, 950, 925, 900, 875, 850
mqfv=mean(qfluxv(:,:,qflev),3);
%mqfspd=( mqfu.^2 + mqfv.^2 ).^0.5;

%--------------
%spd=( u.^2 + v.^2 ).^0.5;
%----------
qdiv=div.*q;  %s^-1*Kg/Kg
qdiv=qdiv.*10^7;
mqdiv=mean(qdiv(:,:,qflev),3);
%mqdiv=qdiv(:,:,31);

%----------------
[yj xi]=meshgrid(y,x);

mqx=xi(1:3:end,1:3:end);  mqy=yj(1:3:end,1:3:end);

%---plot setting---;
xplot=xi(1:int:end,1:int:end);        yplot=yj(1:int:end,1:int:end);
uplot=u(1:int:end,1:int:end,nlev);      vplot=v(1:int:end,1:int:end,nlev);
%----
%%
L=[15 20 25 30 35 40 45 50 55 60 65 70];
plotvar=TPW;
pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
%---shade
figure('position',[100 500 650 500])
m_proj('miller','lon',plon,'lat',plat)
[c hp]=m_contourf(xi,yj,plotvar,L2);   set(hp,'linestyle','none');
hold on
%---water vapor divergence---
%[c2 hc]=m_contour(xi,yj,mqdiv,[-2 -2],'LineStyle','--','color',[0.05 0.1 0.02],'LineWidth',1);
 %m_contour(xi,yj,-mqdiv,[2 2],'LevelStep',1,'color',[0.1 0.1 0.9],'LineWidth',1,'LineStyle','--');
 %m_text(90.5,39,'white line: qv conv.=2*10^-^7 Kg/Kg*S^-^1','color',[0.9 0.9 0.9],'fontsize',10)
%[c2 hc]=m_contour(xi,yj,spd(:,:,nlev),[12 16],'LineStyle','-','color',[0.9 0.9 0.9],'LineWidth',1);
% [c2 hc]=m_contour(xi,yj,mqfspd,[0.2 0.2],'LineStyle','-','color',[0.9 0.9 0.9],'LineWidth',1.8);
% clabel(c2,hc,'fontsize',9,'color',[0.9 0.9 0.9]);
[c2 hc]=m_contour(xi,yj,the,[70 70],'LevelStep',1,'color',[0.9 0.9 0.9],'LineWidth',1.1);
clabel(c2,hc,'fontsize',10,'color',[0.9 0.9 0.9],'LabelSpacing',250);
%---
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',80:10:140,'ytick',10:10:45); 
m_coast('color',[0.15 0.15 0.2],'LineWidth',1);
%---wind vector----
% h1 = m_quiver(xplot,yplot,uplot,vplot,0,'k') ; % the '0' turns off auto-scaling
% hU = get(h1,'UData');   hV = get(h1,'VData') ;
% set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',0.8); 
% %-wind legend--
% h1 = m_quiver(130.4,8.1,wtxt,0,0,'color',[0.2 0.1 0.1]) ; % the '0' turns off auto-scaling
% hU = get(h1,'UData');   hV = get(h1,'VData') ;
% set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2,'MaxHeadSize',270); 
% set(h1,'ShowArrowHead','off');  set(h1,'ShowArrowHead','on') 
% m_text(130.3,7.15,num2str(wtxt),'color',[0.2 0.1 0.1],'fontsize',11)
% m_text(130,6,'(m/s)','color',[0.2 0.1 0.1],'fontsize',9)

windmax=20;
windbarbM_mapVer(xplot,yplot,uplot,vplot,13,windmax,[0.2 0.1 0.1],0.7)
windbarbM_mapVer(131.5,6,windmax,0,20,windmax,[0.9 0.1 0.1],1)
m_text(131.7,6.1,num2str(windmax),'color',[0.9 0.1 0.1],'fontsize',12)


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
