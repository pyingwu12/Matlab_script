%function vr_scoreda(hm,sw,expri,type,zmind)
clear
hm=['16:00'];
%hm=['15:30'];
expri='MRcycle06'; type='anal';  tresh=15;

% hm: time, string. ex:'15:00'
% sw: elevation angel (/0.5, 1.4, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/)
% expri: experiment name, string. ex:'orig'
% member: ensemble member you want to plot  
% zmind: if zmind~=0, figure will zoom in to lon=[119.1 121.4]; lat=[22
% 24.3];

%---setting---
num=size(hm,1);
indir=['/work/pwin/data/morakot_wrf2obs_',expri];
%outdir=['/work/pwin/plot_cal/Vr/',expri,'/'];
%---
for ti=1:num;
  time=hm(ti,:); 
%===obs===
   infile1=['/SAS004/pwin/obs_new/obs_d03_2009-08-08_',time,':00'];
   A=importdata(infile1);
   vr1 =A(:,8);   
%===wrf=====  
  for tyi=2
    if tyi==1; type='fcst'; elseif tyi==2; type='anal'; end
    for mi=1:40
      nen=num2str(mi);
      if mi<=9
       infile=[indir,'/',type,'_d03_2009-08-08_',time,':00_0',nen];
      elseif mi>=10
       infile=[indir,'/',type,'_d03_2009-08-08_',time,':00_',nen];    
      end
      B=importdata(infile);
      vr2=B(:,8);        
      
        fin=find(vr2~=-9999 & vr1~=-9999);
        vro=vr1(fin); vrw=vr2(fin);   
        [scc(mi,ti) rmse(mi,ti) ETS(mi,ti) bias(mi,ti)]=score(vro,vrw,tresh);
      
    end    
    
    %sprd=spread(vr2); 
    %rmse=RMSE(vr2,vr1); 
  %---
    %sprd_vol(2*(ti-1)+tyi)=(mean(sprd.^2))^0.5;
    %rmse_vol(2*(ti-1)+tyi)=(mean(rmse.^2))^0.5;
  end
end

if size(scc,1)==40
  scc(:,ti+1)=mean(scc,2);
  rmse(:,ti+1)=mean(rmse,2); 
  [scc(:,ti+2) scc(:,ti+3)]=sort(scc(:,ti+1));
end