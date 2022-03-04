function vr_obs(hm,sw,zmind)

% hm: time, string. ex:'15:00'
% sw: elevation angel (/0.5, 1.4, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/)
% zmind: if zmind~=0, figure will zoom in to lon=[119.1 121.4]; lat=[22% 24.3];

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/'); 
load '/work/pwin/data/colormap_vr.mat';   
%---setting---
%hm=['18:00';'20:00']; sw=1.4; zmind=1;
expri='obs';   vari='Vr';   filenam='dot_newobs_vr_';   
num=size(hm,1);
outdir='/work/pwin/plot_cal/IOP8/';
%---
cmap=colormap_vr;
L=[-28 -24 -20 -16 -12 -8 -4 0  4 8 12 16 20 24 28 ];
 if zmind~=0;   filenam=['zm_',filenam];  end
%---
for ti=1:num;
  time=hm(ti,:);
  infile=['/SAS004/pwin/data/obs_OSSE/obs_d03_2008-06-16_',time,':00'];
  A=importdata(infile);
  lon=A(:,5); lat=A(:,6);
  vr =A(:,8); sweep=A(:,2);
  fin=find(vr~=-9999);
  lon=lon(fin); lat=lat(fin);  vr=vr(fin);  
%----choose elevation angle----
  for swi=sw
    lon_sw=lon(sweep==swi);    lat_sw=lat(sweep==swi);
    vr_sw=vr(sweep==swi);
%---plot---
    plot_radar(vr_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
    tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(swi),'.png'];
    saveas(gca,outfile,'png');
  end
%}
end

