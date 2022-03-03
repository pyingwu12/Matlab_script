%---------------------------------
% Plot Zh increment
%----------------------------------
clear
hm='00:00';  expri='e01';  sw=3.4;    zmind=0;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/work/pwin/data/largens_wrf2obs_',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri,'/'];
L=[-11 -9 -7 -5 -3 -1  1 3 5 7 9 11];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');  
load '/work/pwin/data/colormap_br.mat';    cmap=colormap_br;  cmap(7,:)=[0.95 0.95 0.95];
%---
varinam='Zh incr.';    filenam=[expri,'_zh-incr_'];  
num=size(hm,1);
if zmind~=0;  filenam=['zm_',filenam];  end

%---
for ti=1:num;
  time=hm(ti,:);
%---fcst
  infile1=[indir,'/','fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile1); 
  zh1 =A(:,9);     lon=A(:,5); lat=A(:,6); ela=A(:,2);   
%---anal   
  infile2=[indir,'/','analmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  B=importdata(infile2); 
  zh2 =B(:,9); 
%---calculate--- 
  fin=find(zh2~=-9999 & zh1~=9999);
  lon=lon(fin); lat=lat(fin); ela=ela(fin);
  zh1=zh1(fin); zh2=zh2(fin);      
  plotvar=zh2-zh1;
  
%---tick white point
  plotvar(plotvar>L(6) & plotvar<L(7))=NaN;
  
  for swi=sw
    swi2=fix(swi); fin=find(ela>swi2 & ela<swi2+1);
    plotvar_sw=plotvar(fin); lon_sw=lon(fin); lat_sw=lat(fin);
%---plot---
    plot_radar(plotvar_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
    tit=[expri,'  ',varinam,'  ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,time(1:2),time(4:5),'_',num2str(swi)];
%     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%     system(['rm ',[outfile,'.pdf']]);  
  end
%}
end
