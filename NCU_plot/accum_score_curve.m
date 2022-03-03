
clear all
close all

 % !!! notice: remember to modify the date in function <aaccum_score_sing>

outdir='/SAS011/pwin/201work/plot_cal/largens/';   araid=4;
%---
%exp={'noda';'shao';'vrzhall3'};   
%cexp=[0.2 0.2 0.2; 0 0 1; 1 0 0; 0.1 0.8 0.2];  lexp={'-';'-';'-';'-'};
%cexp=[0.2 0.2 0.2; 0 0 1; 1 0 0];  lexp={'-';'-';'-'};
%exp={'noda';'2HR';'2HRall3'};   
%exp={'szvrzh124';'szvrzh364';'szvrzh364lsr'};  exptext='_lsr';  lexp={'-';'-';'--'}; 

%exp={'e11';'e10';'e01';'e02';'e04';'e07';'e08';'e09'};   exptext='_all';
%lexp={'-';'--';'-';'--';'-';'--';'-';'--'};
%cexp=[0.5 0.5 0.6; 0.7 0.7 0.8; 0.75 0.1 0.2; 1 0.6 0.2; 0.1 0.6 0.1; 0.3 0.85 0.4; 0.1 0.2 0.8; 0.3 0.7 0.9];
%expnam={'L1204';'S1204';'L3604';'S3604';'L3612';'S3612';'L10804';'S10804'};

%exp={'e11';'e10';'e01';'e02';'e38'};   exptext='_e38';
%lexp={'-';'--';'-';'--';'--'};
%cexp=[0.5 0.5 0.6; 0.7 0.7 0.8; 0.75 0.1 0.2; 1 0.6 0.2; 0.6 0.2 1];
%expnam={'L1204';'S1204';'L3604';'S3604';'LimVr'};

expi={'e11';'e10';'e01';'e02';'e04';'e07'};   exptext='_paper';                %!!!remember to change the lengend below
lexp={'-';'--';'-';'--';'-';'--'};
cexp=[ 0.3 0.3 0.4; 0.7 0.7 0.8;  0.75 0.1 0.2;  1 0.6 0.2; 0.1 0.6 0.1; 0.3 0.85 0.4];
expnam={'L1204';'S1204';'L3604';'S3604';'L3612';'S3612'};

%exp={'e10';'e47';'e46';'e41';'e42';'e45';'e02'};   exptext='_hrls';     
%lexp={'-';'-';'-';'-';'-';'-';'-';'-'};
%cexp=[0.48 0.17 0.55; 0.01 0.44 0.74; 0.28 0.73 0.93; 0.47 0.68 0.2 ; 0.93 0.68 0.09; 0.85 0.31 0.08; 0.63 0.05 0.25];
%expnam={'S1204';'S1604';'S2004';'S2404';'S2804';'S3204';'S3604'};

