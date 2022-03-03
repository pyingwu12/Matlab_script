function hi=vr_cal_impr_hist(expdir,range,hm,day,dom,obsdir,landid)
%-----------------------------------
% cal histogram of Vr improvement after DA
%-----------------------------------

%clear  hm='02:00';  expri='szvrzh124';  

%---experimental setting---
year=day(1:4); mon=day(5:6); date=day(7:8);   % time setting
obsdir=['/SAS004/pwin/data/',obsdir];  indir=['/work/pwin/data/',expdir]; 

%---
time=hm;
%---obs
infile=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
A=importdata(infile);  vro =A(:,8);  
%---fcst 
infile=[indir,'/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
B=importdata(infile);  vrf =B(:,8); 
%---anal
infile=[indir,'/analmean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
C=importdata(infile);  vra =C(:,8);  
%---calculate---    
impr=abs(vro-vra)-abs(vro-vrf);
%---
fin=find(vro~=-9999 & vrf~=-9999 & vra~=-9999);    
irad=A(fin,1); aza=A(fin,3); dis=A(fin,4);
%irad=irad(fin); aza=aza(fin); dis=dis(fin);

if landid==1
    impr=impr(fin); 
    impr=impr(irad==4 & aza>=18 & aza<=148 & dis<123 | irad==3 & aza<=8 | irad==3 & aza>=333);  
elseif landid==-1
    impr=impr(fin); 
    impr=impr(irad==4 & aza<18 | irad==4 & aza>148 | irad==3 & aza>8 & aza<333);  
else 
    impr=impr(fin);
end
  
  hi=cal_histc(impr,range);
  hi=hi./length(impr).*100;
