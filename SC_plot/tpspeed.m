%addpath('/work/scyang/matlab/map/m_map/')
function tspeed()
constants;
global Re rad;
%figure(2);clf
nt=1:17;
for nf=2:2
    load /SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/fcstrune28.mat;
    lonc0=lonc;
    latc0=latc;
    switch (nf)
    case(0)
      date='1500';
    case(1)
      date='1506';
      subfig='(a)'
    case(2)
      date='1512';
      subfig='(b)'
    case(3)
      date='1518';
      subfig='(c)'
    case(4)
      date='1600';
      subfig='(d)'
    end 
    eval(['load /SAS001/ailin/exp09/osse/e01/AVG/Fcst',date,'Track.mat;'])
    lonc1=lonc;
    latc1=latc;
    eval(['load /SAS001/ailin/exp09/osse/e03/AVG/Fcst',date,'Track.mat;'])
    lonc2=lonc;
    latc2=latc;
    
    for j=1:3
        eval(['latc=latc',num2str(j-1),';']);
        eval(['lonc=lonc',num2str(j-1),';']);
        for i=2:length(lonc)
        ry=Re*rad*(latc(i)-latc(i-1));
        rx=Re*cos(rad*latc(i))*rad*(lonc(i)-lonc(i-1));
        r=sqrt(rx.^2+ry.^2);
        ts(i-1,j)=r/6;
        end
    end
    %m_proj('miller','long',[115 135],'lat',[15 30]); hold on
    %m_grid('linest','--','box','fancy','tickdir','in');
    %m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    %h1=m_plot(lonc0(2:end),latc0(2:end),'-k','linewidth',3.0);hold on
    %h2=m_plot(lonc1(:),latc1(:),'-b','linewidth',2.,'markersize',12);
    %h3=m_plot(lonc2(:),latc2(:),'-r','linewidth',2.,'markersize',12);
    %  0.0   1.0    2.0   3.0   4.0   5.0
    % 14/06 14/12  14/18 15/00 15/06 15/12
    %subplot(4,1,nf)
    plot([4.5:15.5],ts(5:16,1),'-ko','linewidth',3);hold on
    plot([nf+4.5:nf+4.5+9],ts(1:10,2),'-bo','linewidth',2);
    plot([nf+4.5:nf+4.5+9],ts(1:10,3),'-ro','linewidth',2);
%hleg=legend('Truth','LETKF','LETKF-RIP')
%legend('boxoff')
%set(hleg,'location','southwest','fontsize',11)
    %set(gca,'Xlim',[4.5 16],'Xtick',[0:16],'Ylim',[0 25],'Ytick',[0:5:25],'Yminortick','on',...
    %'Xticklabel',{'00','06','12','18','00','06','12','18','00','06','12','18','00','06','12','18','00'},'fontsize',12);
    %dd=15;
    %for id=[5,8,12,16]
    %    %text(4.+4*(id-15),-6,num2str(id),'horizontalalignment','center','verticalalignment','top')
    %    text(id,-3.,num2str(dd),'horizontalalignment','center','verticalalignment','top','fontsize',12,'fontsize',14)
    %    dd=dd+1;
    %end
    ylabel('Translation speed (km/hr)')
    %text(4.8,2,['init: 09/',date(1:2),' ',date(3:4),'Z'],'fontsize',14)
    %text(16,2,subfig,'fontsize',14,'horizontalalignment','right')
    %xlabel('Time')
end


%set(gcf,'PaperOrientation','Portrait','PaperPosition',[.125 0.25 7. 10.5])
