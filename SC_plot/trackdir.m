clear all
constants;
global Re rad;
reread=1;
clf
addpath('/work/scyang/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');

file0='/SAS001/ailin/SHAND25/PT37_2/wrfinput_d01_148179_0_28';
xlon=getnc(file0,'XLONG');
ylat=getnc(file0,'XLAT');
eta=getnc(file0,'ZNU');
nx=size(xlon,2);
ny=size(xlon,1);
nz=length(eta);
in1z=1:26;in2z=in1z+1;
zg=zeros(nz,ny,nx);
pressure=zeros(nz,ny,nx);
nens=36;
run=nens;
iplt=1;
it=1;
hh=12;
dd=15;
nt=12;
expdir{1}='/SAS001/ailin/exp09/osse/e01/fcst1512/'
tag{1}=['2006-09-14_00:00:00'];
tag{2}=['2006-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
%m_proj('lambert','long',[115 135],'lat',[15 30]); hold on
%m_proj('miller','long',[113.5 138.5],'lat',[16 37]); hold on
%m_grid('linest','--','box','fancy','tickdir','in');
%m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
xc=124.0;yc=20.0;
hold on
load /SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/fcstTRUTH_e28_1hr.mat;
%h=m_plot(lonc(1,6:6:end),latc(1,6:6:end),'-','linewidth',3,'color',[0.5 0.5 0.5]);
lonc0=lonc(1,36:6:end);
latc0=latc(1,36:6:end);
for i=1:10
    [theta(i,1),Rdist]=getdir(lonc0(i),latc0(i),lonc0(i+1),latc0(i+1));
end
cc{1}='r';
cc{2}='b';
for nf=1:2
    if(nf==1)
    load /SAS001/ailin/exp09/osse/e01/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e01/fcst1512/fcst1512.mat;
    else
    load /SAS001/ailin/exp09/osse/e03/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e03/fcst1512/fcst1512.mat;
    end
    %h=m_plot(lonc,latc,'-','color',cc,'linewidth',2);
   
    for i=1:10
        [theta_means(i,nf),Rdist]=getdir(lonc(i),latc(i),lonc(i+1),latc(i+1));
    
        for k=1:36
           [thetas(k,i,nf),Rdist]=getdir(LONS(k,i),LATS(k,i),LONS(k,i+1),LATS(k,i+1));
        end
        %theta_iqr(i,nf)=iqr(thetas(thetas(:,i,nf));
        qs(i,:,nf)=quantile(thetas(:,i,nf),[0.05 0.25 0.50 0.75 0.95]);
        %qs(i,:,nf)=quantile(thetas(:,i,nf),[0.1 0.25 0.50 0.75 0.9]);
        theta_max(i,nf)=max(thetas(:,i,nf));
        theta_min(i,nf)=min(thetas(:,i,nf));
        count(i,nf)=length(find(thetas(:,i,nf)<-11.25));
    end
end
yaxis2=100;
yaxis1=-100;
tick_leg1={'1512Z','1600Z','1612Z','17000','1712Z','1800Z'}
tick_leg2={'18Z','06Z','18Z','06Z','18Z','06Z'}
for nf=1:2
    subplot(2,1,nf)
    plot(theta(:,1),'k','linewidth',2);hold on
    plot(theta_means(:,1),'*','color',cc{nf});hold on
    for i=1:10
        pltbox([i-0.15 i+0.15],[qs(i,2,nf) qs(i,4,nf)],qs(i,3,nf),qs(i,1,nf),qs(i,5,nf),1,cc{nf});
        %pltbox([i-0.1 i+0.1],[qs(i,2,nf) qs(i,4,nf)],qs(i,3,nf),theta_min(i,nf),theta_max(i,nf),1,cc{nf})
    end
    is=1;
    for i=1:2:11
        xs=i-0.5;
        ys=yaxis1-(yaxis2-yaxis1)*0.02;
        h=text(xs,ys,tick_leg1{is},'fontsize',10,...
        'horizontalalignment','center','verticalalignment','top');
        if(i<11)
           xs=i+0.5;
           ys=yaxis1-(yaxis2-yaxis1)*0.02;
           h=text(xs,ys,tick_leg2{is},'fontsize',10,...
           'horizontalalignment','center','verticalalignment','top');
        end
        is=is+1;
    end
    set(gca,'xtick',[0.5:1:11],'xticklabel',' ','fontsize',12);
    axis([0.5 10.5 -100 100])
    ylabel('Moving direction (degree)','fontsize',12)
    xlabel('Time','fontsize',12)
    if(nf==1)
       title('(a) LETKF ensemble vs. Truth','fontsize',14,'fontweight','bold')
    else
       title('(b) LETKF-RIP ensemble vs. Truth','fontsize',14,'fontweight','bold')
    end
end
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 6.5 10])
return
subplot(2,1,2)
plot(theta(:,1),'k','linewidth',2);hold on
plot(theta_means(:,2),'b*');hold on
nf=2;
for i=1:10
    pltbox([i-0.2 i+0.2],[qs(i,2,nf) qs(i,4,nf)],qs(i,3,nf),qs(i,1,nf),qs(i,5,nf),1,cc{nf});
    %pltbox([i-0.1 i+0.1],[qs(i,2,nf) qs(i,4,nf)],qs(i,3,nf),theta_min(i,nf),theta_max(i,nf),0,cc{nf})
