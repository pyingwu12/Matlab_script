%-------------------------------------------------------
% Plot wind vector of observation (station)
%-------------------------------------------------------

clear

hr=4;     
%
%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16'; s_datexp='16';    % time setting
outdir='/SAS011/pwin/201work/plot_cal/Wind/obs';
%L=[1 3 5 7 9 11 13 15 17 19 21 23 25]; %IOP8
%---set
addpath('/work/pwin/m_map1.4/')
%---
expri='obs'; varinam='wind';  filenam=[expri,'_wind_'];  
plon=[119 121.9];       plat=[21.65 24.5];

%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
   %---read obs data---
   [lon lat wspd wdir]=wind_obs_read(s_hr,year,mon,date,s_datexp);
   lon=lon(wspd>=0);  lat=lat(wspd>=0);  wdir=wdir(wspd>=0);  wspd=wspd(wspd>=0);
   %use wind speed and direction to get u, v wind
   wdir=wdir.*pi./180;
   u=-wspd.*sin(wdir);   v=-wspd.*cos(wdir);   
   %
   %---plot---            
   figure('position',[100 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on') 
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color',[0.3 0.3 0.3],'LineWidth',0.8);
   %
   windmax=5;  scale=20;
   windbarbM_mapVer(lon,lat,u,v,scale,windmax,[0.05 0.02 0.5],0.9)
   windbarbM_mapVer(plon(1)+0.2,plat(2)-0.2,windmax,0,scale,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
   % 
   tit=[expri,'  ',varinam,'  ',s_hr,'z'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr];
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 
    
end  %ti

