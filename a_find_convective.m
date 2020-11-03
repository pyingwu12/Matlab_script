% close all
clear;   ccc='%3A';
%---setting
expri='TWIN003B';  s_date='23'; hr=1; minu=00; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
scheme='WSM6';
%---
%indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
indir=['e:/wrfout/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='Zh composite';   fignam=[expri,'_zh_'];
%
%---

for ti=hr   
  for mi=minu    
    %ti=hr; mi=minu;
    %---set filename---
    s_hr=num2str(ti,'%2.2d');  % start time string
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    zh_max=cal_zh_cmpo(infile,scheme);         
    hgt = ncread(infile,'HGT');  
    %
    BW=zeros(size(zh_max));
    BW(zh_max>2)=1;
    CC = bwconncomp(BW,8);
    
    L = labelmatrix(CC);
%     imshow(label2rgb(L,'jet','k','shuffle'));
    A=L; A(L~=0)=1;
    figure
    contour(A',[1 1])
    
    for i=1:size(CC.PixelIdxList,2)
     a(i)=size(CC.PixelIdxList{i},1);
    end
   
  end
end