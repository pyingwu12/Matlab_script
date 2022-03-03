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
% initial time
hh=12; dd=15;
% forecast length (6-hr output)
nt=12;

expdir{1}='/SAS001/ailin/exp09/osse/e01/fcst1512/'
tag{1}=['2006-09-14_00:00:00'];
tag{2}=['2006-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
figure(1);clf
subplot(2,1,1)
m_proj('miller','long',[113.5 138.5],'lat',[16 37]); hold on
m_grid('linest','--','box','fancy','tickdir','in');
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);

xc=124.0;yc=20.0;
hold on

% truth track (every hour)
load /SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/fcstTRUTH_e28_1hr.mat;
h=m_plot(lonc(1,6:6:end),latc(1,6:6:end),'-','linewidth',3,'color',[0.5 0.5 0.5]);

% for two runs
for nf=1:2
    if(nf==1)
    load /SAS001/ailin/exp09/osse/e01/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e01/fcst1512/fcst1512.mat;
    cc='b';
    else
    load /SAS001/ailin/exp09/osse/e03/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e03/fcst1512/fcst1512.mat;
    cc='r';
    end
    h=m_plot(lonc,latc,'-','color',cc,'linewidth',2);
end
m_plot([130 133.25],[19.5 19.5],'-','linewidth',3.0,'color',[0.5 0.5 0.5]);
m_plot([130 133.25],[18.3 18.3],'-r','linewidth',3.0);
m_plot([130 133.25],[17 17],'-b','linewidth',3.0);
m_text(133.4,19.3,'Truth','fontsize',10);
m_text(133.4,18.0,'LETKF','fontsize',10);
m_text(133.4,16.7,'LETKF-RIP','fontsize',10);
%legend('boxoff')

% LONS and LATS are the ensemble tracks
% lonc and latc are the mean of the ensemble tracks
for nf=1:2
    if(nf==1)
    load /SAS001/ailin/exp09/osse/e01/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e01/fcst1512/fcst1512.mat;
    cc='b';
    else
    load /SAS001/ailin/exp09/osse/e03/AVG/Fcst1512Track.mat;
    load  /SAS001/ailin/exp09/osse/e03/fcst1512/fcst1512.mat;
    cc='r';
    end
    figure(1)
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
    figure(2)
    subplot(2,1,2)
    plot([1:11],radius_p,'color',cc,'linewidth',2.0);hold on
end
figure(2)
yaxis1=0;
yaxis2=400;
xaxis1=1;
xaxis2=11;
axis([1 11 0 400])
set(gca,'position',[0.200 0.1 0.6 0.4],'fontsize',12,'xtick',[1:11],'xticklabel','  ');
tick_leg={'1512Z','1600Z','1612Z','1700Z','1712Z','1800Z'}
is=1;
for i=1:2:11
    xs=i;
    ys=yaxis1-(yaxis2-yaxis1)*0.02;
    h=text(xs,ys,tick_leg{is},'fontsize',12,...
    'horizontalalignment','center','verticalalignment','top');
    is=is+1;
end
title('(b) Radius of 70% probability circle of typhoon position','fontsize',14,'fontweight','bold')
xlabel('Time')
ylabel('Radius (Km)')
legend('LETKF','LETKF-RIP','location','northwest')
legend('boxoff')

subplot(2,1,1)
tpspeed;
set(gca,'Xlim',[4. 16],'Xtick',[0:16],'Ylim',[0 25],'Ytick',[0:5:25],'Yminortick','on',...
'fontsize',12,'xticklabel','  ');
xlabel('Time','fontsize',12)
ylabel('Translation speed (km/hr)','fontsize',12)
title('(a) Typhoon translation speed','fontsize',14,'fontweight','bold')
tick_leg={'1506Z','1512Z','1600Z','1612Z','1700Z','1712Z','1800Z'}
is=1;
for i=1:2:13
    xs=i+3.;
    ys=yaxis1-(25)*0.02;
    h=text(xs,ys,tick_leg{is},'fontsize',12,...
    'horizontalalignment','center','verticalalignment','top');
    is=is+1;
end
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 8 10])
set(gca,'position',[0.2 0.65 .6 0.3],'fontsize',14);

figure(1)
subplot(2,1,1)
set(gca,'position',[0.02500 0.55 1.0 0.35],'fontsize',14);
title('(a)Track initialized from 09/15 12Z','fontsize',14,'fontweight','bold')
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 8 10])
return
set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 11 8])
figure(2);clf
plot(slpc(3,:),'k','linewidth',2.0);;hold on
plot(slpc(1,:),'b','linewidth',2.0);
plot(slpc(2,:),'r','linewidth',2.0);
hh=0;dd=14;
yrange=get(gca,'Ylim');
for it=1:12
    hh=hh+6;
    if(hh>=24)
       hh=hh-24
       dd=dd+1;
       text(it,yrange(1)-0.075*(yrange(2)-yrange(1)),['09/',num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',12,'fontweight','bold');
    end
    xt{it}=num2str(hh,'%2.2d');
    day{it}=num2str(dd,'%2.2d');
end
ylabel('Sea-leval Pressure','Fontsize',12);
set(gca,'Xtick',[1:12],'Xticklabel',xt,'fontsize',12);
h=legend('True','Background','Analysis')
set(h,'fontsize',12,'location','southwest')
legend('boxoff')