nexp=size(expi,1);
%%
%{
%=======1-hr scores===========================
sth=2:6;   tresh=10;
acch=1;
nt=length(sth);  s_sth=num2str(sth(1),'%2.2d'); s_edh=num2str(sth(nt)+1,'%2.2d'); 
%
scc=zeros(nexp,nt); rmse=zeros(nexp,nt); ETS=zeros(nexp,nt); bias=zeros(nexp,nt); 
for i=1:nexp
%[scc(i,:) rmse(i,:) ETS(i,:) bias(i,:)]=accum_score_sing(sth,acch,expi{i},araid,tresh); 
[scc(i,:) rmse(i,:) ETS(i,:) bias(i,:)]=accum_score_sp(sth,acch,expi{i},araid,tresh); 
end

%---plot-------
nam={'SCC';'RMSE';'ETS';'Bias'};
for k=[1 2 ]                             %<===
  switch (k); case 1; varinam=scc;  case 2; varinam=rmse; case 3; varinam=ETS;  case 4; varinam=bias;  end    
  figure('position',[100 100 880 490]) 
  for i=1:nexp
   plot(sth+0.5,varinam(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.5); hold on
  end
  if k==4;  line([sth(1) sth(nt)+1],[1 1],'color','k','LineWidth',1.3); end
  %
  set(gca,'XLim',[sth(1) sth(nt)+1],'XTick',[sth sth(nt)+1],'XTickLabel',[sth sth(nt)+1],'fontsize',13,'LineWidth',1)
  xlabel('Time','fontsize',14);   ylabel(nam{k},'fontsize',14);
  legend(expnam,'Location','BestOutside');
  %
  tit=[s_sth,'z-',s_edh,'z 1-hr accumulation rainfall ',nam{k},' (area',num2str(araid),')'];  title(tit,'fontsize',15)
  outfile=[outdir,nam{k},'_',s_sth,s_edh,'_hourly',exptext,'_area',num2str(araid)];
  if k==3 || k==4
  tit=[s_sth,'z-',s_edh,'z 1-hr accumulation rainfall ',nam{k},' thr.=',num2str(tresh),' (area',num2str(araid),')'];  title(tit,'fontsize',15)
  outfile=[outfile,'_tr',num2str(tresh)];
  end
  %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
  %system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']); 
  %system(['rm ',[outfile,'.pdf']]);
end
%%
%}
%{
%clear 
%=======1-6 hr scores=======================
sth=2;   acch=1:5;    tresh=40;  
nt=length(acch);  s_sth=num2str(sth,'%2.2d'); s_edh=num2str(sth+acch(nt),'%2.2d'); 
%
scc=zeros(nexp,nt); rmse=zeros(nexp,nt); ETS=zeros(nexp,nt); bias=zeros(nexp,nt); 
for i=1:nexp
[scc(i,:) rmse(i,:) ETS(i,:) bias(i,:)]=accum_score_sp(sth,acch,expi{i},araid,tresh); 
end
%---plot------
nam={'SCC';'RMSE';'ETS';'Bias'};
for k=[1 2]                          % <===
  switch (k); case 1; vari=scc;  case 2; vari=rmse; case 3; vari=ETS;  case 4; vari=bias;  end    
  figure('position',[100 100 880 490]) 
  for i=1:nexp
   plot(1:nt,vari(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.5); hold on
  end
  set(gca,'XLim',[0.5 nt+0.5],'XTick',1:nt,'XTickLabel',['1hr';'2hr';'3hr';'4hr';'5hr';'6hr'],'fontsize',13,'LineWidth',1)
%  set(gca,'YLim',[0 4.8])
  xlabel('Accumulating time','fontsize',14);   ylabel(nam{k},'fontsize',14);
  legend(expnam,'Location','BestOutside');
  tit=[s_sth,'z-',s_edh,'z 1~6hr accumulation rainfall ',nam{k},' (area',num2str(araid),')'];  title(tit,'fontsize',15)
  outfile=[outdir,nam{k},'_',s_sth,s_edh,'_accum',exptext,'_area',num2str(araid)];
  if k==3 || k==4
  tit=[s_sth,'z-',s_edh,'z 1~6hr accumulation rainfall ',nam{k},' thr.=',num2str(tresh),' (area',num2str(araid),')'];  title(tit,'fontsize',15)
  outfile=[outfile,'_tr',num2str(tresh)];
  end
  set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
  system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']); 
  system(['rm ',[outfile,'.pdf']]);
end
%%
%}
%
% =======ETS / bias===================
%clear

%tresh=5:5:30;
%tresh=30:15:105;
%tresh=5:15:80;
tresh=5:10:95;
%tresh=[5 10 20 30 50 70 100 130 160 190 220 260 300];
sth=2;  acch=5;   s_sth=num2str(sth,'%2.2d'); s_edh=num2str(sth+acch,'%2.2d'); 
nt=length(tresh);   
%
scc=zeros(nexp,nt); rmse=zeros(nexp,nt); ETS=zeros(nexp,nt); bias=zeros(nexp,nt); 
for i=1:nexp
[scc(i,:) rmse(i,:) ETS(i,:) bias(i,:)]=accum_score_sp(sth,acch,expi{i},araid,tresh);  %!!!! for time shift
end
plotvar=bias; s_plot='Bias';   %---plot variable
%---
figure('position',[100 200 850 500]) 
for i=1:nexp
plot(1:nt,plotvar(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.8); hold on
end
if strcmp(s_plot,'Bias')==1; 
line([1 nt],[1 1],'color','k','linewidth',1.2,'LineStyle','-.')
end
set(gca,'XLim',[1 nt],'YLim',[0 6],'XTick',1:nt,'XTickLabel',tresh,'fontsize',14,'LineWidth',1)
%set(gca,'XLim',[1 nt],'YLim',[0 4.8],'XTick',1:nt,'XTickLabel',tresh,'fontsize',14,'LineWidth',1)
%set(gca,'XLim',[1 nt],'XTick',1:nt,'XTickLabel',tresh,'fontsize',14,'LineWidth',1)
xlabel('Threshold (mm)','fontsize',15);   ylabel(s_plot,'fontsize',15);
%hl=legend(expnam,'Location','BestOutside');
hl=legend(expnam,'Location','Northwest');
set(hl,'fontsize',15,'box','off');
%tit=[s_sth,'z-',s_edh,'z accumulation rainfall ',s_plot,' (area',num2str(araid),')'];  
tit=[s_sth,'00UTC-',s_edh,'00UTC  Accumulated rainfall ',s_plot];  
title(tit,'fontsize',17)
outfile=[outdir,s_plot,'_',s_sth,s_edh,exptext,'_area',num2str(araid)];
 set(gcf,'PaperPositionMode','auto');  set(gcf,'PaperOrientation','landscape');
print('-dpdf',[outfile,'.pdf']) 
 system(['convert -trim -density 600 ',outfile,'.pdf ',outfile,'.png']); 
 system(['rm ',[outfile,'.pdf']]);
%}
