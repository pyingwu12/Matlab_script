function [scc rmse ETS bias]=vr_score(hm,expri,target,tresh)

%---input
% hm: time, string. ex:'15:00'
% expri: experiment name, string. ex:'orig'
% target: 'mean' or 'member'
%---output
% SCC : scc(member,time+mean+sort)

%---set time and wrf directory---
%hm=['15:00';'16:00';'17:00'];   expri='orig';
num=size(hm,1);
indir=['/work/pwin/data/morakot_wrf2obs_',expri];
%---
for ti=1:num;
   time=hm(ti,:);
%===obs===
   infile1=['/SAS004/pwin/obs_new/obs_d03_2009-08-08_',time,':00'];
   A=importdata(infile1);
   vr1 =A(:,8);   
%===wrf======
   switch(target)
   case('mean')
     infile=[indir,'/wrfout_d03_2009-08-08_',time,':00_mean'];
     B=importdata(infile);
     vr2=B(:,8); 
%----
     fin=find(vr2~=-9999 & vr1~=-9999);
     vro=vr1(fin); vrw=vr2(fin); 
     [scc(ti,1) rmse(ti,1) ETS(ti,1) bias(ti,1)]=score(vro,vrw,tresh);
     scc(ti,2)=str2num(time(1:2));
     rmse(ti,2)=str2num(time(1:2));
   case('member')    
     for mi=1:40;
% --- wrf filename----
        nen=num2str(mi);
        if mi<=9
         infile2=[indir,'/wrfinput_d03_2009-08-08_',time,':00_0',nen];
        else
         infile2=[indir,'/wrfinput_d03_2009-08-08_',time,':00_',nen];
        end  
        B=importdata(infile2); 
       vr2 =B(:,8);  
%========= cal ==========
        fin=find(vr2~=-9999 & vr1~=-9999);
        vro=vr1(fin); vrw=vr2(fin);   
        [scc(mi,ti) rmse(mi,ti) ETS(mi,ti) bias(mi,ti)]=score(vro,vrw,tresh);
     end %member
   end
   disp([time(1:2),time(4:5),' OK'])
end
if size(scc,1)==40
  scc(:,ti+1)=mean(scc,2);
  rmse(:,ti+1)=mean(rmse,2); 
  [scc(:,ti+2) scc(:,ti+3)]=sort(scc(:,ti+1));
end
