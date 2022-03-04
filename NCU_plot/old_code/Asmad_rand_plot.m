
clear
hr=0;  minu='00'; 

%---set---
outdir=['/SAS011/pwin/201work/plot_cal/largens/largens'];
addpath('/SAS011/pwin/201work/plot_cal')

%----
varinam=['ABSerr random 40mem'];    filenam=['Corr-smad2_'];
%
 s_sub='12'; randtimes=20+1;
%-----------------
point='A';
load(['smad',s_sub,'_',point,'.mat']); %err(8,21)
stdA=std(err,0,1);
meanA=mean(err,1);

stdA2(1)=stdA(2); meanA2(1)=meanA(2);
stdA2(2)=stdA(6); meanA2(2)=meanA(6);
stdA2(3)=stdA(1); meanA2(3)=meanA(1);
stdA2(4)=stdA(5); meanA2(4)=meanA(5);
stdA2(5)=stdA(3); meanA2(5)=meanA(3);
stdA2(6)=stdA(7); meanA2(6)=meanA(7);
stdA2(7)=stdA(4); meanA2(7)=meanA(4);
stdA2(8)=stdA(8); meanA2(8)=meanA(8);

%-------------------------
point='B';
load(['smad',s_sub,'_',point,'.mat'])
stdB=std(err,0,1);
meanB=mean(err,1);

stdB2(1)=stdB(2); meanB2(1)=meanB(2);
stdB2(2)=stdB(6); meanB2(2)=meanB(6);
stdB2(3)=stdB(1); meanB2(3)=meanB(1);
stdB2(4)=stdB(5); meanB2(4)=meanB(5);
stdB2(5)=stdB(3); meanB2(5)=meanB(3);
stdB2(6)=stdB(7); meanB2(6)=meanB(7);
stdB2(7)=stdB(4); meanB2(7)=meanB(4);
stdB2(8)=stdB(8); meanB2(8)=meanB(8);

%
%-----------------
%
figure('position',[100 100 1000 500])

errorbar(1:8,meanA2,stdA2,'k','LineWidth',2,'LineStyle','none'); hold on 
plot(1:8,meanA2,'ko','MarkerSize',5,'MarkerFaceColor','k')
errorbar(1.2:8.2,meanB2,stdB2,'r','LineWidth',2,'LineStyle','none'); 
plot(1.2:8.2,meanB2,'ro','MarkerSize',5,'MarkerFaceColor','r')
%set(gca,'XTick',1:8,'Xticklabel',{'CORR(Vr,V)';'CORR(Vr,U)';'CORR(Vr,Qv)';'CORR(Vr,Qr)';'CORR(Zh,V)';'CORR(Zh,U)';'CORR(Zh,Qv)';'CORR(Zh,Qr)'})
set(gca,'XTick',1:8,'Xticklabel',{'CORR(Vr,U)';'CORR(Zh,U)';'CORR(Vr,V)';'CORR(Zh,V)';'CORR(Vr,Qv)';'CORR(Zh,Qv)';'CORR(Vr,Qr)';'CORR(Zh,Qr)'})

  %legend(label);  ylabel('SMAD','fontsize',13)
  %set(gca,'Xlim',[0 22],'Ylim',[0 0.9],'XTick',[1.5:1:20.5],'Xticklabel',[ ],'Ticklength',[0 0],'LineWidth',1,'fontsize',14)

   s_hr=num2str(hr,'%.2d');
   tit=['SMADs ',s_sub,'grid'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_sub',s_sub,'_curve'];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);
%}
