figure(2);
plot(slpc(1,1:16),'color',[0.7 0.7 0.7],'linewidth',3.0);;hold on
plot(slpc(2,1:16),'k','linewidth',3);
plot(slpc(6,1:16),'--k','linewidth',3);
plot(slpc(3,1:16),'-b','linewidth',1.5);
plot(slpc(4,1:16),'r','linewidth',1.5);
%plot(slpc(5,1:17),'Color',[255 138 22]/255,'linewidth',1.5);
plot(slpc(5,1:16),'Color',[19 128 15]/255,'linewidth',1.5);
yrange=get(gca,'Ylim');
set(gca,'Xlim',[1 18]);
hh=hh0+t_fcst;
dd=dd0;
while (hh>=24)
   hh=hh-24
   dd=dd+1;
end
for it=1:17
    hh=hh+3;
    if(hh>=24)
       hh=hh-24
       dd=dd+1;
       %text(it,yrange(1)-0.075*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
       text(it,yrange(1)-0.07*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
    end
    xt{it}=num2str(hh,'%2.2d');
    day{it}=num2str(dd,'%2.2d');
    if(it==1)
       %text(it,yrange(1)-0.075*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
       text(it,yrange(1)-0.07*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
    end
end
tit=['Forecast initialized from SEP ',num2str(dd0),' ',num2str(hh0),'Z'];
text(9.5,yrange(1)+1.075*(yrange(2)-yrange(1)),tit,...
'verticalalignment','top','Fontsize',16,'horizontalalignment','center')
%text(4.5,yrange(1)+1.075*(yrange(2)-yrange(1)),[num2str(t_fcst),'-HR Forecast'],'verticalalignment','top','Fontsize',16,'horizontalalignment','center')
ylabel('Sea-leval Pressure','Fontsize',16);
set(gca,'Xtick',[1:17],'Xticklabel',xt,'fontsize',14);
%h=legend('TRUTH','CNT','AL25','BW3S','BW1','AL25BW3','AL25BW3S')
h=legend('Truth','e04','e02','e04RIPB','e04RIPD','e04RIPF')
set(h,'fontsize',12,'location','Southeast')
legend('boxoff')

%pfile=['fslp_e27rip_',num2str(t_fcst,'%2.2d'),'hr_091406z-091500z.ps'];
%eval(['print -dpsc -f2 ',pfile])
