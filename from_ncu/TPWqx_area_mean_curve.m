%-------------------------------------
% plot the curve of the qx's area mean calculate by <TPWqx_cal_area_mean>
%-------------------------------------

clear all
close all

vari='QVAPOR';
lonA=119; latA=21; asize=100; %model igrid points, asize=100 => 3km*100=300km

%cexp=[ 0.3 0.3 0.3; 0.7 0.7 0.8;  0.75 0.1 0.2;  1 0.6 0.2; 0.1 0.2 0.8; 0.3 0.7 0.9]; 
%expi={'e11';'e10';'e01';'e02';'e04';'e07'};   exptext='_paper';  %!!!remember to change the lengend below
%lexp={'-';'--';'-';'--';'-';'--'};
%expnam={'L1204';'S1204';'L3604';'S3604';'L3612';'S3612'};

cexp=[ 0.3 0.3 0.3; 0.7 0.7 0.8;  0.75 0.1 0.2;  1 0.6 0.2; 0.1 0.6 0.1; 0.3 0.85 0.4];
expi={'e11';'e10';'e01';'e02';'e04';'e07'};   exptext='_paper';
lexp={'-';'--';'-';'--';'-';'--'};
expnam={'L1204';'S1204';'L3604';'S3604';'L3612';'S3612'};


%expi={'e01';'e10';'e41';'e02'};     exptext='_hlocs';
%lexp={'--';'-';'-';'-'};
%cexp=[0.75 0.1 0.2; 0.3 0.3 0.3; 0.28 0.73 0.93; 1 0.6 0.2];
%expnam={'L3604';'S1204';'S2404';'S3604'};

%expi={'e01';'e10';'e47';'e46';'e41';'e42';'e45';'e02'};     exptext='_hlocs';
%lexp={'--';'-';'-';'-';'-';'-';'-';'-';'-'};
%cexp=[0.75 0.1 0.2; 0.48 0.17 0.55; 0.01 0.44 0.74; 0.28 0.73 0.93; 0.47 0.68 0.2 ; 0.93 0.68 0.09; 0.85 0.31 0.08; 0.63 0.05 0.25];
%expnam={'L3604';'S1204';'S1604';'S2004';'S2404';'S2804';'S3204';'S3604'};


%
%hm=['00:00';'00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00'];
hm=['00:00';'00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00';'03:00';'04:00';'05:00';'06:00';'07:00'];
x=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 11 12 13 14];
%x=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9];
outdir='/SAS011/pwin/201work/plot_cal/largens/';

%---experimental setting---
dom='02'; day='20080616';    % time setting
%---
num=size(hm,1);  nexp=size(expi,1);
s_vari=lower(vari(1:2));
varinam=['Total-',s_vari,' area mean'];   filenam=['TPW-',s_vari,'areamean_'];  

%-----
for i=1:nexp    
   qa_mean{i}=TPWqx_cal_area_mean(expi{i},hm,vari,lonA,latA,asize);
end

%%
%x(1:2:num*2-1)=1:num;  x(2:2:num*2)=1:num;
%---plot---
figure('position',[150 300 800 400])
for i=1:nexp
hp(i)=plot(x,qa_mean{i},'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.3);  hold on
end
%
set(gca,'XLim',[0 num+1],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
%set(gca,'XLim',[0 num+1],'YLim',[-0.5 2.7],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
xlabel('Time','fontsize',14);   ylabel('kg/m^2','fontsize',14);
legh=legend(hp,expnam,'Location','Best'); 
set(legh,'fontsize',13)
%
 tit=[varinam,'  ',hm(1,1:2),'z-',hm(num,1:2),'z '];
 title(tit,'fontsize',15)
 outfile=[outdir,filenam,hm(1,1:2),hm(num,1:2),exptext];
 set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
 system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
 system(['rm ',[outfile,'.pdf']]);
 
 
