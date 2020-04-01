
clear

load('qa_mean.mat')

vari='QVAPOR';
% expi={'e01';'e10';'e41';'e02'};     exptext='_hlocs';
% lexp={'--';'-';'-';'-'};
% cexp=[0.75 0.1 0.2; 0.3 0.3 0.3; 0.28 0.73 0.93; 1 0.6 0.2];
% expnam={'L3604';'S1204';'S2404';'S3604'};

expi={'e01';'e10';'e47';'e46';'e41';'e42';'e45';'e02'};     exptext='_hlocs';
lexp={'--';'-';'-';'-';'-';'-';'-';'-';'-'};
cexp=[0.75 0.1 0.2; 0.48 0.17 0.55; 0.01 0.44 0.74; 0.28 0.73 0.93; 0.47 0.68 0.2 ; 0.93 0.68 0.09; 0.85 0.31 0.08; 0.63 0.05 0.25];
expnam={'L3604';'S1204';'S1604';'S2004';'S2404';'S2804';'S3204';'S3604'};


hm=['00:00';'00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00';'03:00';'04:00';'05:00';'06:00';'07:00'];
x=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 11 12 13 14];

num=size(hm,1);  nexp=size(expi,1);
s_vari=lower(vari(1:2));
varinam=['Total-',s_vari,' area mean'];   filenam=['TPW-',s_vari,'areamean_'];
%

figure('position',[150 300 800 500])
for i=1:nexp
hp(i)=plot(x,qa_mean{i},'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.3);  hold on
end
%
set(gca,'XLim',[0 num+1],'YLim',[62.5 64.5],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
xtickangle(45)
%set(gca,'XLim',[0 num+1],'YLim',[-0.5 2.7],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
xlabel('Time','fontsize',14);   ylabel('kg/m^2','fontsize',14);
legh=legend(hp,expnam,'Location','Best','box','off'); 
set(legh,'fontsize',13)
%
 tit=[varinam,'  ',hm(1,1:2),'z-',hm(num,1:2),'z '];
 title(tit,'fontsize',15)
 outfile=[filenam,hm(1,1:2),hm(num,1:2),exptext];
 set(gcf,'PaperPositionMode','auto','PaperOrientation','landscape');   
 print('-dpdf',[outfile,'.pdf'])

