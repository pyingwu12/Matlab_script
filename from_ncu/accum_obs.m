%function accum_obs(sth,acch,textid,ctnid,dotid)
% sth: start time
% acch: accumulation time
% texid: Mark max value when texid~=0
% ctnid: same colorbar maximum=ctnid when ctnid~=0
% dotid: 0-inperlation, 1-obs station dot with color

clear;  sth=2;  acch=7;  textid=0;  ctnid=1; dotid=0; 
araid=0;
%---experi. setting-------
year='2008'; mon='06'; date=16;   s_datexp='16';   % time setting
%infile='/SAS011/pwin/what_plot/CTR/wrfout_d01_2012-06-10_12:00:00'; 
%infile='/SAS005/pwin/expri_shao/EC/wrfout_d02_2008-06-14_12:00:00';
%infile='/SAS002/pwin/expri_241/morakot_sing_vr124/wrfout_d03_2009-08-08_18:00:00';
%infile='/SAS007/pwin/expri_sz6414/szvrzh124/wrfout_d03_2008-06-16_02:00:00';
infile='/SAS007/pwin/expri_largens/WRF_shao/wrfout_d02_2008-06-15_18:00:00';
%-------------------------
%
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');    
load '/work/pwin/data/colormap_rain.mat'; 
cmap=colormap_rain;  clen=length(cmap); %cmap(1,:)=[0.9 0.9 0.9];
%load '/work/pwin/data/heighti.mat';  [xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
seaid=2; %not a option
%---setting---
expri='obs';   varinam='accumulation rainfall';  filenam='obs_accum_';
outdir='/SAS011/pwin/201work/plot_cal/Rain/obs/';
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=['ctn',num2str(ctnid),'_',filenam]; end
if dotid==1;  filenam=['dot_',filenam]; end
if araid~=0;  filenam=['area',num2str(araid),'_',filenam]; end
%---read model land data---
ncid = netcdf.open(infile,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'XLONG');     lon =netcdf.getVar(ncid,varid);   x=double(lon);
varid  =netcdf.inqVarID(ncid,'XLAT');      lat =netcdf.getVar(ncid,varid);   y=double(lat);
varid  =netcdf.inqVarID(ncid,'LANDMASK');  land=double(netcdf.getVar(ncid,varid)); 
land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;   land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
% ^^^ make lakes on the land land ^^^
%---
if araid==1;      xmi=120.8;   xma=121.35;  ymi=23.95;  yma=24.45;   % what 1 
elseif araid==2;  xmi=120.5;   xma=121.05;  ymi=22.95;  yma=23.6;    % what 2
elseif araid==3;  xmi=120.5;   xma=121.05;  ymi=22.3;   yma=22.94;   % what 3
    
elseif araid==4;  xmi=120;     xma=121;     ymi=22;     yma=23.5;    % SW py
elseif araid==5;  xmi=120;     xma=120.7;   ymi=22.4;   yma=23.4;    % SW sz
elseif araid==6;  xmi=121.15;  xma=121.55;  ymi=24.7;   yma=25;      % north
end

%---
for ti=sth
  s_sth=num2str(ti,'%2.2d');    s_date=num2str(date,'%2.2d');
  for ai=acch       % accumulation time
%---set clim and end time---    
    edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d'); 
%---read and add data---
    for j=1:ai
      hr1=ti+j-1;    hrday=fix(hr1/24);  
      hr1=hr1-24*hrday;    r_hr1=num2str(hr1,'%2.2d');      
      hr2=mod(ti+j,24);    r_hr2=num2str(hr2,'%2.2d');      
      r_date=num2str(date+hrday,'%2.2d');
      %
      infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/', ...
                            year,mon,r_date,'_',r_hr1,r_hr2,'_raingauge.dat']; 
      A=importdata(infile);  rain(:,j)=A(:,3);
      rain(rain(:,j)<0,j)=NaN;  %tick -999
    end        
    acc=sum(rain,2);   lon=A(:,1);  lat=A(:,2);   