end
is=1;
for i=1:2:10
    xs=i+0.5;
    ys=yaxis1-(yaxis2-yaxis1)*0.02;
    h=text(xs,ys,tick_leg{is},'fontsize',12,...
    'horizontalalignment','center','verticalalignment','top');
    is=is+1;
end

set(gca,'xtick',[0.5:1:11],'xticklabel',' ');
%for k=1:36
    %plot(thetas(k,:,1),'-rx');hold on
%end
%for k=1:36
%    plot(thetas(k,:,2),'-b*');hold on
%end
axis([0.5 10.5 -100 100])
return
m_plot([130 133.25],[19.5 19.5],'-','linewidth',3.0,'color',[0.5 0.5 0.5]);
m_plot([130 133.25],[18.3 18.3],'-r','linewidth',3.0);
m_plot([130 133.25],[17 17],'-b','linewidth',3.0);
m_text(133.4,19.3,'Truth','fontsize',10);
m_text(133.4,18.0,'LETKF','fontsize',10);
m_text(133.4,16.7,'LETKF-RIP','fontsize',10);
%legend('boxoff')
for nf=1:2
    if(nf==1)
    load /SAS001/ailin/exp09/osse/e01/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e01/fcst1512/fcst1512.mat;
    cc='r';
    else
    load /SAS001/ailin/exp09/osse/e03/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e03/fcst1512/fcst1512.mat;
    cc='b';
    end
    subplot(2,1,1)
    for i=1:length(lonc)
        %if(mod(i,4)==1)
           ir=0;
           radius_p(i)=0;
           while( radius_p(i)==0)
              radius=0+25*ir;
              rys=Re*rad*(LATS(:,i)-latc(i));
              rxs=Re*cos(rad*latc(i))*rad*(LONS(:,i)-lonc(i));
              rs=sqrt(rys.^2+rxs.^2);
              nvalid=length(find(rs<radius));
              if(nvalid> 25)
                 radius_p(i)=radius;
              end
              ir=ir+1;
           end
        if(mod(i,4)==3 | i==1)
        h=m_plot(lonc(i),latc(i),'x','color',cc,'markersize',10,'linewidth',2.5);
           is=0;
           for s=0:0.2:360
               is=is+1;
               ry=radius_p(i)*sin(s*pi/180.);
               rx=radius_p(i)*cos(s*pi/180.);
               circle_y(is)=ry/(Re*rad)+latc(i);
               circle_x(is)=rx/(Re*cos(rad*latc(i))*rad)+lonc(i);
           end
	   h=m_plot(circle_x,circle_y,'--','linewidth',1,'color',cc);
           %h=m_plot(lonc(i),latc(i),'rx','markersize',10);
           %h=m_text(lonc(i),latc(i),'X','color',cc,'fontsize',12,'fontweight','bold',...
           %'horizontalalignment','center','verticalalignment','top');
        end
    end
    subplot(2,1,2)
    plot([1:11],radius_p,'color',cc,'linewidth',2.0);hold on
end
yaxis1=0;
yaxis2=400;
xaxis1=1;
xaxis2=11;
axis([1 11 0 400])
set(gca,'position',[0.200 0.075 0.6 0.4],'fontsize',12,'xtick',[1:11],'xticklabel','  ');
xlabel('Time')
ylabel('Radius (Km)')
legend('LETKF','LETKF-RIP','location','northwest')
legend('boxoff')
subplot(2,1,1)
set(gca,'position',[0.02500 0.55 1.0 0.35],'fontsize',14);
title('(a)Track initialized from 09/15 12Z','fontsize',14,'fontweight','bold')
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 8 10])
