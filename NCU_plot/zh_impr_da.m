%-----------------------------------
% Plot Zh improvement after DA
%-----------------------------------

clear
hm='00:00';  expri='e02';  sw=[0.5 1.4];  zmind=0;


%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%obsdir='/SAS004/pwin/data/obs_IOP8';
obsdir='/SAS004/pwin/data/obs_sz6414';
%indir=['/work/pwin/data/IOP8_wrf2obs_',expri];  outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri,'/'];
%indir=['/work/pwin/data/sz_wrf2obs_',expri];  outdir=['/SAS011/pwin/201work/plot_cal/IOP8/',expri,'/'];
indir=['/work/pwin/data/largens_wrf2obs_',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri,'/'];
L=[-10 -8 -6 -4 -3 -2 -1  1 2 3 4 6 8 10];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');  
load '/work/pwin/data/colormap_br3.mat';    cmap=colormap_br3;  cmap(8,:)=[0.95 0.95 0.95];
%---
varinam='Zh impr';    filenam=[expri,'_zh-imprda_'];  

num=size(hm,1);
if zmind~=0;  filenam=['zm_',filenam];  end

%---
for ti=1:num;
  time=hm(ti,:);
%---obs
  infile=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile);
  lon=A(:,5); lat=A(:,6); ela=A(:,2);   
  zho =A(:,9);  
%---fcst 
  infile=[indir,'/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  B=importdata(infile); 
  zhf =B(:,9); 
%---anal
  infile=[indir,'/analmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  C=importdata(infile); 
  zha =C(:,9);  
%---calculate---    
  impr=abs(zho-zha)-abs(zho-zhf);
%---
  fin=find(zho~=9999 & zhf~=-9999 & zha~=9999);
  lon=lon(fin); lat=lat(fin); ela=ela(fin);  impr=impr(fin);      
  plotvar=impr;
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
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  
  end
%}
end
