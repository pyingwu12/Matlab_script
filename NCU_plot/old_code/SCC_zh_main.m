%------------------
%  use function<corr_obsmodel_fun> to calculate corr. of 256 member and randam 40 member
%  than calculate SCC and plot zh-SCC graphic
%--------------------

clear

hr=0;  minu='00';   vonam='Zh';  vmnam='QVAPOR';

%---set---
addpath('/SAS011/pwin/201work/plot_cal');
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=vmnam(1:2);  else  s_vm=vmnam; end
corrvari=[vonam,',',lower(s_vm)];
%
varinam=['SCC of Corr'];    filenam=['Corr-SCC-zh_'];
%
sub=4;

%-----------------

infile='/SAS011/pwin/201work/data/largens_wrf2obs_largens/wrfmean_d02_2008-06-16_00:00:00';
A=importdata(infile); ela=A(:,2); hgt=A(:,7);  %zh=A(:,9);
finobs=find(hgt<1200 & hgt >800 & ela<4 );
%length(finobs)
%
n=0;
%
for oi=10:31:length(finobs);
  n=n+1
  [corr256, corr40 , ~, ~, zhmean(n)]=corr_obsmodel_SCCfun(hr,minu,vonam,vmnam,A(finobs(oi),1),A(finobs(oi),2),A(finobs(oi),3),A(finobs(oi),4),sub);
  [scc(n), ~, ~, ~]=score(corr40,corr256,0.1);
end  
  save(['zh-scc_',vonam,'-',lower(s_vm),'_',num2str(sub),'.mat'],'scc','zhmean')
%}


%figure('position',[100 100 650 500])

%plot(zhmean,SCC,'ok','MarkerSize',3)


