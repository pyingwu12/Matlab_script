figure(2);clf
subplot(1,2,1)
w=w3-w2;
w=w3;
%w(find(w<-5.0))=-5;
%w(find(w>5.0))=5;
col=jet(40);
%col(end,:)=[0.7,0.7,0.7];
%col(end-1,:)=[1,0,1];
col(1,:)=[0.7 0.7 0.7];
col(end,:)=[1 0 1];
%col(17:24,:)=[1 1 1;1 1 1;1 1 1;1 1 1;1 1 1;1 1 1;1 1 1; 1 1 1;];
col(19:22,:)=[1 1 1;1 1 1;1 1 1; 1 1 1;];
colormap(col);
%[c,h]=contourf(x,-1.e-2*z,w',[-5:10/20:5]);hold on
%caxis([-5 5])
[c,h]=contourf(x,-1.e-2*z,w',[-25:50/20:25]);hold on
caxis([-25 25])
set(h,'linestyle','none');
set(gca,'Ylim',[-1000 -100],'ytick',[-1000:100:-100],'Xlim',[-550 550],'xtick',[-500:250:500],'xminortick','on','yticklabel',{'1000','900','800','700','600','500','400','300','200','100'},'fontsize',10);
xlabel('Distance (km)','fontsize',12)
ylabel('Pressure (hPa)','fontsize',12)
text(.5,1.05,['(a) WS_{ITER2}-WS_{ITER1}'],'Units','normalized','HorizontalAlignment','center','fontweight','bold','Fontsize',12)
pos=get(gca,'position');
x1=pos(1)
set(gca,'Position',[pos(1) pos(2)+0.1*pos(4) pos(3) 0.8*pos(4)])
%hold on
%w=abs(w3-w1)-abs(w2-w1);
%[c,h]=contour(x,-1.e-2*z,w',[1:10/20:5]);hold on
%set(h,'edgecolor','k')
%[c,h]=contour(x,-1.e-2*z,w',[-5:10/20:1]);hold on
%set(h,'edgecolor','k','linestyle','-.')

subplot(1,2,2)
w=abs(w3-w1)-abs(w2-w1);
%w(find(w<-5))
w(find(w<-5))=-5.;
w(find(w>5))=5;
[c,h]=contourf(x,-1.e-2*z,w',[-5.:10/20:5]);hold on
caxis([-5. 5.])
set(gca,'Ylim',[-1000 -100],'ytick',[-1000:100:-100],'Xlim',[-550 550],'xtick',[-500:250:500],'xminortick','on','yticklabel',{'1000','900','800','700','600','500','400','300','200','100'},'fontsize',10);
set(h,'linestyle','none');
xlabel('Distance (km)','fontsize',12)
ylabel('Pressure (hPa)','fontsize',12)
pos=get(gca,'position');
set(gca,'Position',[pos(1) pos(2)+0.1*pos(4) pos(3) 0.8*pos(4)])
pos(2)=pos(2)+0.1*pos(4);
pos(4)=pos(4)*0.8;
dx=pos(1)+pos(3)-x1;
hbar=colorbar('horizontal');
set(hbar,'Position',[x1 pos(2)-0.15*pos(4) dx 0.025],'xtick',[-5:0.5:5])
set(gca,'position',pos);
text(.5,1.05,['(b) ABS(ERR_{ITER2})-ABS(ERR_{ITER1})'],'Units','normalized','HorizontalAlignment','center','fontweight','bold','Fontsize',12)
set(gcf,'PaperOrientation','landscape','PaperPosition',[0.25 1.5 10.5 5.])
