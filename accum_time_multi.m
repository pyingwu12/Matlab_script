close all
clear;  ccc=':';

%dark blue: 0,0.447,0.741;   %light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125;  %orange: 0.85,0.325,0.098;   
%purple: 0.494,0.184,0.556;  %dark red: [0.6350 0.0780 0.1840]
%green: 0.466,0.674,0.188
%-------------------------------
% 
expri={'TWIN005B';'TWIN005P';'TWIN006B';'TWIN006P';'TWIN007B';'TWIN007P'};   exptext='TWINweakP';   bdy=0;  
expnam={'TWIN005B';'TWIN005P';'TWIN006B';'TWIN006P';'TWIN007B';'TWIN007P'};
dom={'01';'01';'01';'01';'01';'01';'01'};
lexp={'-';'--';'-';'--';'-';'--'};  
cexp=[0  0.447  0.741; 0  0.447  0.741; 0.85,0.325,0.098; 0.85,0.325,0.098; 0.466,0.674,0.188 ;0.466,0.674,0.188 ];


%---setting
sth=15;  lenh=48;  tint=3;
typst='mean';%mean/sum/max
time='2018062100';
nexp=size(expri,1);   
%
outdir='/mnt/e/figures/expri_twin';
titnam='Hourly Rainfall';   fignam=['hourlyrain_',exptext,'_'];

acci=zeros(nexp,lenh);
for i=1:nexp
   acci(i,:)=cal_hrly_accum(expri{i},time,sth,lenh,dom{i},bdy,typst,ccc);
   disp([expri{i},' done'])
end

%%
%---set x tick---
xi=(1:lenh);
nti=0;
for ti=sth:tint:sth+lenh
  hr=mod(ti+9,24);
  nti=nti+1;  ss_hr{nti}=num2str(hr,'%2.2d');
end
%%
%---plot
hf=figure('position',[100 45 1000 600]);
for i=1:nexp
plot(xi+0.5,acci(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.2); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'location','nw');
%
set(gca,'XLim',[1 lenh+1],'XTick',xi(1:tint:end),'XTickLabel',ss_hr,...
    'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',18);  ylabel('Rainfall (mm)','fontsize',18)
%---
tit=[titnam,'  (',upper(typst),')  '];     
title(tit,'fontsize',19)
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,time(5:6),time(7:8),'_',s_sth,time(9:10),'_',s_lenh,'hr_',typst];
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
