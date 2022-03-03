figure(1);clf
hh0=6;
dd0=14;
subplot(2,1,1);hold on
nt=size(slpc,2);
[ax,h1,h2]=plotyy([1:nt],squeeze(slpc(1,:)),[1:nt],squeeze(maxws(1,:)));
set(ax(2),'ycolor','k','linewidth',2.0,'Xlim',[1 nt],'Xtick',[1:nt],'Ylim',[30 80],'Ytick',[30:10:80],'Xticklabel',{'06','12','18','00','06','12','18','00','06','12','18','00','06','12'},'fontsize',12);
set(ax(1),'ycolor','k','linewidth',2.0,'Xlim',[1 nt],'Ylim',[935 995],'Ytick',[935:12:995],'Xticklabel','');
set(h1,'color','k','linewidth',2.0);
set(h2,'color','k','linestyle','--','linewidth',2.0);
yrange=get(ax(1),'Ylim');
ax1_y=get(ax(1),'Ylabel');
ax2_y=get(ax(2),'Ylabel');
ax1_x=get(ax(1),'xlabel');
set(ax1_y,'Color',[0 0 0],'string','Center pressure (hpa)','fontsize',14)
set(ax2_y,'Color',[0 0 0],'string','Max windspeed (m/s)','fontsize',14)
title('Typhoon intensity','Fontsize',16)
plot([4 4],[935 995],':k')
plot([6 6],[935 995],':k')
%set(ax1_x,'string','Time','fontsize',14)
hh=hh0; dd=dd0;
for it=1:nt
    if(hh>=24)
       hh=hh-24;dd=dd+1;
       text(it,yrange(1)-0.07*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
    end
    xt{it}=num2str(hh,'%2.2d');
    day{it}=num2str(dd,'%2.2d');
    if(it==1);text(it,yrange(1)-0.07*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);end
    hh=hh+6;
end
text(0.5*(1+nt),yrange(1)-0.13*(yrange(2)-yrange(1)),'Time','HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
text(2,(yrange(1)+(yrange(2)-yrange(1))*0.1),'(a)','fontsize',16,'fontweight','bold','horizontalalignment','center')
subplot(2,1,2);hold on
nt=size(slpc,2);
plot([1.5:nt],slpc(1,2:end)-slpc(1,1:end-1),'k','linewidth',2.0);;hold on
yrange=get(gca,'Ylim');
set(gca,'Xlim',[1 nt],'xtick',[1:nt],'Xticklabel',{'06','12','18','00','06','12','18','00','06','12','18','00','06','12'});
%set(gca,'Xlim',[1 nt],'xtick',[0.5:nt-0.5],'Xticklabel',{'03','09','15','21','03','09','15','21','03','09','15','21','03','09','15'});
hh=hh0; dd=dd0;
for it=1:nt
    if(hh>=24)
       hh=hh-24;dd=dd+1;
       text(it,yrange(1)-0.07*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
    end
    xt{it}=num2str(hh,'%2.2d');
    day{it}=num2str(dd,'%2.2d');
    if(it==1);text(it,yrange(1)-0.07*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);end
    hh=hh+6;
end
set(gca,'box','on','linewidth',2,'fontsize',12)
text(2,(-15+25*0.1),'(b)','fontsize',16,'fontweight','bold','horizontalalignment','center')
ylabel('Pressure tendency ,dp/dt (hpa/hr)','fontsize',14)
plot([4 4],[yrange],':k')
plot([6 6],[yrange],':k')
text(0.5*(1+nt),yrange(1)-0.13*(yrange(2)-yrange(1)),'Time','HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
title('Intensity tendency','Fontsize',16)
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 8 10])

%text(4.5,yrange(1)+1.075*(yrange(2)-yrange(1)),[num2str(t_fcst),'-HR Forecast'],'verticalalignment','top','Fontsize',16,'horizontalalignment','center')
