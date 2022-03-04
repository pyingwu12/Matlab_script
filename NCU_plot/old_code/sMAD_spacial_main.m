%-------------------------------------------------
%   Corr.(obs_point,model_2D-level) 
%-------------------------------------------------
%
%function corr_obsmodel_SCCmain(vonam,vmnam)
clear

hr=0;  minu='00';   vonam='Zh';  vmnam='QVAPOR';  

%---set---
addpath('/SAS011/pwin/201work/plot_cal');
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=vmnam(1:2);  else  s_vm=vmnam; end
corrvari=[vonam,',',lower(s_vm)];  
%

sub=12;
sub2=sub*2+1; 
%-----------------

n=0;

%
rad=4;  ela=0.5; aza=128:5:348;  dis=83; 
for i=1:length(aza)
  n=n+1
  [corr256 corr40 lon(n) lat(n) , ~]=Corr256n40_fun(hr,minu,vonam,vmnam,rad,ela,aza(i),dis,sub);
  maxcorr=max(max(abs(corr40),abs(corr256)));  err(n)=sum(abs(corr40-corr256))/length(corr256)/maxcorr;
end
s_rad=num2str(rad); s_ela=num2str(ela); s_dis=num2str(dis); s_sub=num2str(sub);
save(['stnerr_',vonam,'-',lower(s_vm),'_',s_rad,'-',s_ela,'-',s_dis,'_',s_sub,'.mat'],'err','lon','lat')




