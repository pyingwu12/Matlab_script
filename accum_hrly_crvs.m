close all
clear;  ccc=':';



% expri={'test38';'test40';'test44';'test48';'test43';'test45'};   exptext='test001';  
% expnam={'CTRL';'03st';'per01';'per01_03st';'topo01';'topo02'};
% lexp={'-';'-';'-';'-';'-';'-'};  
% cexp=[0.3 0.3 0.35; 0.5 0.18 0.55; 0.85,0.325,0.098;  0.929,0.694,0.125; 0,0.447,0.741; 0.3,0.745,0.933]; 

expri={'test40';'test42';'test46';'test47'};   exptext='Nesting_d02';  
expnam={'CTRL';'5km';'3km_f';'3km'};
dom={'01';'02';'02';'02'};
lexp={'-';'-';'-';'-';'-';'-'};  
cexp=[0.3 0.3 0.35; 0.5 0.18 0.55; 0.929,0.694,0.125; 0.3,0.745,0.933]; 

%dark blue: 0,0.447,0.741
%light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125
%orange: 0.85,0.325,0.098
%purple: 0.494,0.184,0.556
%green: 0.466,0.674,0.188

%---setting
typst='mean';%mean/sum/max
time='2018062100';
sth=18;  lenh=27;  
nexp=size(expri,1);   
%
outdir='/mnt/e/figures/expri191009/';
titnam='Hourly Rainfall';   fignam=['hourlyrain_',exptext,'_'];

acci=zeros(nexp,lenh);
for i=1:nexp
   acci(i,:)=cal_hrly_accum(expri{i},time,sth,lenh,dom{i},typst,ccc);
   disp([expri{i},' done'])
end


%%
%---set x tick---
xi=(1:lenh);
nti=0;
tint=2;
for ti=sth:tint:sth+lenh
  jti=ti+9;  
  hrday=fix(jti/24);  hr=jti-24*hrday;
  nti=nti+1;  ss_hr{nti}=num2str(hr,'%2.2d');
end

%
%---plot
hf=figure('position',[-1200 200 1000 600]);
for i=1:nexp
plot(xi+0.5,acci(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.2); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none');
%
set(gca,'XLim',[1 lenh+1],'XTick',xi(1:tint:end),'XTickLabel',ss_hr,...
    'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',18);  ylabel('Rainfall (mm)','fontsize',18)
%---

tit=[titnam,'  (',upper(typst),')  ',ss_hr{1},time(9:10),'-',ss_hr{end},time(9:10),'JST'];     
title(tit,'fontsize',19)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,time(5:6),time(7:8),'_',s_sth,time(9:10),'_',s_lenh,'hr_',typst];

 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
