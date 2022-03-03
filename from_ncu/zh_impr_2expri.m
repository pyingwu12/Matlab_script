%-------------------------------------------------------
% Plot Zh mean improvement of expri1 compare to expri2
%                          (both DA or forecast time)
%-------------------------------------------------------

clear

hm='00:00';   expri1='largens364';  expri2='largforty364';   sw=0.5;   zmind=0;
%---DA or forecast time---
%infilenam='wrfout';   type='sing';
infilenam='analmean';  type=infilenam(1:4);  %!notice

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
obsdir='/SAS004/pwin/data/obs_sz6414';
indir='/work/pwin/data/largens_wrf2obs_';   outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];
L=[-5 -4 -3 -2 -1.5 -1 -0.5  0.5 1 1.5 2 3 4 5];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3; cmap(8,:)=[0.99 0.99 0.99];
%---
varinam='zh impr.';    filenam=[expri1,'_zh-impr-',expri2,'_'];  
if zmind~=0;  filenam=['zm_',filenam];  end
num=size(hm,1);

%---
for ti=1:num;
  time=hm(ti,:);
  %---set file name
  infile0=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
  %---read expri1
  A=importdata(infile1);
  lon=A(:,5); lat=A(:,6); zh1=A(:,9); ela=A(:,2);
  %---read expri2
  B=importdata(infile2);
  zh2 =B(:,9); 
  %---read obs
  C=importdata(infile0);
  zho =C(:,9); 
  
  %---calculate improvement
  impr=abs(zho-zh1)-abs(zho-zh2);
  %---tick -9999  
  fin=find(zh1~=-9999 & zh1~=-9999 & zh2~=-9999);
  lon=lon(fin); lat=lat(fin);  ela=ela(fin);  impr=impr(fin); 
 
  plotvar=impr;
  %---tick white point---
  plotvar(plotvar>L(7) & plotvar<L(8))=NaN;
%---  
  for swi=sw
    swi2=fix(swi); fin=find(ela>swi2 & ela<swi2+1);
    plotvar_sw=plotvar(fin); lon_sw=lon(fin); lat_sw=lat(fin);
%---plot---
    plot_radar(plotvar_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function   
    tit=[expri1,'  ',varinam,' to ',expri2,'  ',time(1:2),time(4:5),'z (',type,' ',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,time(1:2),time(4:5),'_',type,'_',num2str(swi)];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  
  end
%}
end
