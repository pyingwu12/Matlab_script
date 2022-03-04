%function vr_rmse(hm,sw,expri,type,zmind)
clear
hm='17:00'; sw=[0.5 1.4 2.4 3.4 4.3]; expri='DA1517vr'; zmind=1;  type='fcst';

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
vari='Vr rmse';    filenam=[expri,'_vr-rmse_'];
num=size(hm,1);
indir=['/work/pwin/data/morakot_wrf2obs_',expri];
outdir=['/work/pwin/plot_cal/Vr/',expri,'/'];
%---
cmap=colormap_rms;
L=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
if zmind~=0;    filenam=['zm_',filenam];  end
%---
for ti=1:num;
  time=hm(ti,:);
%===obs===
   infile1=['/SAS004/pwin/obs_new/obs_d03_2009-08-08_',time,':00'];
   A=importdata(infile1);
   vr1 =A(:,8);   
%===wrf=====  
     for mi=1:40;
% --- wrf filename----
        nen=num2str(mi);
        if mi<=9
         infile2=[indir,'/',type,'_d03_2009-08-08_',time,':00_0',nen];
        else
         infile2=[indir,'/',type,'_d03_2009-08-08_',time,':00_',nen];
        end  
        B=importdata(infile2); 
        vr2(:,mi) =B(:,8);          
     end %member
  vr1(vr1==-9999)=0;  vr2(vr2==-9999)=0;
  rmse=RMSE(vr2,vr1);
  rmse_vol=(mean(rmse.^2))^0.5;
  %---plot---
  %----choose elevation angle----
  lon=A(:,5); lat=A(:,6);  sweep=A(:,2);
  %
  for swi=sw
    lon_sw=lon(sweep==swi);  lat_sw=lat(sweep==swi);
    rmse_sw=rmse(sweep==swi);
    plot_radar(rmse_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
    tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  ',type,'  (',num2str(swi),')'];
    title(tit,'fontsize',15)
    outfile=[outdir,filenam,time(1:2),time(4:5),'_',type,'_',num2str(swi),'.png'];
    print('-dpng',outfile,'-r350')
  end
%}
end