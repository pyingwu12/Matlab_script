%-----------------------------------
% Plot Zh improvement after DA
%-----------------------------------
%{
clear all
close all

vari='QVAPOR';
hm=['00:00';'00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00'];

expi={'e10';'e41';'e02';'e01'};     exptext='_hlocs';   
lexp={'-';'-';'-';'-'};
cexp=[0.3 0.3 0.3; 0.28 0.73 0.93; 1 0.6 0.2; 0.75 0.1 0.2;];
expnam={'S1204';'S2404';'S3604';'L3604'};
%
%---experimental setting---
dom='02'; day='20080616';    % time setting
outdir='/SAS011/pwin/201work/plot_cal/largens/';
s_vari=lower(vari(1:2));
varinam=['Sum of total-',s_vari,' increment'];  filenam=['TPW-',s_vari,'-incr-curve_'];
%
num=size(hm,1);  nexp=size(expi,1);
%
%-----
for i=1:nexp 
   incr(i,:)=TPWqx_incr_mean(hm,expi{i},vari,dom,day);
   disp([expi{i},' done'])
end
%}
x=1:num; 
%---plot---
figure('position',[150 300 800 400])
for i=1:nexp
hp(i)=plot(x,incr(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.3);  hold on
end

line([1 num],[0 0],'color','k','linewidth',1.2,'LineStyle','--')

%
set(gca,'XLim',[1 num],'XTick',x,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
xlabel('Time (UTC)','fontsize',14);   ylabel('Kg*m^-^2','fontsize',14);
legh=legend(hp,expnam,'Location','BestOutside'); 
set(legh,'fontsize',13)
% 
 tit=[varinam,'  ',hm(1,1:2),'z-',hm(num,1:2),'z '];
 %tit=[varinam];
 title(tit,'fontsize',15)
 outfile=[outdir,filenam,hm(1,1:2),hm(num,1:2),exptext];
 set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
 system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
 system(['rm ',[outfile,'.pdf']]);
%}
 
