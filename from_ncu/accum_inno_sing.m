%-------------------------------------------------------
% accumulation rainfall innovation(O-B) of expri
%-------------------------------------------------------

clear;   sth=12;  acch=6;  expri='ECall3'; 
%---experimental setting---
dom='02'; year='2008'; mon='06'; date=14;  s_datexp='14';   % time setting
indir=['/SAS005/pwin/expri_shao/',expri];     % path of the experiments
%indir=['/SAS009/pwin/expri_cctmorakot/',expri];
%indir=['/SAS009/pwin/expri_whatsmore/',expri];
outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri];   % path of the figure output
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;
L=[-70 -50 -30 -15 -5 -1  1 5 15 30 50 70];
%------
varinam='rainfall inno.';  filenam=[expri,'_accum-inno_'];
plon=[119 123];  plat=[21.65 25.65];

%---
for ti=sth;
  s_sth=num2str(ti,'%2.2d');   % start time string
  for ai=acch;
  edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d');   % end time string
%===wrf---set filename---
    for j=1:2;
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;    
      s_date=num2str(date+hrday,'%2.2d');  s_hr=num2str(hr,'%2.2d');      
      infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
    %------read netcdf data--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'RAINC');    rc{j}  =netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc{j} =netcdf.getVar(ncid,varid);
    end
    varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
    varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
    varid  =netcdf.inqVarID(ncid,'LANDMASK');  land=double(netcdf.getVar(ncid,varid)); 
    netcdf.close(ncid);
    % make lakes on the land land 
    land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
    land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;  land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
     %-----interpolation and land------
    rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
    rain(land==0 | x<120)=NaN;   rain(rain<0)=0; 
    wrfacci=rain;
%-----obs--------
    for j=1:ai
        
      hr1=ti+j-1;    hrday=fix(hr1/24);  
      hr1=hr1-24*hrday;    r_hr1=num2str(hr1,'%2.2d');      
      hr2=mod(ti+j,24);    r_hr2=num2str(hr2,'%2.2d');      
      r_date=num2str(date+hrday,'%2.2d');
      %
      infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/', ...
                            year,mon,r_date,'_',r_hr1,r_hr2,'_raingauge.dat']; 
      A=importdata(infile);  obsrain(:,j)=A(:,3);
      obsrain(obsrain(:,j)<0,j)=NaN;
    end        
    acc=sum(obsrain,2);   lon=A(:,1);  lat=A(:,2);
    lon=lon(isnan(acc)==0); lat=lat(isnan(acc)==0); acc=acc(isnan(acc)==0);
    %---interpolate and land---   
    obsacci=griddata(lon,lat,acc,x,y,'cubic');
    obsacci(land==0 | x<120)=NaN;  obsacci(obsacci<0)=0;
%------------------    
    inno=obsacci-wrfacci;   
%--plot----
    plotvar=inno;   plotvar(plotvar==0)=NaN;
    pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
    figure('position',[500 500 600 500]) 
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
    %
    cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
    %m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.8);  
    %        
    tit=[expri,'  ',varinam,'  ',s_sth,'z -',s_edh,'z'];
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,s_sth,s_edh];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  
  end  %ai
end  %ti
