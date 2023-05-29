close all
clear;  ccc=':';
%-------------------------------
%
expri={'TWIN001B';'TWIN001Pr001qv062221';'TWIN003B';'TWIN003Pr001qv062221'};   exptext='NHMwspert';   bdy=0;  
expnam={'FLAT_cntl';'FLAT_pert';'TOPO_cntl';'TOPO_pert'};
dom={'01';'01';'01';'01'};
lexp={'-';'--';'-';'--'};  
cexp=[0  0.447  0.741; 0.3,0.745,0.933; 0.85,0.325,0.098;  0.929,0.694,0.125];

%---setting
sth=18;  lenh=54;  tint=4;  typst='mean';%mean/sum/max
ymdm='2018062100';  
%
% indir='/mnt/HDD003/pwin/Experiments/expri_test/'; outdir='/mnt/e/figures/expri_test';
indir='/mnt/HDD008/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='2-m Water vapor';    fignam=['Q2_',exptext,'_'];
nexp=size(expri,1);

%---
plotvar=zeros(nexp,lenh);
for i=1:nexp
  plotvar(i,:)=cal_q2(indir,expri{i},ymdm,sth,lenh,dom{i},bdy,typst,ccc);
  disp([expri{i},' done'])
end
%
%---set x tick---
nti=0; ss_hr=cell(length(tint:tint:lenh),1);
for ti=tint:tint:lenh
  nti=nti+1;  
  ss_hr{nti}=num2str(mod(sth+ti-1+9,24),'%2.2d');
end
%%
%---plot---
hf=figure('position',[100 55 1000 600]);
for i=1:nexp
  plot(plotvar(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.5); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','se','FontName','Monospaced');
%
set(gca,'XLim',[1 lenh],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Time (JST)');  ylabel('Mixing ratio (g/Kg)')
tit=[titnam,'  (domain ',typst,')  '];   
title(tit,'fontsize',18)
%
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,ymdm(5:6),ymdm(7:8),'_',s_sth,ymdm(9:10),'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
