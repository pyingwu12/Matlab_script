figure(2);clf
%cc={'k';'r';'b';'k';'g';'m'};
cc={'k';'k';'r';'k';'g';'m'};
lwd=[2.,2.,2,2,1,1,1];
ln={'-';'--';'-';'-';'-';'-'}
legs={'LETKF';'LETKF-RIP';'';'LETKF-RIP'}
subplot(2,2,1);hold on
%cases=[1,3:run-1];
cases=[1:3];
for i=cases
    plot(ews(i,:),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
end
%xlabel('Time','fontsize',14)
ylabel('RMS error in KE (m^{2}/s^{2})','fontsize',14,'Fontweight','bold')
axis([1 9 30 160])
%axis([1 9 30 320])
dx=9;
dy=160-30;
%text(1+0.015*dx,30+0.05*dy,'(a)','horizontalalignment','left','fontsize',16)
set(gca,'box','on','fontsize',14,'Xtick',[1:9],'Xticklabel',{'06';'12';'18';'00';'06';'12';'18';'00';'06'})
text(1,30-0.11*dy,'14','horizontalalignment','center','fontsize',14)
text(4,30-0.11*dy,'15','horizontalalignment','center','fontsize',14)
text(8,30-0.11*dy,'16','horizontalalignment','center','fontsize',14)
text(4.5,30-0.18*dy,'Time','horizontalalignment','center','fontsize',14,'Fontweight','bold')
title('(a) RMS error at low levels','Fontweight','bold')
hleg=legend(legs(cases),'location','NorthWest','fontsize',12)
legend('boxoff')
subplot(2,2,2);hold on
for i=cases
    plot(ewsu(i,:),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
end
%xlabel('Analysis cycles','fontsize',14)
ylabel('RMS error in KE (m^{2}/s^{2})','fontsize',14,'Fontweight','bold')
set(gca,'box','on','fontsize',14,'Xtick',[1:9],'Xticklabel',{'06';'12';'18';'00';'06';'12';'18';'00';'06'})
text(1,30-0.11*dy,'14','horizontalalignment','center','fontsize',14)
text(4,30-0.11*dy,'15','horizontalalignment','center','fontsize',14)
text(8,30-0.11*dy,'16','horizontalalignment','center','fontsize',14)
text(4.5,30-0.18*dy,'Time','horizontalalignment','center','fontsize',14,'Fontweight','bold')
title('(b) RMS error at upper levels','Fontweight','bold')
axis([1 9 30 160])
%axis([1 9 30 320])
hleg=legend(legs(cases),'location','NorthWest','fontsize',12)
legend('boxoff')
dx=8;
dy=130;
%text(1+0.015*dx,30+0.05*dy,'(b)','horizontalalignment','left','fontsize',16)
%figure(3);clf
%cases=[1,2:run-1];
set(gcf,'Paperorientation','portrait','paperposition',[0.125 0.25 5.25 10.5])
%figure(3);clf
subplot(2,2,3);hold on
for i=cases
    %plot(mean(ewsz(i,1:20,5:1:6),3),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i}); 
    plot(mean(ewsz(i,1:26,1:1:8),3),eta(1:26),cc{i},'linewidth',lwd(i),'linestyle',ln{i},'linewidth',2.); hold on
end
legend(legs(cases),'location','NorthEast','fontsize',12)
legend('boxoff')
%set(hleg,'position',[0.55 0.3 0.2 0.15])
ylabel('Sigma','fontsize',14,'Fontweight','bold')
xlabel('RMS error in KE (m^{2}/s^{2})','fontsize',14,'Fontweight','bold')
title('(c) RMS error in vertical','Fontweight','bold','fontsize',14)
%axis([35 110 0.1 1])
%dx=110-35;
axis([50 120 0.1 1])
%axis([50 200 0.1 1])
dx=120-50;
dy=1-0.1;
%text(50+0.015*dx,1.-0.05*dy,'(b)','horizontalalignment','left','fontsize',16)
set(gca,'Ydir','reverse','fontsize',14,'xtick',[20:20:200],'box','on')
set(gcf,'Paperorientation','portrait','paperposition',[0.25 0.25 8. 9])
%set(gcf,'Paperorientation','portrait','paperposition',[0.125 0.25 5.25 10.5])
%pfile='rmserrbox_E28_2AMS2011.ps'
figure(5)
dx=0.3;
dy=0.3;
hh=hh0;
dd=dd0;
for it=1:8
   subplot(3,3,it)
   for i=cases
       plot(squeeze(ewsz(i,1:20,it)),eta(1:20),cc{i},'linewidth',lwd(i),'linestyle',ln{i},'linewidth',2.); hold on
   end
   ylabel('Sigma','fontsize',12)
   xlabel('RMS error in KE (m^{2}/s^{2})','fontsize',12)
   axis([50 150 0.1 1])
   dx=170-30;
   dy=1-0.1;
   
   tag=['Time:09/',num2str(dd,'%2.2d'),' ',num2str(hh,'%2.2d'),'Z'];
   text(167.5,0.1+0.04*dy,tag,'horizontalalignment','right','verticalalignment','top','fontsize',10)
   set(gca,'Ydir','reverse','fontsize',14,'xtick',[20:20:200],'box','on','fontsize',12)

   if(it==3)
      hleg=legend('LETKF','LETKF-RIP');
      set(hleg,'position',[0.14 .95 0.2 0.01])
      legend('boxoff') 
   end

   hh=hh+6;
   if(hh>=24)
      dd=dd+1;
      hh=hh-24
   end
end
set(gcf,'Paperorientation','landscape','paperposition',[0.25 0.15 10.5 8.2])
