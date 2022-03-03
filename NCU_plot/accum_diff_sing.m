%-------------------------------------------------------
% accumulation rainfall difference(exp1-exp2) between expri1 to expri2
%-------------------------------------------------------

clear
sth=2; acch=5; expri1='e38';  expri2='e02'; 
%---experimental setting---
dom='02'; year='2008'; mon='06'; date=16;    % time setting
indir='/SAS009/pwin/expri_largens/';  % path of the experiments
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
L=[-70 -50 -30 -20 -10 -5 5 10 20 30 50 70];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
%load '/work/pwin/data/colormap_br5.mat';  cmap=colormap_br5; 
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3(2:14,:);
%------
varinam='Rainfall';  filenam=[expri1,'-diff-',expri2,'_accum_'];
%plon=[119 123];  plat=[21.65 25.65];
%plon=[118.3 122.85];  plat=[21.2 25.8];     % accum w/ sea
plon=[118.9 121.8];   plat=[21 24.3]; 

%---
for ti=sth
  s_sth=num2str(ti,'%2.2d'); 
  for ai=acch
    edh=mod(ti+ai,24);  s_edh=num2str(edh,'%2.2d');      
%===wrf---set filename---
    for j=1:2
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;    
      if date+hrday<10; s_date=['0',num2str(date+hrday)]; else s_date=num2str(date+hrday); end
      if hr<10;  s_hr=['0',num2str(hr)];  else   s_hr=num2str(hr);  end   %%%    
      infile1=[indir,expri1,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
      infile2=[indir,expri2,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
%------read netcdf data--------
      ncid = netcdf.open(infile1,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
      varid  =netcdf.inqVarID(ncid,'LANDMASK'); land =double(netcdf.getVar(ncid,varid));      
      varid  =netcdf.inqVarID(ncid,'RAINC');    rc1{j}  =double(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc1{j} =double(netcdf.getVar(ncid,varid));
        netcdf.close(ncid);
      ncid = netcdf.open(infile2,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'RAINC');    rc2{j}  =double(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc2{j} =double(netcdf.getVar(ncid,varid));
        netcdf.close(ncid);
    end
    %--- 
    land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
    land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;  land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
    rain1=double(rc1{2}-rc1{1}+rnc1{2}-rnc1{1});  %rain1(land==0 | x<120)=NaN;  rain1(rain1<0)=0;    
    rain2=double(rc2{2}-rc2{1}+rnc2{2}-rnc2{1});  %rain2(land==0 | x<120)=NaN;  rain2(rain2<0)=0;        
%------------------    
    diff=rain1-rain2;    
%--plot----
    plotvar=diff;   plotvar(plotvar==0)=NaN;
    pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
    figure('position',[500 200 600 500]) 
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
    cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
    %m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.8);    
    %
    tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_sth,'z -',s_edh,'z'];
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,s_sth,s_edh];
    %print('-dpng',outfile,'-r400')    
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);  
  end
end
