close all
clear;  ccc=':';

%dark blue: 0,0.447,0.741;   %light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125;  %orange: 0.85,0.325,0.098;   
%purple: 0.494,0.184,0.556;  %dark red: [0.6350 0.0780 0.1840]
%green: 0.466,0.674,0.188
%-------------------------------
% 
expri={'test88';'test91'};   exptext='LSM';   bdy=0;  
expnam={'5-layer';'NOAH'};
dom={'01';'01';};  
lexp={'-';'-'};  
cexp=[0  0.447  0.741; 0.929,0.694,0.125];

%---setting
sth=16;  lenh=48;  tint=3;
typst='mean';%mean/sum/max
time='2018062100';
nexp=size(expri,1);   
%
outdir='/mnt/e/figures/expri191009/';
titnam='Latent heat flux at surface';   fignam=['LHfx_',exptext,'_'];

acci=zeros(nexp,lenh);
for i=1:nexp
   lhfx(i,:)=cal_lhfx(expri{i},time,sth,lenh,dom{i},bdy,typst,ccc);
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
plot(lhfx(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.2); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','best');
%
set(gca,'XLim',[1 lenh],'XTick',1:tint:lenh,'XTickLabel',ss_hr,'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',18);  ylabel('Latent heat Flux (W m^-^2)','fontsize',18)

%---
tit=[titnam,'  (domain ',typst,')  '];     
title(tit,'fontsize',19)
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,time(5:6),time(7:8),'_',s_sth,time(9:10),'_',s_lenh,'hr_',typst];
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
 