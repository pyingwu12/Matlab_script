%function zh_spread(hm,sw,expri,type,zmind)
clear
hm=['15:00';'16:00';'17:00';]; sw=1.4; expri='DA1517vr'; zmind=1;  type='anal';

% hm: time, string. ex:'15:00'
% sw: elevation angel (/0.5, 1.4, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/)
% expri: experiment name, string. ex:'orig'
% member: ensemble member you want to plot  
% zmind: if zmind~=0, figure will zoom in to lon=[119.1 121.4]; lat=[22
% 24.3];

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rms.mat';  
%---setting---
vari='Zh spread';    filenam=[expri,'_zh-sprd_'];
num=size(hm,1);
indir=['/work/pwin/data/morakot_wrf2obs_','DA1518vrda'];
outdir=['/work/pwin/plot_cal/Zh/',expri,'/'];
%---
cmap=colormap_rms;
L=[8 9 10 11 12 13 14 15 16 17 18 19 20 21 22];
if zmind~=0;    filenam=['zm_',filenam];  end
%---
for ti=1:num;
  time=hm(ti,:);  
  zh=[]; lon=[]; lat=[]; sweep=[];
  for mi=1:40
    nen=num2str(mi);
    if mi<=9
    infile=[indir,'/',type,'_d03_2009-08-08_',time,':00_0',nen];
    elseif mi>=10
    infile=[indir,'/',type,'_d03_2009-08-08_',time,':00_',nen];    
    end
    A=importdata(infile);
    zh(:,mi) =A(:,9);        
  end
  sprd=spread(zh);
  %----choose elevation angle----
  lon=A(:,5); lat=A(:,6);  sweep=A(:,2);
  sprd(zh(:,1)==-9999)=NaN;   
  for swi=sw
    lon_sw=lon(sweep==swi);  lat_sw=lat(sweep==swi);
    sprd_sw=sprd(sweep==swi);
    %---plot---
    %{
    plot_radar(sprd_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
    tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  ',type,'  (',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,filenam,time(1:2),time(4:5),'_',type,'_',num2str(swi),'.png'];
    print('-dpng',outfile,'-r350')
    %}
  end
  sprd(isnan(sprd)==1)=0;
  sprd_vol(ti)=(mean(sprd.^2))^0.5;
end


