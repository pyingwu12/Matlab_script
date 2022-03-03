%-------------------------------------------------------
% plot the improvement on accumulation rainfall of expri1 to expri2
%-------------------------------------------------------

clear
sth=12; acch=6; expri1='vrzh364L';  expri2='vrzh364'; 
%---experimental setting---
dom='01'; year='2012'; mon='06'; date=10;  s_datexp='10';  % time setting
indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
outdir=['/SAS011/pwin/201work/plot_cal/what/',expri1]; % path of the figure output
L=[-30 -20 -15 -10 -5  -3 -1  1 3 5 10 15 20 30];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3;
%cmap=colormap_br([2 3 4 5 6 8 9 11 12 13 14 15 17],:);    
%------
varinam='rainfall impr.';  filenam=[expri1,'_accum-impr_'];
plon=[119 123];  plat=[21.65 25.65];
%---
for ti=sth;
  s_sth=num2str(ti,'%2.2d');  
  for ai=acch;      
    edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d');     
%===wrf---set filename---
    for j=1:2;
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;    
      s_date=num2str(date+hrday,'%2.2d'); s_hr=num2str(hr,'%2.2d');     %%%    
      infile1=[indir,expri1,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
      infile2=[indir,expri2,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
%------read netcdf data--------
      varid  =netcdf.inqVarID(ncid,'LANDMASK'); land =double(netcdf.getVar(ncid,varid));      
      varid  =netcdf.inqVarID(ncid,'RAINC');    rc1{j}  =double(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc1{j} =double(netcdf.getVar(ncid,varid));
        netcdf.close(ncid);
      ncid = netcdf.open(infile2,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'RAINC');    rc2{j}  =double(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc2{j} =double(netcdf.getVar(ncid,varid));
        netcdf.close(ncid);
    end
    ncid = netcdf.open(infile1,'NC_NOWRITE');
    varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
    varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
    netcdf.close(ncid);
    %--- 
    % make lakes on the land land 
    land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
    land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;  land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
    rain1=double(rc1{2}-rc1{1}+rnc1{2}-rnc1{1});  rain1(land==0 | x<120)=NaN;  rain1(rain1<0)=0;    
    rain2=double(rc2{2}-rc2{1}+rnc2{2}-rnc2{1});  rain2(land==0 | x<120)=NaN;  rain2(rain2<0)=0;        
%-----obs--------
    for j=1:ai        
      hr1=ti+j-1;    hrday=fix(hr1/24);  
      hr1=hr1-24*hrday;    r_hr1=num2str(hr1,'%2.2d');      
      hr2=mod(ti+j,24);    r_hr2=num2str(hr2,'%2.2d');      
      r_date=num2str(date+hrday,'%2.2d');
      infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/', ...
                            year,mon,r_date,'_',r_hr1,r_hr2,'_raingauge.dat']; 
      A=importdata(infile);  obsrain(:,j)=A(:,3);
      obsrain(obsrain(:,j)<0,j)=NaN;  %tick -999
    end        
    acc=sum(obsrain,2);   lon=A(:,1);  lat=A(:,2);
    lon=lon(isnan(acc)==0); lat=lat(isnan(acc)==0); acc=acc(isnan(acc)==0);
    %---interpolate and land---   
    raino=griddata(lon,lat,acc,x,y,'cubic');
    raino(land==0 | x<120)=NaN;  raino(raino<0)=0;
%------------------    
    impr=abs(rain1-raino)-abs(rain2-raino);    
%--plot----
    plotvar=impr;   plotvar(plotvar==0)=NaN;
    pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
    figure('position',[500 500 600 500]) 
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
    cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
    %m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.8);    
    %
    tit=[expri1,'  ',varinam,' to ',expri2,'  ',s_sth,'z -',s_edh,'z'];
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,s_sth,s_edh];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);    end
end
