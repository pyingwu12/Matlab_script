clear;  %ccc=':';
close all

%dark blue: 0,0.447,0.741;   %light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125;  %orange: 0.85,0.325,0.098;   
%purple: 0.494,0.184,0.556;  %dark red: [0.6350 0.0780 0.1840]
%green: 0.466,0.674,0.188
%----

% expri1={'TWIN001Pr001THM21';'TWIN002Pr001THM21';'TWIN003Pr001THM21';'TWIN004Pr001THM21'};  exptext='TWINori_area1';
% expri2={'TWIN001B';'TWIN002B';'TWIN003B';'TWIN004B'};
% expnam={'TWIN001P';'TWIN002P';'TWIN003P';'TWIN004P'};
% col=[0 0.447 0.741; 0.85,0.325,0.098; 0.466,0.674,0.188; 0.494,0.184,0.556;]; 
% %cal_area=[1:300,1:300];
% cal_area=[50:150,75:175];

expri1={'TWIN005P';'TWIN006P';'TWIN007P'};  exptext='TWINweak_area1';
expri2={'TWIN005B';'TWIN006B';'TWIN007B'};
expnam={'TWIN005P';'TWIN006P';'TWIN007P'};
col=[0 0.447 0.741; 0.85,0.325,0.098; 0.466,0.674,0.188]; 
% cal_area=[1:300,1:300];
 cal_area=[50:150,75:175];

% expri1={'TWIN001Pr01qv21';'TWIN001Pr001qv21';'TWIN001Pr01THM21';'TWIN001Pr001THM21'};  exptext='TWIN001_all';
% expri2={'TWIN001B';'TWIN001B';'TWIN001B';'TWIN001B'};
% expnam={'Pr01qv21';'Pr001qv21';'Pr01THM21';'Pr001THM21'};
% col=[0.85,0.325,0.098; 0.929,0.694,0.125; 0  0.447  0.741; 0.3,0.745,0.933];
% cal_area=[1:300,1:300];



% expri1={'twin06';'twin05'};  exptext='twin0605';
% expri2={'sing004';'sing001'};
% expnam={'twin06';'twin05'};
% col=[0 0.447 0.741;  0.85,0.325,0.098]; 

%---setting---
stdate=21; sth=21;  lenh=24;  minu=[10];  tint=2;

%outdir='/mnt/e/figures/expri_test/';
outdir='/mnt/e/figures/expri_twin/';
titnam='DTE';   fignam=['DTE_',exptext,'_'];
nexp=size(expri1,1);

%----
MDTE=zeros(lenh*length(minu),nexp);
for i=1:nexp
 MDTE(:,i)=cal_DTE_twin(expri1{i},expri2{i},cal_area,stdate,sth,lenh,minu);
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

legh=legend(expnam,'Box','off','Interpreter','none','fontsize',16,'location','ne');

% set(gca,'YScale','log','Linewidth',1.2,'fontsize',13)
set(gca,'Xlim',[1 lenh*length(minu)],'XTick',1:tint*length(minu):length(minu)*lenh,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',13)
xlabel('Time(JST)','fontsize',15); ylabel('TDE mean','fontsize',15)

%---
tit=[titnam,'  ',ss_hr{1},'00-',ss_hr{end},'00 JST'];     
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,num2str(sth),'_',num2str(lenh),'h_2'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
