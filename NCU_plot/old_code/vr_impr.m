function vr_impr(hm,sw,expri,zmind)

% hm: time, string. ex:'15:00'
% sw: elevation angel (/0.5, 1.4, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/)
% expri: experiment name, string. ex:'MR15'
% zmind: if zmind~=0, figure will zoom in to lon=[119.1 121.4]; lat=[22 24.3];

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/'); 
load '/work/pwin/data/colormap_br.mat';   
%---setting---
vari='Vr improve (vs.ori)';   filenam=[expri,'_vr-imp_'];  
num=size(hm,1);
indir='/work/pwin/data/morakot_wrf2obs_';
outdir=['/work/pwin/plot_cal/Vr/',expri,'/'];
%---
cmap=colormap_br;
L=[-6 -5 -4 -3 -2 -1 -0.5 -0.1   0.1 0.5 1 2 3 4 5 6];
if zmind~=0;   filenam=['zm_',filenam];  end
%---
for ti=1:num;
  time=hm(ti,:);
%===obs===
  infile1=['/SAS004/pwin/obs_new/obs_d03_2009-08-08_',time,':00'];
  A=importdata(infile1);
  lon=A(:,5); lat=A(:,6); ela=A(:,2); 
  vr1 =A(:,8);  
%===wrf1===    
  infile2=[indir,'orig/wrfout_d03_2009-08-08_',time,':00_mean'];
  B=importdata(infile2); 
  vr2 =B(:,8); 
%===wrf2===    
  infile3=[indir,expri,'/wrfout_d03_2009-08-08_',time,':00_mean'];
  C=importdata(infile3); 
  vr3 =C(:,8); 
%===calculate innovation===  
  fin=find(vr3~=-9999 & vr2~=-9999 & vr1~=-9999);
  lon=lon(fin); lat=lat(fin);
  vr1=vr1(fin); vr2=vr2(fin); vr3=vr3(fin); 
%---
  ino_ori=vr1-vr2;
  ino_exp=vr1-vr3;
  imp=abs(ino_exp)-abs(ino_ori);
  
  for swi=sw
    vrimp=imp(ela==swi);
    lon_sw=lon(ela==swi); lat_sw=lat(ela==swi);
%---plot---
    plot_radar(vrimp,lon_sw,lat_sw,cmap,L,zmind)  %%%----plot function
    tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(swi),'.png'];
    print('-dpng',outfile,'-r350')
  end
%}
end
