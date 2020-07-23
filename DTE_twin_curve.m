clear;  %ccc=':';
close all

expri1={'twin02';'twin03'};  exptext='twin02';
expri2={'test94';'test94'};
expnam={'twin02';'twin03'};
col=[0 0.447 0.741;  0.85,0.325,0.098]; 

%---setting---
stdate=21; sth=21;  lenh=18;  minu=[00 30];  tint=2;

outdir='/mnt/e/figures/expri191009/';
titnam='DTE';   fignam=['DTE_',exptext,'_'];
nexp=size(expri1,1);

%----
MDTE=zeros(lenh*length(minu),nexp);
for i=1:nexp
 MDTE(:,i)=cal_DTE_twin(expri1{i},expri2{i},stdate,sth,lenh,minu);
 disp([expri1{i},' done'])
end

%---
nti=0;
for ti=1:tint:lenh 
   nti=nti+1;
   hr=sth+ti-1+9;  ss_hr{nti}=num2str(mod(hr,24),'%2.2d');
end
%%
%---plot
hf=figure('position',[100 50 1000 550]) ;

for i=1:nexp
  plot(MDTE(:,i),'color',col(i,:),'LineWidth',2.2); hold on
end

legh=legend(expnam,'Box','off','Interpreter','none','fontsize',16,'location','northwest');

set(gca,'YScale','log','Linewidth',1.2,'fontsize',13)
set(gca,'Xlim',[1 lenh*length(minu)],'XTick',1:tint*length(minu):length(minu)*lenh,'XTickLabel',ss_hr)
xlabel('Time(JST)','fontsize',15); ylabel('TDE mean','fontsize',15)

%---
tit=[titnam,'  ',ss_hr{1},'00-',ss_hr{end},'00 JST'];     
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,num2str(sth),'_',num2str(lenh),'h_'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
