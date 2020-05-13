clear;  %ccc=':';
close all

% expri={'ens02';'ens03';'ens04'};   exptext='ens001';  
% expnam={'ens02';'';'ens03';'';'ens04';''};
% cexp=[0  0.447  0.741; 0.466,0.674,0.188; 0.85,0.325,0.098]; 

expri={'ens04';'ens05'};   exptext='ens0405';  
expnam={'ens04';'ens05'};
cexp=[0  0.38  0.641; 0.85,0.325,0.098]; 

%---setting---
sth=16;  lenh=30;  minu=[00];
member=1:20; 

outdir='/mnt/e/figures/ens200323/';
titnam='RMDTE';   fignam=['RMDTE_',exptext,'_'];
nexp=size(expri,1);

%----
% for i=1:nexp
%  RMDTE=cal_DTE(expri{i},sth,lenh,minu,member);
% end

xcen=101:150;    xsw=51:100;    xne=151:200;
ycen=76:125;     ysw=31:80;     yne=121:170;
xi=[xcen; xsw; xne];
yi=[ycen; ysw; yne];

for i=1:nexp
  load(['RMDTE_',expri{i}]) 
  eval(['RMDTE=RMDTE_',expri{i},';'])
  for ti=1:size(RMDTE,2)
    for ai=0:size(xi,1)
      if ai==0
       RMDTE_m(ti,ai+1,i)=mean(mean(RMDTE{ti}));
      else
       RMDTE_m(ti,ai+1,i)=mean(mean(RMDTE{ti}(xi(ai,:),yi(ai,:))));
      end
    end
  end    
end

%---
tint=2;
nti=0;
for ti=1:tint:lenh 
   nti=nti+1;
   hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
   ss_hr{nti}=num2str(hr,'%2.2d');
end

larea={'-','--','-.',':'};
marea={'none','none','x','none'};
lw=[2,1.55,1.55,1.55];

%---plot
hf=figure('position',[100 50 1000 550]) ;
%hold on
for i=1:nexp
  for ai=1:size(RMDTE_m,2)
    plot(RMDTE_m(:,ai,i),'LineWidth',lw(ai),'color',cexp(i,:),...
        'linestyle',larea{ai},'marker',marea{ai});hold on
  end
end
%legh=legend(expnam,'Box','off','Interpreter','none','fontsize',16,'location','northwest');
legend('flat_all','flat_cen','flat_up','flat_down',...
    'topo_all','topo_cen','topo_up','topo_down',...
    'Box','off','fontsize',16,'Interpreter','none','location','Bestoutside')
set(gca,'Linewidth',1.2,'fontsize',13)
set(gca,'Xlim',[1 lenh],'XTick',1:tint*length(minu):length(minu)*lenh,'XTickLabel',ss_hr)
xlabel('Time(UTC)','fontsize',15); ylabel('RMTDE','fontsize',15)
%---
tit=[titnam,'  ',ss_hr{1},'00-',ss_hr{end},'00UTC'];     
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,num2str(sth),'_',num2str(lenh),'h'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

