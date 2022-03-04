function zh_damean(hm,sw,expri,type,zmind)

% hm: time, string. ex:'15:00'
% sw: elevation angel (/0.5, 1.4, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/)
% expri: experiment name, string. ex:'orig'
% type : 'anal' or 'fcst'
% zmind: if zmind~=0, figure will zoom in to lon=[119.1 121.4]; lat=[22 24.3];
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/'); 
load '/work/pwin/data/colormap_zh.mat';  
%---setting---
vari='Zh';    filenam=[expri,'_zh_'];   type0=[type,' mean']; 
num=size(hm,1);
indir=['/work/pwin/data/morakot_wrf2obs_',expri];
outdir=['/work/pwin/plot_cal/Zh/',expri,'/'];
%---
cmap=colormap_zh;
L=[2 6 10 14 18 21 24 27 30 33 35 37 39 41 43 45];
if zmind~=0;   filenam=['zm_',filenam];  end
%---
for ti=1:num;
  time=hm(ti,:);
  infile=[indir,'/',type,'mean_d03_2009-08-08_',time,':00'];
  A=importdata(infile);
  lon=A(:,5); lat=A(:,6);
  zh =A(:,9); sweep=A(:,2);
  fin=find(zh~=-9999);
  lon=lon(fin); lat=lat(fin);  zh=zh(fin); 
%----choose elevation angle----
  for swi=sw
    lon_sw=lon(sweep==swi);  lat_sw=lat(sweep==swi);
    zh_sw=zh(sweep==swi);
%---plot---
    plot_radar(zh_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
    tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  ',type0,'  (',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,filenam,time(1:2),time(4:5),'_',type,'_',num2str(swi),'.png'];
    print('-dpng',outfile,'-r350')
  end
%}
end
end