%--------------
%  Plot Zh obs
%--------------
clear

hm='01:00';   sw=0.5;   zmind=0;

% hm: time, string. ex:'15:00'
% sw: elevation angel (/0.5, 1.4, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/)
% zmind: if zmind~=0, figure will zoom in to lon=[119.1 121.4]; lat=[22 24.3];

%---experimental setting---
year='2008'; mon='06'; date='16';    % time setting
obsdir='/SAS004/pwin/data/obs_sz6414_QC';
%L=[2 6 10 14 18 21 24 27 30 33 35 37 39 41 43 45];
L=[2 2 6 10 14 18 22 25 30 34 38 42 46 50 55 60];
%L=[0 5 10 15 20 25 30 35 40 45 50 55 60 65];
%L=10/3:10/3:50-10/3;
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_zh.mat';  cmap=colormap_zh; cmap(1,:)=[0.75 0.75 0.75];
%---
expri='obs';   varinam='zh';  filenam='obs_zh_';
outdir='/SAS011/pwin/201work/plot_cal/Zh/obs/';
if zmind~=0;  filenam=['zm_',filenam];  end
num=size(hm,1);

%---
for ti=1:num;
  time=hm(ti,:);
  infile=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile); 
  lon=A(:,5); lat=A(:,6);  ela=A(:,2);  zh=A(:,9); 
  fin=find(zh~=-9999);
  lon=lon(fin); lat=lat(fin);  ela=ela(fin);  zh=zh(fin);    
  %---
  plotvar=zh;
  for swi=sw  
    %swi2=fix(swi);
    fin=find(ela>swi2 & ela<swi2+1);
    plotvar_sw=plotvar(fin); lon_sw=lon(fin); lat_sw=lat(fin);
    %plotvar_sw=plotvar; lon_sw=lon; lat_sw=lat;
%---plot---
    plot_radar(plotvar_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
    tit=[expri,'  ',varinam,'  ',mon,date,' ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,filenam,mon,date,'_',time(1:2),time(4:5),'_',num2str(swi)];
%     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%     system(['rm ',[outfile,'.pdf']]);  
  end
%}
end
