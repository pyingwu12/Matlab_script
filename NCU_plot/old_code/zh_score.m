%function [scc rmse ETS bias]=zh_score(hm,expri,target,tresh)
% hm: time, string. ex:'15:00'
% expri: experiment name, string. ex:'orig'
% target: 'mean' or 'member'
clear
hm=['16:00'];   expri='MRcycle12'; target='member'; tresh=15;

%---set time and wrf directory---
num=size(hm,1);
indir=['/work/pwin/data/morakot_wrf2obs_',expri];
%---
for ti=1:num;
   time=hm(ti,:);
%===obs===
   infile1=['/SAS004/pwin/obs_new/obs_d03_2009-08-08_',time,':00'];
   A=importdata(infile1);
   zh1 =A(:,9);   ela=A(:,2);  
%===wrf======
   switch(target)
   case('mean')
     infile=[indir,'/wrfout_d03_2009-08-08_',time,':00_mean'];
     B=importdata(infile);
     zh2=B(:,9); 
%----
     zho=zh1(zh2~=-9999); zhw=zh2(zh2~=-9999); 
     [scc(ti,1) rmse(ti,1) ETS(ti,1) bias(ti,1)]=score(zho,zhw,tresh);
     scc(ti,2)=str2num(time(1:2));
     rmse(ti,2)=str2num(time(1:2));
   case('member')    
     for mi=1:40;
% --- wrf filename----
        nen=num2str(mi);
        if mi<=9
         infile2=[indir,'/anal_d03_2009-08-08_',time,':00_0',nen];
        else
         infile2=[indir,'/anal_d03_2009-08-08_',time,':00_',nen];
        end  
        B=importdata(infile2); 
        zh2 =B(:,9);   
%========= cal ==========
        zho=zh1(zh2~=-9999 & zh2~=0); zhw=zh2(zh2~=-9999 & zh2~=0);  
        %zho_sw=zho(ela==0.5 );   zhw_sw=zhw(ela==0.5 );
        zho_sw=zho(ela==0.5 | ela==1.4);   zhw_sw=zhw(ela==0.5 | ela==1.4);
        %[scc(mi,ti) rmse(mi,ti) ETS(mi,ti) bias(mi,ti)]=score(zho,zhw,tresh);
        [scc(mi,ti) rmse(mi,ti) ETS(mi,ti) bias(mi,ti)]=score(zho_sw,zhw_sw,tresh);
     end %member
   end
   disp([time(1:2),time(4:5),' OK'])
end
if size(scc,1)==40
  scc(:,ti+1)=mean(scc,2);
  rmse(:,ti+1)=mean(rmse,2); 
  [scc(:,ti+2) scc(:,ti+3)]=sort(scc(:,ti+1));
end