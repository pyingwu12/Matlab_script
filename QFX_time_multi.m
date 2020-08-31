close all
clear;  ccc=':';

%dark blue: 0,0.447,0.741;   %light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125;  %orange: 0.85,0.325,0.098;   
%purple: 0.494,0.184,0.556;  %dark red: [0.6350 0.0780 0.1840]
%green: 0.466,0.674,0.188
%-------------------------------
% 
expri={'TWIN005B';'TWIN005Pr001qv21';'TWIN006B';'TWIN006Pr001qv21'};   exptext='TWINweak';   bdy=0;  
expnam={'TWIN005B';'5Pr001qv21';'TWIN006B';'6Pr001qv21'};
dom={'01';'01';'01';'01'};
lexp={'-';'-';'-';'-'};  
cexp=[0  0.447  0.741; 0.3,0.745,0.933; 0.85,0.325,0.098; 0.929,0.694,0.125];

%---setting
sth=16;  lenh=48;  tint=3;  typst='mean';%mean/sum/max
ymdm='2018062100';  
%
% indir='/mnt/HDD003/pwin/Experiments/expri_test/'; outdir='/mnt/e/figures/expri_test/';
indir='/mnt/HDD008/pwin/Experiments/expri_twin/'; outdir='/mnt/e/figures/expri_twin/';
titnam='Upward Qv flux at surface';   fignam=['qvfx_',exptext,'_'];
nexp=size(expri,1);
%
%---
plotvar=zeros(nexp,lenh);
for i=1:nexp
  plotvar(i,:)=cal_qfx(indir,expri{i},ymdm,sth,lenh,dom{i},bdy,typst,ccc);
  disp([expri{i},' done'])
end
%

%---set x tick---
nti=0; ss_hr=cell(length(tint:tint:lenh),1);
for ti=tint:tint:lenh
  nti=nti+1;  
  ss_hr{nti}=num2str(mod(sth+ti-1+9,24),'%2.2d');
end
%---plot---
hf=figure('position',[100 45 1000 600]);
for i=1:nexp
  plot(plotvar(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.5); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','nw');
%
set(gca,'XLim',[1 lenh],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Time (JST)');  ylabel('Moisture Flux (kg m^-^2 s^-^1)')
tit=[titnam,'  (domain ',typst,')  '];   
title(tit,'fontsize',18)
%
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,ymdm(5:6),ymdm(7:8),'_',s_sth,ymdm(9:10),'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
 