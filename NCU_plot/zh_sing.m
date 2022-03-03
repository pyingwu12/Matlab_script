%-------------------------------------------------------
% Plot Zh mean or single (DA cycle & forecasting time)
%-------------------------------------------------------

clear

hm='00:00';   expri='largens';   sw=0.5;   zmind=0;
%---DA or forecast time---
infilenam='wrfmean';   type='mean'; 
%infilenam='wrfout';   type='sing'; 
%infilenam='fcstmean';  type=infilenam(1:4); %!notice

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/work/pwin/data/largens_wrf2obs_',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%L=[2 6 10 14 18 21 24 27 30 33 35 37 39 41 43 45];
L=[0 5 10 15 20 25 30 35 40 45 50 55 60 65];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_zh2.mat';  cmap=colormap_zh2; 
%---
varinam='zh';    filenam=[expri,'_zh_'];  
if zmind~=0;  filenam=['zm_',filenam];  end
num=size(hm,1);

%---
for ti=1:num
  time=hm(ti,:);   
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile); 
  lon=A(:,5); lat=A(:,6);  ela=A(:,2);  zh=A(:,9); 
  fin=find(zh~=-9999);
  lon=lon(fin); lat=lat(fin);  ela=ela(fin);  zh=zh(fin);  
  
  plotvar=zh;
  for swi=sw
    swi2=fix(swi); fin=find(ela>swi2 & ela<swi2+1);
    plotvar_sw=plotvar(fin); lon_sw=lon(fin); lat_sw=lat(fin);
%---plot---
    plot_radar(plotvar_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
    tit=[expri,'  ',varinam,'  ',time(1:2),time(4:5),'z  (',type,' ',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,time(1:2),time(4:5),'_',type,'_',num2str(swi)];
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);  
  end
%}
end
