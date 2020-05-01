clear;  %ccc=':';
close all

expri={'ens02';'ens03';'ens04'};   exptext='ens001';  
% dom={'01';'01';'01'};
expnam={'ens02';'';'ens03';'';'ens04';''};
 %lexp={'-';'-';'-';'-'};  
cexp=[0  0.447  0.741; 0.466,0.674,0.188; 0.85,0.325,0.098]; 


%---setting
xi=81:120;  yi=81:120;
sth=22;  lenh=24;  minu=[00];
member=1:10; 

outdir='/mnt/e/figures/ens200323/';
titnam='RMDTE';   fignam=['RMDTE_',exptext,'_'];
nexp=size(expri,1); 
%----

RMDTE_t=zeros(nexp,lenh*length(minu));
RMDTEcen_t=zeros(nexp,lenh*length(minu));
for i=1:nexp
 RMDTE=cal_DTE(expri{i},sth,lenh,minu,member);
 disp([expri{i},' done'])
 for ti=1:size(RMDTE,2)
 RMDTE_t(i,ti)=mean(mean(RMDTE{ti}));
 RMDTEcen_t(i,ti)=mean(mean(RMDTE{ti}(xi,yi)));
 end
end


%%
tint=2;
nti=0;
for ti=1:tint:lenh 
   nti=nti+1;
   hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
   ss_hr{nti}=num2str(hr,'%2.2d');
end

%---plot
hf=figure('position',[100 50 800 550]) ;
%hold on
for i=1:nexp
 plot(RMDTE_t(i,:),'LineWidth',1.55,'color',cexp(i,:)); hold on
 plot(RMDTEcen_t(i,:),'LineWidth',1.55,'color',cexp(i,:),'linestyle','--');
end
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',16,'location','northwest');
set(gca,'Linewidth',1.2,'fontsize',13)
set(gca,'Xlim',[1 lenh],'XTick',1:tint*length(minu):length(minu)*lenh,'XTickLabel',ss_hr)
xlabel('Time(UTC)','fontsize',15); ylabel('RMTDE','fontsize',15)
%---
tit=[titnam,'  ',ss_hr{1},'00-',ss_hr{end},'00UTC'];     
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,num2str(sth),'_',num2str(lenh),'h'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

