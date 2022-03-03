%-----------------------------------
% Plot Zh improvement after DA
%-----------------------------------
%
clear

%cexp=[ 0.75 0.1 0.2;  1 0.6 0.2  ]; 
%exp={'e01';'e02'};   exptext='_3604';  
%lexp={'-';'--'};
%expnam={'L1204';'S1204'};

%cexp=[ 0.3 0.3 0.3; 0.7 0.7 0.8;  0.75 0.1 0.2;  1 0.6 0.2; 0.1 0.6 0.1; 0.3 0.85 0.4]; 
%exp={'e11';'e10';'e01';'e02';'e04';'e07'};   exptext='_paper'; 
%lexp={'-';'--';'-';'--';'-';'--'};
%expnam={'L1204';'S1204';'L3604';'S3604';'L3612';'S3612'};

%cexp=[ 0.3 0.3 0.3; 0.7 0.7 0.8;  0.75 0.1 0.2;  1 0.6 0.2; 0.1 0.2 0.8; 0.3 0.7 0.9; 0.1 0.6 0.1; 0.3 0.85 0.4;];
%exp={'e11';'e10';'e01';'e02';'e08';'e09';'e04';'e07'};   exptext='_ISDA';
%lexp={'-';'--';'-';'--';'-';'--';'-';'--'};
%expnam={'L1204';'S1204';'L3604';'S3604';'L10804';'S10804';'L3612';'S3612'};

%cexp=[ 0.3 0.3 0.3; 0.7 0.7 0.8;  0.75 0.1 0.2;  1 0.6 0.2; 0.1 0.2 0.8; 0.3 0.7 0.9];
%exp={'e11';'e10';'e01';'e02';'e08';'e09'};   exptext='_hloc';
%lexp={'-';'--';'-';'--';'-';'--'};
%expnam={'L1204';'S1204';'L3604';'S3604';'L10804';'S10804';};

%exp={'e10';'e47';'e46';'e41';'e42';'e45';'e02'};     exptext='_hlocs';   
%lexp={'-';'-';'-';'-';'-';'-';'-';'-'};
%cexp=[0.48 0.17 0.55; 0.01 0.44 0.74; 0.28 0.73 0.93; 0.47 0.68 0.2 ; 0.93 0.68 0.09; 0.85 0.31 0.08; 0.63 0.05 0.25];
%expnam={'S1204';'S1604';'S2004';'S2404';'S2804';'S3204';'S3604'};

expi={'e10';'e46';'e42';'e02'};     exptext='_hlocs2';
lexp={'-';'-';'-';'-';'-';'-';'-';'-'};
cexp=[0.48 0.17 0.55; 0.28 0.73 0.93; 0.93 0.68 0.09; 0.63 0.05 0.25];
expnam={'S1204';'S2004';'S2804';'S3604'};


%
hm=['00:00';'00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00'];

%---experimental setting---
dom='02'; day='20080616';    % time setting
%obsdir='obs_morakot'; expdir='morakot_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/IOP8_morakot/';
%obsdir='obs_201206'; expdir='what_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/what/';
%obsdir='obs_sz6414'; expdir='sz_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/IOP8/';
obsdir='obs_sz6414_QC'; expdir='largens_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/largens/';
%---
num=size(hm,1);  nexp=size(expi,1);
varinam='Zh RMSI';   filenam='zh-rmsi_';  
%varinam='Zh mean inno.';   filenam='zh-meaninno_';  
%
%-----
for i=1:nexp 
   expri=[expdir,expi{i}];
   [inno{i}]=zh_cal_rmsi(expri,hm,day,dom,obsdir);
end
%%
x(1:2:num*2-1)=1:num;  x(2:2:num*2)=1:num;
%}
%---plot---
figure('position',[150 500 800 400])
for i=1:nexp
hp(i)=plot(x,inno{i}.rmsi,'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.3);  hold on
%plot(x,inno{i}.mean,'color',cexp(i,:),'Linestyle','--','LineWidth',2.3); hold on
end
%for i=1:nexp; plot(x(end),inno{i}.mean(end),'x','color',cexp(i,:),'LineWidth',2,'Markersize',17); end
%
set(gca,'XLim',[0 num+1],'YLim',[3.5 9.5],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
%set(gca,'XLim',[0 num+1],'YLim',[-7.5 12],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
xlabel('Time (UTC)','fontsize',14);   ylabel('dBZ','fontsize',14);
legh=legend(hp,expnam,'Location','BestOutside'); 
set(legh,'fontsize',13)
% 
 %tit=[varinam,'  ',hm(1,1:2),'z-',hm(num,1:2),'z '];
 tit=[varinam];
 title(tit,'fontsize',15)
 outfile=[outdir,filenam,hm(1,1:2),hm(num,1:2),exptext];
 set(gcf,'PaperPositionMode','auto');  set(gcf,'PaperOrientation','landscape');
 print('-dpdf',[outfile,'.pdf'])
 system(['convert -trim -density 600 ',outfile,'.pdf ',outfile,'.png']);
 system(['rm ',[outfile,'.pdf']]);

 
