function SCC_rand_main(vonam,vmnam,sub)
%------------------
%  use function<corr_obsmodel_fun> to calculate corr. of 256 member and randam 40 member
%  than calculate SCC and plot zh-SCC graphic
%--------------------

%clear

hr=0;  minu='00';  % vonam='Zh';  vmnam='QVAPOR';

%---set---
addpath('/SAS011/pwin/201work/plot_cal');
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=vmnam(1:2);  else  s_vm=vmnam; end
corrvari=[vonam,',',lower(s_vm)];
%
%varinam=['SCC of Corr'];    filenam=['Corr-SCC-zh_'];
%
%sub=36;
sub2=sub*2+1;
randtimes=20;

%-----------------

pradar=4;  pela=0.5;  paza=188;  pdis=83;  point='B';
%
for i=1:randtimes
  i
  [corr256, corr40 , ~, ~, ~]=Corr256n40_rand_fun(hr,minu,vonam,vmnam,pradar,pela,paza,pdis,sub);
  corr256r=reshape(corr256,sub2,sub2);
  corr40r=reshape(corr40,sub2,sub2);
  
  corr256_12=reshape(corr256r(25:49,25:49),25*25,1);
  corr40_12=reshape(corr40r(25:49,25:49),25*25,1);

  corr256_4=reshape(corr256r(33:41,33:41),9*9,1);
  corr40_4=reshape(corr40r(33:41,33:41),9*9,1);

  [scc36(i), ~, ~, ~]=score(corr40,corr256,0.1);
  [scc12(i), ~, ~, ~]=score(corr40_12,corr256_12,0.1);
  [scc4(i), ~, ~, ~]=score(corr40_4,corr256_4,0.1);
end  

  [corr256, corr40 , ~, ~, ~]=Corr256n40_fun(hr,minu,vonam,vmnam,pradar,pela,paza,pdis,sub);
  corr256r=reshape(corr256,sub2,sub2);
  corr40r=reshape(corr40,sub2,sub2);

  corr256_12=reshape(corr256r(25:49,25:49),25*25,1);
  corr40_12=reshape(corr40r(25:49,25:49),25*25,1);

  corr256_4=reshape(corr256r(33:41,33:41),9*9,1);
  corr40_4=reshape(corr40r(33:41,33:41),9*9,1);

  [scc36(i+1), ~, ~, ~]=score(corr40,corr256,0.1);
  [scc12(i+1), ~, ~, ~]=score(corr40_12,corr256_12,0.1);
  [scc4(i+1), ~, ~, ~]=score(corr40_4,corr256_4,0.1);


  scc=scc36;  save(['scc21_',vonam,'-',lower(s_vm),'_36',point,'.mat'],'scc')
  scc=scc12;  save(['scc21_',vonam,'-',lower(s_vm),'_12',point,'.mat'],'scc')
  scc=scc4;  save(['scc21_',vonam,'-',lower(s_vm),'_4',point,'.mat'],'scc')
  
  %scc=scc36;  save(['scc-rand_',vonam,'-',lower(s_vm),'_36',point,'.mat'],'scc')
  %scc=scc12;  save(['scc-rand_',vonam,'-',lower(s_vm),'_12',point,'.mat'],'scc')
  %scc=scc4;  save(['scc-rand_',vonam,'-',lower(s_vm),'_4',point,'.mat'],'scc')
%}



