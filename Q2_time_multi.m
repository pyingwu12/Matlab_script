close all
clear;  ccc=':';

%dark blue: 0,0.447,0.741;   %light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125;  %orange: 0.85,0.325,0.098;   
%purple: 0.494,0.184,0.556;  %dark red: [0.6350 0.0780 0.1840]
%green: 0.466,0.674,0.188
%-------------------------------
% 
% expri={'test88';'test91';'test92'};   exptext='LSM-PBL';   bdy=0;  
% expnam={'5-layer';'NOAH';'MYJ'};
% dom={'01';'01';'01';};  
% lexp={'-';'-';'-'};  
% cexp=[0  0.447  0.741; 0.929,0.694,0.125; 0.85,0.325,0.098];

expri={'test101';'test99';'test96'};   exptext='PBLSM';   bdy=0;  
expnam={'111';'121';'222'};
dom={'01';'01';'01';'01'};
lexp={'-';'-';'-'};  
cexp=[ 0,0.447,0.741; 0.85,0.325,0.098; 0.466,0.674,0.188];

%---setting
sth=15;  lenh=24;  tint=2;
typst='mean';%mean/sum/max
time='2018062110';
nexp=size(expri,1);   
%
outdir='/mnt/e/figures/expri_test/';
titnam='Q2';   fignam=['Q2_',exptext,'_'];

acci=zeros(nexp,lenh);
for i=1:nexp
   q2(i,:)=cal_q2(expri{i},time,sth,lenh,dom{i},bdy,typst,ccc);
   disp([expri{i},' done'])
end

%%
%---set x tick---
nti=0;
for ti=sth:tint:sth+lenh
  jti=ti+9;    nti=nti+1;  
  ss_hr{nti}=num2str(mod(jti,24),'%2.2d');
end

%---plot---
hf=figure('position',[100 45 1000 600]);
for i=1:nexp
plot(q2(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.2); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','nw');
%
set(gca,'XLim',[1 lenh],'XTick',1:tint:lenh,'XTickLabel',ss_hr,'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',18);  ylabel('Q2 (g/Kg)','fontsize',18)

%---
tit=[titnam,'  (domain ',typst,')  '];     
title(tit,'fontsize',19)
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,time(5:6),time(7:8),'_',s_sth,time(9:10),'_',s_lenh,'hr_',typst];
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
