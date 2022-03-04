function ABSerr_rand_main(vonam,vmnam,sub)
%------------------
%  use function<corr_obsmodel_fun> to calculate corr. of 256 member and randam 40 member
%  than calculate SCC and plot zh-SCC graphic
%--------------------

%clear
hr=0;  minu='00';   
%vonam='Zh';  vmnam='QVAPOR';  sub=36;

%---set---
addpath('/SAS011/pwin/201work/plot_cal');
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=vmnam(1:2);  else  s_vm=vmnam; end
corrvari=[vonam,',',lower(s_vm)];
%
sub2=sub*2+1;
randtimes=20;

%-----------------
%
pradar=4;  pela=0.5;  paza=188;  pdis=83;  point='B';
%
for i=1:randtimes
  i
  [corr256, corr40 , ~, ~, ~]=Corr256n40_rand_fun(hr,minu,vonam,vmnam,pradar,pela,paza,pdis,sub);
  maxcorr=max(max(abs(corr40),abs(corr256)));
  %err36(i)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);
  err12(i)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);

  %corr256r=reshape(corr256,sub2,sub2);
  %corr40r=reshape(corr40,sub2,sub2);
  
  %corr256_12=reshape(corr256r(25:49,25:49),25*25,1);
  %corr40_12=reshape(corr40r(25:49,25:49),25*25,1);
  %maxcorr=max(max(abs(corr40_12),abs(corr256_12)));
  %err12(i)=sum(abs(corr40_12/maxcorr-corr256_12/maxcorr))/length(corr256_12);

  %corr256_4=reshape(corr256r(33:41,33:41),9*9,1);
  %corr40_4=reshape(corr40r(33:41,33:41),9*9,1);
  %maxcorr=max(max(abs(corr40_4),abs(corr256_4)));
  %err4(i)=sum(abs(corr40_4/maxcorr-corr256_4/maxcorr))/length(corr256_4);
end  
%
  [corr256, corr40 , ~, ~, ~]=Corr256n40_fun(hr,minu,vonam,vmnam,pradar,pela,paza,pdis,sub);
%  corr256r=reshape(corr256,sub2,sub2);
%  corr40r=reshape(corr40,sub2,sub2);

%  corr256_12=reshape(corr256r(25:49,25:49),25*25,1);
%  corr40_12=reshape(corr40r(25:49,25:49),25*25,1);

%  corr256_4=reshape(corr256r(33:41,33:41),9*9,1);
%  corr40_4=reshape(corr40r(33:41,33:41),9*9,1);

  maxcorr=max(max(abs(corr40),abs(corr256)));
  %err36(i+1)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);
  err12(i+1)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);
  %maxcorr=max(max(abs(corr40_12),abs(corr256_12)));
  %err12(i+1)=sum(abs(corr40_12/maxcorr-corr256_12/maxcorr))/length(corr256_12);
  %maxcorr=max(max(abs(corr40_4),abs(corr256_4)));
  %err4(i+1)=sum(abs(corr40_4/maxcorr-corr256_4/maxcorr))/length(corr256_4);

  %abserr=err36;  save(['smad_',vonam,'-',lower(s_vm),'_36',point,'.mat'],'abserr')
  abserr=err12;  save(['smad_',vonam,'-',lower(s_vm),'_12',point,'.mat'],'abserr')
  %abserr=err4;  save(['smad_',vonam,'-',lower(s_vm),'_4',point,'.mat'],'abserr')
%}

%
pradar=4;  pela=0.5;  paza=248;  pdis=83;  point='A';
%
for i=1:randtimes
  i
  [corr256, corr40 , ~, ~, ~]=Corr256n40_rand_fun(hr,minu,vonam,vmnam,pradar,pela,paza,pdis,sub);
  maxcorr=max(max(abs(corr40),abs(corr256)));
  %err36(i)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);
  err12(i)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);

%  corr256r=reshape(corr256,sub2,sub2);
%  corr40r=reshape(corr40,sub2,sub2);

%  corr256_12=reshape(corr256r(25:49,25:49),25*25,1);
%  corr40_12=reshape(corr40r(25:49,25:49),25*25,1);
%  maxcorr=max(max(abs(corr40_12),abs(corr256_12)));
%  err12(i)=sum(abs(corr40_12/maxcorr-corr256_12/maxcorr))/length(corr256_12);

%  corr256_4=reshape(corr256r(33:41,33:41),9*9,1);
%  corr40_4=reshape(corr40r(33:41,33:41),9*9,1);
%  maxcorr=max(max(abs(corr40_4),abs(corr256_4)));
%  err4(i)=sum(abs(corr40_4/maxcorr-corr256_4/maxcorr))/length(corr256_4);
end

  [corr256, corr40 , ~, ~, ~]=Corr256n40_fun(hr,minu,vonam,vmnam,pradar,pela,paza,pdis,sub);
  %corr256r=reshape(corr256,sub2,sub2);
  %corr40r=reshape(corr40,sub2,sub2);

  %corr256_12=reshape(corr256r(25:49,25:49),25*25,1);
  %corr40_12=reshape(corr40r(25:49,25:49),25*25,1);

  %corr256_4=reshape(corr256r(33:41,33:41),9*9,1);
  %corr40_4=reshape(corr40r(33:41,33:41),9*9,1);

  maxcorr=max(max(abs(corr40),abs(corr256)));
  %err36(i+1)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);
  err12(i+1)=sum(abs(corr40/maxcorr-corr256/maxcorr))/length(corr256);
  %maxcorr=max(max(abs(corr40_12),abs(corr256_12)));
  %err12(i+1)=sum(abs(corr40_12/maxcorr-corr256_12/maxcorr))/length(corr256_12);
  %maxcorr=max(max(abs(corr40_4),abs(corr256_4)));
  %err4(i+1)=sum(abs(corr40_4/maxcorr-corr256_4/maxcorr))/length(corr256_4);

%  abserr=err36;  save(['smad_',vonam,'-',lower(s_vm),'_36',point,'.mat'],'abserr')
  abserr=err12;  save(['smad_',vonam,'-',lower(s_vm),'_12',point,'.mat'],'abserr')
%  abserr=err4;  save(['smad_',vonam,'-',lower(s_vm),'_4',point,'.mat'],'abserr')

%}

