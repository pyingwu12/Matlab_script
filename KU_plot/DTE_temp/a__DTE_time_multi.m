clear;  ccc=':';
close all

%---
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='13qv062221';
expri2={'TWIN001B';'TWIN003B'};
expnam={'FLAT';'TOPO'};
col=[  0,0.447,0.741; 0.85,0.325,0.098; 0.466,0.674,0.188]; 

%---set time---
sth=21;  lenh=24;  minu=00;  tint=2;
ymd='20180621';  
%
%---
ylogid=1;  plotarea=1;
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam='mean DTE';   fignam=['DTE_',exptext,'_'];

%---set area
x1=1:150; y1=76:175;    x2=151:300; y2=176:275;  
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'all';'Mon';'Fla'};
linestyl={'--',':'};   markersty={'none','none'};  
%
nexp=size(expri1,1);
nminu=length(minu);  ntime=lenh*nminu;
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
%%
%---------------------------------------------------
DTE_dm=zeros(nexp,ntime); if plotarea~=0; DTE_am=zeros(nexp,ntime,narea); end
for ei=1:nexp
  DTE=cal_DTE_twin(indir,expri1{ei},expri2{ei},ymd,sth,lenh,minu,ccc); 
  for ti=1:ntime
    DTE_dm(ei,ti) = mean(mean(mean(DTE{ti})));
    if plotarea~=0
    for ai=1:narea
      DTE_am(ei,ti,ai)=mean(mean(mean(  DTE{ti}(xarea(ai,:),yarea(ai,:),:) )));
    end
    end
  end  
  disp([expri1{ei},' done'])
end
%%
%---
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
%----
%%
%---plot
hf=figure('position',[100 45 1000 600]);
for ei=1:nexp
  plot(DTE_dm(ei,:),'LineWidth',2.5,'color',col(ei,:)); hold on
  if plotarea~=0
  for ai=1:narea
    plot(DTE_am(ei,:,ai),'LineWidth',2.2,'color',col(ei,:),'linestyle',linestyl{ai},...
           'marker',markersty{ai},'MarkerSize',5,'MarkerFaceColor',col(ei,:));
  end
  end
end
legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','se');
%
%---
set(gca,'Linewidth',1.2,'fontsize',16)
if ylogid~=0; set(gca,'YScale','log'); end
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Time(JST)'); ylabel('area mean DTE')  
title(titnam,'fontsize',18)

%---
if plotarea~=0
  outfile=[outdir,'/',fignam,ymd(5:8),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min_',num2str(narea),'area'];
else
  outfile=[outdir,'/',fignam,ymd(5:8),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min'];
end
if ylogid~=0; outfile=[outfile,'_log']; end
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

