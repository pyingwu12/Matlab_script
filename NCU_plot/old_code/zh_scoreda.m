%function zh_scoreda(hm,sw,expri,type,zmind)
clear
hm=['15:00'];
%hm=['15:30'];
sw=1.4; expri='MRcycle06'; zmind=1;  type='anal';

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
  zh2=[]; 
%===obs===
   infile1=['/SAS004/pwin/obs_new/obs_d03_2009-08-08_',time,':00'];
   A=importdata(infile1);
   zh1 =A(:,9);   
   zh1(zh1==-9999)=0;
%===wrf=====  
  for tyi=1:2
    if tyi==1; type='fcst'; elseif tyi==2; type='anal'; end
    for mi=1:40
      nen=num2str(mi);
      if mi<=9
       infile=[indir,'/',type,'_d03_2009-08-08_',time,':00_0',nen];
      elseif mi>=10
       infile=[indir,'/',type,'_d03_2009-08-08_',time,':00_',nen];    
      end
      B=importdata(infile);
      zh2(:,mi) =B(:,9);        
    end    
    sprd=spread(zh2); sprd(zh2(:,mi)==-9999)=0;
    rmse=RMSE(zh2,zh1); rmse(zh2(:,mi)==-9999)=0;
  %---
    sprd_vol(2*(ti-1)+tyi)=(mean(sprd.^2))^0.5;
    rmse_vol(2*(ti-1)+tyi)=(mean(rmse.^2))^0.5;
  end
end

