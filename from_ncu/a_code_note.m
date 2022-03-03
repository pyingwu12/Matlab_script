


lat1 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT1')); 
lat2 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT2'));
cen_lon =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LON'));

m_proj('Lambert','lon',plon,'lat',plat,'clongitude',cen_lon,'parallels',[lat1 lat2],'rectbox','on')

[c2 hc]=m_contour(xi,yj,zg,'LevelStep',zint,'color',[0.05 0.11 0.02],'LineWidth',0.8);
clabel(c2,hc,650:20:800,'fontsize',9,'color',[0.1 0.11 0.1],'LabelSpacing',150);


dx =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX')); 
dy =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY'));

varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);

m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);

title(hc,'km')

plon=[118.3 121.8];   plat=[21 24.3];       % only southwest area

plon=[119 123];       plat=[21.65 25.65];   % accum w/o sea
plon=[119.8 122.2];   plat=[21.65 25.55];   % accum narrow

plon=[118.3 122.85];  plat=[21.2 25.8];     % accum w/ sea (Taiwan + southwesa area)
plon=[118.5 122.5];   plat=[21.65 25.65];   % Taiwan + smaller southwesa area

plon=[117.5 122.5]; plat=[20.5 25.65];      % correlation, Taiwan + larger southwesa area

plon=[115 128];  plat=[18 28];              % d01

title(tit,'fontsize',15,'Interpreter','none','FontWeight','bold')


   windmax=15;  scale=15;
   windbarbM_mapVer(xi,yi,u.plot,v.plot,scale,windmax,[0.05 0.02 0.5],0.8)
   windbarbM_mapVer(plon(1)+0.2,plat(2)-0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
   
   h1 = m_quiver(xi,yi,u.plot,v.plot,0,'k') ; % the '0' turns off auto-scaling
   hU = get(h1,'UData');   hV = get(h1,'VData') ;
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2);   
