%function [std std1 rmse scc]=accum_taylor_sing(sth,acch,expri,araid)
% sth: start time
% acch: accumulation time
% expri: experiment name
% tresh: tresh for ETS and bias

clear; 
sth=2; acch=6;  araid=0;  exp={'e01';'e02';'e04';'e07'};  exptext='_vr12';
nexp=size(exp,1);
%---set
dom='02'; year='2008'; mon='06'; date=16;  s_datexp='16';    % time setting
indir='/SAS009/pwin/expri_largens/';
outdir='/SAS011/pwin/201work/plot_cal/largens/';   
%---
if araid==1;      xmi=120.8;   xma=121.35;  ymi=23.95;  yma=24.45; 
elseif araid==2;  xmi=120.5;   xma=121.05;  ymi=22.95;  yma=23.6; 
elseif araid==3;  xmi=120.5;   xma=121.05;  ymi=22.3;   yma=22.94;
    
elseif araid==4;  xmi=120;     xma=121;     ymi=22;     yma=23.5; 
elseif araid==5;  xmi=120;     xma=120.7;   ymi=22.4;   yma=23.4; 
elseif araid==6;  xmi=121.15;  xma=121.55;  ymi=24.7;   yma=25; 
end

%---
ti=sth;  
ai=acch;
s_sth=num2str(sth,'%2.2d'); s_edh=num2str(sth+acch,'%2.2d'); 
for i=1:nexp  
%===wrf---set filename---
  for j=1:2;
    hr=(j-1)*ai+ti;
    hrday=fix(hr/24);  hr=hr-24*hrday;    
    s_date=num2str(date+hrday,'%2.2d');     s_hr=num2str(hr,'%2.2d');   %%%    
    infile=[indir,exp{i},'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
%---read netcdf data--------
    ncid = netcdf.open(infile,'NC_NOWRITE');
    varid  =netcdf.inqVarID(ncid,'RAINC');    rc{j}  =double(netcdf.getVar(ncid,varid));
    varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc{j} =double(netcdf.getVar(ncid,varid));   
    if j==1;
     varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
     varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
     varid  =netcdf.inqVarID(ncid,'LANDMASK'); land =double(netcdf.getVar(ncid,varid));
    end
    netcdf.close(ncid);
  end  %j=1:2
  % make lakes on the land land 
  land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
  land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;   land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
  %
  rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});    
  rain(land==0 | x<120)=NaN;  rain(rain<0)=0;      
  wrfacci=rain;   
  if i==1
   %---obs--------
   for j=1:ai        
    hr1=ti+j-1;    hrday=fix(hr1/24);  
    hr1=hr1-24*hrday;    r_hr1=num2str(hr1,'%2.2d');      
    hr2=mod(ti+j,24);    r_hr2=num2str(hr2,'%2.2d');      
    r_date=num2str(date+hrday,'%2.2d');
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
  end
  %-----score-------------   
  if araid~=0;  fin=find(isnan(obsacci) ==0 & isnan(wrfacci)==0 & x>xmi & x<xma & y>ymi & y<yma);
  else          fin=find(isnan(obsacci) ==0 & isnan(wrfacci)==0);    end
  [scc(i+1) ~, ~ ,~]=score(obsacci(fin),wrfacci(fin),30);      
  rmse(i+1)=RMSD(obsacci(fin),wrfacci(fin));
  std(i+1)=STNDE(wrfacci(fin));  
end
std(1)=STNDE(obsacci(fin));
scc(1)=1;  rmse(1)=0;

figure('position',[500 500 600 500])
[hp ht axl] = taylordiag(std,rmse,scc);

tit=[s_sth,'z-',s_edh,'z  scores (area ',num2str(araid),')'];  title(tit,'fontsize',15)
outfile=[outdir,'TaylorDiag_',s_sth,s_edh,exptext,'_area',num2str(araid)];
%set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%system(['rm ',[outfile,'.pdf']]);    

