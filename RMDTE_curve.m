clear;  %ccc=':';
close all

% expri={'ens02';'ens03';'ens04'};   exptext='ens001';  
% expnam={'ens02';'';'ens03';'';'ens04';''};

expri={'ens08';'ens07'};   exptext='ens078';  
expnam={'ens08';'ens07'};


% expri={'ens07'};   exptext='ens07';  
% expnam={'ens07'};
% cexp=[0  0.38  0.641]; 


%---setting---
stdate=21; sth=15;  lenh=48;  minu=[00 30];
member=1:10; 

outdir='/mnt/e/figures/ens200323/';
titnam='RMDTE';   fignam=['RMDTE_',exptext,'_'];
nexp=size(expri,1);

%----
% for i=1:nexp
%  RMDTE=cal_DTE(expri{i},stdate,sth,lenh,minu,member);
% end

x1=51:150;    x2=201:300;  
y1=76:175;    y2=76:175;  

xi=[x1; x2];
yi=[y1; y2];

for i=1:nexp
  load(['RMDTE_',expri{i},'_1500_48h_0030min.mat']) 
  eval(['RMDTE=RMDTE_',expri{i},';'])
%   disp([expri{i},' started'])
%   RMDTE=cal_DTE(expri{i},stdate,sth,lenh,minu,member);
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
   hr=sth+ti-1+9;  ss_hr{nti}=num2str(mod(hr,24),'%2.2d');
end
%%
linestyl={'-','--',':'};
markersty={'none','none','none'};
linewid=[3 2.5 2.5];
col=[0 0.447 0.741;  0.85,0.325,0.098]; 

%---plot
hf=figure('position',[100 50 1000 550]) ;
%hold on

for iarea=1:size(RMDTE_m,2)
  for expi=1:nexp
    plot(RMDTE_m(:,iarea,expi),'LineWidth',linewid(iarea),'color',col(expi,:),...
        'linestyle',linestyl{iarea},'marker',markersty{iarea},...
        'MarkerSize',5,'MarkerFaceColor',col(expi,:));hold on
  end
end

%legh=legend(expnam,'Box','off','Interpreter','none','fontsize',16,'location','northwest');
 legend('FLAT_all','TOPO_all','FLAT_L','TOPO_L','FLAT_R','TOPO_R',...
     'Box','off','fontsize',16,'Interpreter','none','location','Bestoutside')
set(gca,'Linewidth',1.2,'fontsize',13)
%set(gca,'Ylim',[0.5 1.4],'YScale','log')
%set(gca,'YScale','log')
%  set(gca,'Xlim',[0+8*2 7*2+20*2],'XTick',1:tint*length(minu):length(minu)*lenh,...
%      'XTickLabel',ss_hr)
%  set(gca,'Xlim',[0+8*2 7*2+20*2])
 set(gca,'XTick',1:tint*length(minu):length(minu)*lenh,...
     'XTickLabel',ss_hr)
% set(gca,'Xlim',[1 size(RMDTE,2)],'XTick',1:tint*length(minu):length(minu)*lenh,...
%     'XTickLabel',ss_hr)
xlabel('Time(JST)','fontsize',15); ylabel('RMTDE','fontsize',15)
%---
tit=[titnam,'  ',ss_hr{1},'00-',ss_hr{end},'00 JST'];     
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,num2str(sth),'_',num2str(lenh),'h_firstday'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

