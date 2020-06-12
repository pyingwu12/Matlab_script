clear;  %ccc=':';
close all

% expri={'ens02';'ens03';'ens04'};   exptext='ens001';  
% expnam={'ens02';'';'ens03';'';'ens04';''};
% cexp=[0  0.447  0.741; 0.466,0.674,0.188; 0.85,0.325,0.098]; 

expri={'ens08';'ens07'};   exptext='ens078';  
expnam={'ens08';'ens07'};


% expri={'ens07'};   exptext='ens07';  
% expnam={'ens07'};
% cexp=[0  0.38  0.641]; 


%---setting---
stdate=21; sth=23;  lenh=18;  minu=[00 30];
member=1:10; 

outdir='/mnt/e/figures/ens200323/';
titnam='RMDTE';   fignam=['RMDTE_',exptext,'_'];
nexp=size(expri,1);

%----
% for i=1:nexp
%  RMDTE=cal_DTE(expri{i},stdate,sth,lenh,minu,member);
% end

% x1=101:150;    x2=51:100;    x3=151:200;
% y1=76:125;     y2=31:80;     y3=121:170;

x1=1:150;    x2=151:300;   x3=1:150; 
y1=1:200;    y2=1:200;    y3=51:150;

xi=[x1; x2];
yi=[y1; y2];

for i=1:nexp
  load(['RMDTE_',expri{i},'_23']) 
  eval(['RMDTE=RMDTE_',expri{i},';'])
  %RMDTE=cal_DTE(expri{i},sth,lenh,minu,member);
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
%%
%---
tint=2;
nti=0;
for ti=1:tint:lenh 
   nti=nti+1;
   hr=sth+ti-1+9;   hrday=fix(hr/24);  hr=hr-24*hrday;
   ss_hr{nti}=num2str(hr,'%2.2d');
end

lsty={'-','-','--'};
msty={'none','none','none'};
lw=[2,2,1.55,1.55];
col=[0.1 0.1 0.1; 0  0.38  0.641; 0.85,0.325,0.098]; 
%%
%---plot
hf=figure('position',[100 50 1000 550]) ;
%hold on
% for i=1:nexp
%   for ai=1:size(RMDTE_m,2)
%     plot(RMDTE_m(:,ai,i),'LineWidth',lw(ai),'color',cexp(i,:),...
%         'linestyle',larea{ai},'marker',marea{ai});hold on
%   end
% end
for i=2
  for ai=2:3
    plot(RMDTE_m(:,ai,i),'LineWidth',lw(ai),'color',col(i,:),...
        'linestyle',lsty{ai},'marker',msty{ai});hold on
  end
end
%legh=legend(expnam,'Box','off','Interpreter','none','fontsize',16,'location','northwest');
% legend('flat_all','flat_cen','flat_up','flat_down',...
%     'topo_all','topo_cen','topo_up','topo_down',...
%     'Box','off','fontsize',16,'Interpreter','none','location','Bestoutside')
set(gca,'Linewidth',1.2,'fontsize',13)
set(gca,'Ylim',[0.5 1.4])
set(gca,'Xlim',[8 size(RMDTE,2)-3],'XTick',1:tint*length(minu):length(minu)*lenh,...
    'XTickLabel',ss_hr)
xlabel('Time(JST)','fontsize',15); ylabel('RMTDE','fontsize',15)
%---
tit=[titnam,'  ',ss_hr{1},'00-',ss_hr{end},'00JST'];     
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,num2str(sth),'_',num2str(lenh),'h'];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);

