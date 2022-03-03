figure(2);clf
lwd=[2.5,2.5,1,1,1,1,1];
ln={'--';'-';'-';'-';'-';'-'}
subplot(2,1,1);hold on
%cases=[1,3:run-1];
cases=[1:run-1];
for i=cases
    plot(ews(i,:),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
end
xlabel('Analysis cycles','fontsize',14)
ylabel('RMS error in KE (m^{2}/s^{2})','fontsize',14)
axis([1 9 50 100])
dx=9;
dy=100-50;
text(1+0.015*dx,50+0.05*dy,'(a)','horizontalalignment','left','fontsize',16)
set(gca,'box','on','fontsize',14,'Xtick',[1:9])
hleg=legend(legs(cases),'location','NorthWest')
legend('boxoff')
%subplot(2,2,2);hold on
%for i=cases
%    plot(ewsu(i,:),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
%end
%xlabel('Analysis cycles','fontsize',14)
%ylabel('RMS error in KE (m^{2}/s^{2})','fontsize',14)
%set(gca,'box','on','fontsize',14,'Xtick',[1:9])
%axis([1 9 50 140])
%dx=8;
%dy=70;
%text(1+0.015*dx,140-0.05*dy,'(b)','horizontalalignment','left','fontsize',14)
%%figure(3);clf
%cases=[1,2:run-1];
subplot(2,1,2);hold on
for i=cases
    %plot(mean(ewsz(i,1:20,5:1:6),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
    plot(mean(ewsz(i,1:20,5:1:8),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i},'linewidth',2.5); hold on
end
%set(gca,'Ydir','reverse','fontsize',14,'xtick',[20:20:200],'box','on')
%%eval(['print -dpsc -f2 ',pfile])
%subplot(2,2,3);hold on
%for i=cases
%    %plot(mean(ewsz(i,1:20,5:1:6),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
%    plot(mean(ewsz(i,1:20,2:2:8),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); hold on
%end
hleg=legend(legs(cases),'location','NorthWest')
%legend(legs(cases),'location','NorthWest')
legend('boxoff')
%set(hleg,'position',[0.55 0.3 0.2 0.15])
ylabel('Sigma','fontsize',14)
xlabel('RMS error in KE (m^{2}/s^{2})','fontsize',14)
%axis([20 105 0.5 1])
axis([20 120 0.1 1])
dx=120-20;
dy=1-0.1;
text(20+0.015*dx,1.-0.05*dy,'(b)','horizontalalignment','left','fontsize',16)
set(gca,'Ydir','reverse','fontsize',14,'xtick',[20:20:200],'box','on')
set(gcf,'Paperorientation','portrait','paperposition',[0.125 0.25 5.25 10.5])
pfile='rmserrbox_E28_2AMS2011.ps'
