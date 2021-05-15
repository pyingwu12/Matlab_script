clear;  ccc=':';
%---
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='23';  hr=3;  minu=0;  
%
year='2018'; mon='06';  
dirmem='pert'; infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin/';  
%
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile2,'HGT');
    %
    if zhid~=0; zh_max=cal_zh_cmpo(infile2,'WSM6'); end  % zh of perturbed state   
    
    tic
    MDTE = cal_DTEmo_2D(infile1,infile2) ; 
    toc
    
    tic
    MDTE = cal_DTEmo_2D_temp(infile1,infile2) ;  % vertical weighted average (dPm=dP/dPall)      
    toc    
 
  end %tmi
end