%---------    
    switch(dotid)
    case(0)
      lon=lon(isnan(acc)==0); lat=lat(isnan(acc)==0); acc=acc(isnan(acc)==0); 
      %---interpolate and land---   
      acci=griddata(lon,lat,acc,x,y,'cubic');
      acci(land==0 | x<120)=NaN;   acci(acci<0)=0;
      %acci=griddata(lon,lat,acc,xi,yj,'cubic');
      %acci(isnan(heighti)==1 | heighti<=0 )=NaN;  acci(acci<0)=0;    
      obsrain=acci;
      save(['/SAS004/pwin/plot_SC/obsrain_20120610',s_sth,'_',num2str(acch),'hr.mat'],'obsrain')
%---plot---
      acci(acci==0)=NaN;
      plot_accum(acci,x,y,ai,cmap,ctnid,textid,seaid)   
      if araid~=0;
       m_line([xmi xma xma xmi xmi],[ymi ymi yma yma ymi],'color',[0 0 0],'LineWidth',1.8,'LineStyle','--')        
       %m_line([120 120.7 120.7 120 120],[22.4 22.4 23.4 23.4 22.4],'color',[0 0 0],'LineWidth',1.8)        
       %m_line([120.5 121.05 121.05 120.5 120.5],[22.95 22.95 23.6 23.6 22.95],'color',[0 0 0],'LineWidth',1.8)        
       %m_line([120.5 121.05 121.05 120.5 120.5],[22.3 22.3 22.94 22.94 22.3],'color',[0 0 0],'LineWidth',1.8)        
      end
    case(1)     
%---set clim---    
      if mod(ai,2)~=0; clim=[0 ai*75+25]; elseif ai>=6; clim=[0 400]; else clim=[0 ai*75]; end    % colorbar      
      if ctnid~=0; clim=[0 ctnid]; end;       L=fix(clim(2)/17*(1:16));
      if clim(2)==250;      L=[  1   5  10  20  30  40  50  60  70  90 110 130 150 180 200 230];
      elseif clim(2)==300;  L=[  5  10  20  30  40  50  60  75  90 110 130 150 180 220 260 300];  
      elseif clim(2)==1;    L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300];
      end
%---find maximum---
       [macc mxI]=max(acc);    mlat=lat(mxI); mlon=lon(mxI);
       cmap(1,:)=[0.9 0.9 0.9];        Msize=6.5;
       plon=[119 123];       plat=[21.65 25.65]; 
       %plon=[118.3 121.8];   plat=[21 24.3]; 
%---plot---
       figure('position',[500 500 600 500])
       m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
      hold on 
       for i=1:length(acc);   
         if isnan(acc(i))==1            
            hp=m_plot(lon(i),lat(i),'x','color',[0.6 0.6 0.6],'MarkerSize',Msize);  set(hp,'linestyle','none');   
         elseif acc(i)==0
            hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor',cmap(1,:),'MarkerFaceColor','none','MarkerSize',Msize);   set(hp,'linestyle','none');    
         elseif acc(i)<L(1) 
            c=cmap(1,:);
            hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize);  set(hp,'linestyle','none');   
         elseif acc(i)>L(clen-1)
            c=cmap(clen,:);
            hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize);  set(hp,'linestyle','none');   
         else
            for k=1:clen-2;
             if (acc(i) > L(k) && acc(i)<=L(k+1))
              c=cmap(k+1,:);
              hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); set(hp,'linestyle','none');    
             end      
            end
         end
       end  %acc(i)
       if textid~=0
        hold on
        m_text(mlon,mlat+0.02,num2str(round(macc)),'color','k','fontsize',14)
        m_plot(mlon,mlat,'*k')
       end  
       cm=colormap(cmap);  caxis([L(1) L(end)])  
       hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);  
       m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45); 
       m_gshhs_h('color','k','LineWidth',0.8);
       %m_coast('color','k');
    end   %case
%    tit=[expri,'  ',varinam,'  ',mon,s_date,' ',s_sth,'UTC -',s_edh,'UTC'];
%    title(tit,'fontsize',15)
      tit='OBS';
      title(tit,'fontsize',17,'Position',[-0.01 0.0285])
    outfile=[outdir,filenam,mon,s_date,s_sth,s_edh];
    %print('-dpng',outfile,'-r400')
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  
  end
end

