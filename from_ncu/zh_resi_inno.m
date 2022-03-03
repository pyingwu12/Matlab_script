%-------------------------------------------------------
% Plot Zh 1:residual or 2:innovation(background) 3:innovation(forecasting) 
%-------------------------------------------------------

hm='01:45';  expri='e01';  sw=0.5;   plotid=2;    zmind=2;


%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
obsdir='/SAS004/pwin/data/obs_sz6414_QC';
indir=['/work/pwin/data/largens_wrf2obs_',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri,'/'];
L=[-20 -16 -12 -8 -4 -1  1 4 8 12 16 20];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');  
load '/work/pwin/data/colormap_br.mat';    cmap=colormap_br;  cmap(7,:)=[0.95 0.95 0.95];
%---
switch (plotid); 
 case(1); infilenam='analmean';  varinam='Zh residual';    filenam=[expri,'_zh-resi_'];  
 case(2); infilenam='fcstmean';  varinam='Zh innovation';  filenam=[expri,'_zh-inno_'];  
 case(3); infilenam='wrfout';    varinam='Zh innovation';  filenam=[expri,'_zh-inno_'];  
end
num=size(hm,1);
if zmind~=0;  filenam=['zm_',filenam];  end

%---
for ti=1:num;
  time=hm(ti,:);
%---obs
  infile1=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile1);
  lon=A(:,5); lat=A(:,6); ela=A(:,2);   zh1 =A(:,9);  
%---model   
  infile2=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  B=importdata(infile2); 
  zh2 =B(:,9); 
%---calculate--- 
  fin=find(zh2~=-9999 & zh1~=9999);
  lon=lon(fin); lat=lat(fin); ela=ela(fin);
  zh1=zh1(fin); zh2=zh2(fin);      
  plotvar=zh1-zh2;
  
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
