clear;  ccc=':';
close all

%dark blue: 0,0.447,0.741;   %light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125;  %orange: 0.85,0.325,0.098;   
%purple: 0.494,0.184,0.556;  %dark red: [0.6350 0.0780 0.1840]
%green: 0.466,0.674,0.188
%-------------------------------
%---set experiments---
expri={'ens04';'ens05'};     exptext='ens078';  
expnam={'FLAT';'TOPO'};
col=[0 0.447 0.741;  0.85,0.325,0.098]; 

%---set areas---
%x1=51:150;    x2=201:300;  y1=76:175;    y2=76:175;  
x1=51:150; y1=76:175;    x2=151:250; y2=76:175;  
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'all','L','R'};
linestyl={'--',':'};  markersty={'none','none'};  

%---other settings---
sth=16;  lenh=24;  minu=[00 30];  member=1:10;  tint=2; 
ymd='20180621';  
%
indir='/mnt/HDD003/pwin/Experiments/expri_ens200323'; outdir='/mnt/e/figures/ens200323';
titnam='RMDTE area mean';    fignam=['RMDTE_',exptext,'_'];
%
nexp=size(expri,1);
nminu=length(minu);  ntime=lenh*nminu;
narea=size(xarea,1);

%---
RMDTE_dm=zeros(nexp,ntime); RMDTE_am=zeros(nexp,ntime,narea);
for ei=1:nexp
  RMDTE=cal_RMDTE(indir,expri{ei},ymd,sth,lenh,minu,member,ccc); 
  save(['RMDTE_',expri{ei},'_',ymd(5:8),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min'],'RMDTE')  
  %load(['RMDTE_',expri{ei},'_',ymd,num2str(sth),'_l',num2str(lenh),'_m',num2str(length(minu))])   
  for ti=1:ntime
    RMDTE_dm(ei,ti) = mean(mean(RMDTE{ti}));
    for ai=1:narea
      RMDTE_am(ei,ti,ai)=mean(mean(RMDTE{ti}(xarea(ai,:),yarea(ai,:))));
    end
  end    
end
%---
%
%---set x tick---
nti=0; ss_hr=cell(length(tint:tint:lenh),1);
for ti=tint:tint:lenh
  nti=nti+1;  
  ss_hr{nti}=num2str(mod(sth+ti-1+9,24),'%2.2d');
end

%---set legend---
ni=0;  lgnd=cell(nexp*(narea+1),1);
for ei=1:nexp    
  for ai=0:narea
    ni=ni+1;
    lgnd{ni}=[expnam{ei},'_',arenam{ai+1}];
  end
end

%---plot
hf=figure('position',[100 45 1000 600]);
for ei=1:nexp
  plot(RMDTE_dm(ei,:),'LineWidth',2.5,'color',col(ei,:)); hold on
  for ai=1:narea
    plot(RMDTE_am(ei,:,ai),'LineWidth',2.2,'color',col(ei,:),'linestyle',linestyl{ai},...
        'marker',markersty{ai},'MarkerSize',5,'MarkerFaceColor',col(ei,:));
  end
end
legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','nw');
%
set(gca,'Linewidth',1.2,'fontsize',16)
%set(gca,'YScale','log')
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Time(JST)'); ylabel('RMTDE')  
title(titnam,'fontsize',18)

outfile=[outdir,'/',fignam,ymd(5:8),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min_',num2str(narea),'area'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
