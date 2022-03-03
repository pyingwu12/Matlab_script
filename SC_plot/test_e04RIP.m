figure(2);clf
lwd=[2,1,1,1,1,1,1];
subplot(2,2,1);hold on
cases=[1,3:run-1];
for i=cases
    plot(ews(i,:),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
end
xlabel('Analysis cycles','fontsize',14)
ylabel('RMS error in KE (m^{2}/s^{2})','fontsize',14)
axis([1 9 45 180])
dx=8;
dy=180-45;
text(1+0.015*dx,180-0.05*dy,'(a)','horizontalalignment','left','fontsize',14)
set(gca,'box','on','fontsize',14,'Xtick',[1:9])
subplot(2,2,2);hold on
for i=cases
    plot(ewsu(i,:),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
end
xlabel('Analysis cycles','fontsize',14)
ylabel('RMS error in KE (m^{2}/s^{2})','fontsize',14)
set(gca,'box','on','fontsize',14,'Xtick',[1:9])
axis([1 9 70 140])
dx=8;
dy=70;
text(1+0.015*dx,140-0.05*dy,'(b)','horizontalalignment','left','fontsize',14)
%figure(3);clf
cases=[1,2:run-1];
subplot(2,2,3);hold on
for i=cases
    %plot(mean(ewsz(i,1:20,5:1:6),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
    plot(mean(ewsz(i,1:20,2:1:8),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); hold on
end
axis([57.5 150 0.2 1])
%set(gca,'Ydir','reverse','fontsize',14,'xtick',[20:20:200],'box','on')
%%eval(['print -dpsc -f2 ',pfile])
%subplot(2,2,3);hold on
%for i=cases
%    %plot(mean(ewsz(i,1:20,5:1:6),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
%    plot(mean(ewsz(i,1:20,2:2:8),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); hold on
%end
hleg=legend(legs(cases))
%legend(legs(cases),'location','NorthWest')
legend('boxoff')
set(hleg,'position',[0.55 0.3 0.2 0.15])
ylabel('Sigma','fontsize',14)
xlabel('RMS error in KE (m^{2}/s^{2})','fontsize',14)
%axis([20 105 0.5 1])
axis([57.5 150 0.2 1])
dx=150-57.5;
dy=1-0.2;
text(57.5+0.015*dx,0.2+0.05*dy,'(c)','horizontalalignment','left','fontsize',14)
set(gca,'Ydir','reverse','fontsize',14,'xtick',[20:20:200],'box','on')
set(gcf,'Paperorientation','portrait','paperposition',[0.125 0.5 8.25 9.5])
pfile='rmserrbox_E28_2e04RIPBDF.ps'
