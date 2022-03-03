%-------------------------------------------------------
% plot the time series of the total Qr spread 
%-------------------------------------------------------
clear

hr=18:30;   minu='00';   expri='largens';  memsize=256; 

%---experimental setting---
year='2008'; mon='06'; date=15;
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%
varinam='total qr spread';    filenam=[expri,'_TPWqr-sprdt_'];  
%---

sprd=TPWqr_sprd_mean(hr,minu,year,mon,date,expri,memsize);
%%
%---plot---------------
nti=0;
for ti=hr;
    nti=nti+1;  
    hrday=fix(ti/24);    
    s_hr{nti}=num2str(ti-24*hrday,'%2.2d');   
end

figure('position',[100 500 800 500]) 

plot(hr,sprd,'color','k','LineWidth',2.2); hold on

set(gca,'XTick',hr,'XTickLabel',s_hr,'fontsize',13,'LineWidth',1)

xlabel('Time (UTC)','fontsize',14);   ylabel('spread','fontsize',14);
title([year,mon,num2str(date,'%.2d'),'  ',s_hr{1},'z-',s_hr{end},'z  ',...
         varinam,'  (mem',num2str(memsize),')'],'fontsize',15)
outfile=[outdir,'/',filenam,s_hr{1},s_hr{end},'z_m',num2str(memsize)];

set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
system(['rm ',[outfile,'.pdf']]);