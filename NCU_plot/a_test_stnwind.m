
clear;  


hr=17:23;  s_date='10';  


%---experi. setting-------
year='2012'; mon='06';  s_datexp='10';   % time setting
%-------------------------
%
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');    
load '/work/pwin/data/colormap_rain.mat'; 
cmap=colormap_rain;  clen=length(cmap); %cmap(1,:)=[0.9 0.9 0.9];

cmap=[ 0.3 0.8 0.85 ; 0.3 0.9 0.3; 0.9 0.6 0.2 ; 0.9 0.3 0.3];
L=[1 3 5];

%---setting---
expri='obs';   vari='wind';  filenam='obs_wind_';
outdir='/work/pwin/plot_cal/';

%---
for ti=hr
  if ti<10; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end 

%---read and add data---
  infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/',year,mon,s_date,s_hr,'_wind.dat']; 
  A=importdata(infile);  
  wspd=A(:,3);  wdir=(A(:,4)).*pi./180;  lon=A(:,1);  lat=A(:,2);
  fin=find(wdir>0 & wspd>0);
  wspd=wspd(fin);  wdir=wdir(fin);  lon=lon(fin);  lat=lat(fin);
  
  nstn=length(lon);
  u=-wspd.*sin(wdir);
  v=-wspd.*cos(wdir);
  
  lon(:,2)=lon-0.1.*sin(wdir);
  lat(:,2)=lat-0.1.*cos(wdir);

  lon(:,3)=lon(:,2)-0.05.*cos(pi/4+wdir);
  lat(:,3)=lat(:,2)+0.05.*sin(pi/4+wdir);

  lon(:,4)=lon(:,2)+0.05.*sin(pi/4+wdir);
  lat(:,4)=lat(:,2)+0.05.*cos(pi/4+wdir);
  
%---plot---
  qscale=0.05;
  figure('position',[500 500 600 500])
  m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
  for i=1:nstn
      
    for k=1:length(L)-1
      if (wspd(i)>=L(k) && wspd(i)<L(k+1))
         c=cmap(k+1,:);
         m_line(lon(i,1:2),lat(i,1:2),'color',c,'LineWidth',2)       
         m_line(lon(i,2:2:4),lat(i,2:2:4),'color',c,'LineWidth',1.5)  
         m_line(lon(i,2:3),lat(i,2:3),'color',c,'LineWidth',1.5)  
      end
    end

    if wspd(i)>L(length(L))
         c=cmap(length(L)+1,:);
         m_line(lon(i,1:2),lat(i,1:2),'color',c,'LineWidth',2)       
         m_line(lon(i,2:2:4),lat(i,2:2:4),'color',c,'LineWidth',1.5)  
         m_line(lon(i,2:3),lat(i,2:3),'color',c,'LineWidth',1.5)   
    end     
    if wspd(i)<L(1)
         c=cmap(1,:);
         m_line(lon(i,1:2),lat(i,1:2),'color',c,'LineWidth',2)       
         m_line(lon(i,2:2:4),lat(i,2:2:4),'color',c,'LineWidth',1.5)  
         m_line(lon(i,2:3),lat(i,2:3),'color',c,'LineWidth',1.5)   
    end 

  end
  caxis([L(1) L(length(L))])
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis);
  colormap(cmap);  
  colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);  

   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
   m_gshhs_h('color','k','LineWidth',0.8);
   %m_coast('color','k');
   tit=[expri,'  ',vari,'  ',mon,s_date,' ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,mon,s_date,s_hr];
   %
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]);  
end

