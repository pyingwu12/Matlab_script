% read
clear all
clf
addpath('/work/ailin/matlab/lib');
addpath('/work/ailin/matlab/windbarb/');
addpath('/work/ailin/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/')
file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_2day';
xlon=getnc(file,'XLONG');
ylat=getnc(file,'XLAT');
eta=getnc(file,'ZNU');
iread=1;
nt=11;
%levs=[850, 800, 750,700,650,600,550,500 ,  450 , 400 ,  350 ,300 ];%, 25000 ];
levs=[700,650,600,550,500 ,  450 , 400 ,  350 ,300 ];%, 25000 ];
if(iread==0)

for nf=1:3
dd0=15;
hh0=12;
for i=1:nt
    yyyy=num2str(2006,'%4.4d');
    mm=num2str(9,'%2.2d');
    dd=num2str(dd0,'%2.2d');
    hh=num2str(hh0,'%2.2d');
    switch (nf)
    case(1)
       if(dd=='15')
          file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_2day';
       elseif(dd=='16')
          file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_3day';
       elseif(dd=='17')
          file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_4day';
       end
      savefile='steerflow_truthz.mat';
    case(2)
      file='/SAS001/ailin/exp09/osse/e01/AVG//wrfout_d01_2006-09-15_12:00:00.avg';
      savefile='steerflow_e01z.mat';
    case(3)
      file='/SAS001/ailin/exp09/osse/e03/AVG//wrfout_d01_2006-09-15_12:00:00.avg';
      savefile='steerflow_e03z.mat';
    end
    [ve(:,i),vez(:,:,i),ve_m(:,i),vez_m(:,:,i),eta,lonc(i),latc(i)]=steering_z(file,yyyy,mm,dd,hh,100.*levs,-1,-1);
    hh0=hh0+6;
    if(hh0>=24);
       dd0=dd0+1;    
       hh0=hh0-24;
    end
end
%eval(['save ',savefile,' ve;'])
%save(savefile,'ve','vez','ve_m','vez_m','eta','lonc','latc');
end
end
%%levs=[850,800,750,700,650,600,550,500 ,  450 , 400 ,  350 ,300 ];%, 25000 ];
%%load steerflow_truthz.mat ve vez lonc latc;
%infile='steerflow_truthz.mat';
for nf=1:3
    switch(nf)
    case(1)
infile='truth_steeringnew.mat';
    case(2)
infile='e01_steeringnew.mat';
    case(3)
infile='e03_steeringnew.mat';
    end
    load(infile,'vez','uez');
for it=1:11
    ve_m(1,it)=nanmean(uez(8:20,it));
     ve_m(2,it)=nanmean(vez(8:20,it));
     %[dum,ve_m(1,it)]=my_quad(eta(1,5:21),uez(5:21,it));
     %[dum,ve_m(2,it)]=my_quad(eta(1,5:21),vez(5:21,it));
end
eval(['u',num2str(nf),'=ve_m(1,:);']); 
eval(['v',num2str(nf),'=ve_m(2,:);']); 
eval(['uz',num2str(nf),'=squeeze(uez(:,:));'])
eval(['vz',num2str(nf),'=squeeze(vez(:,:));'])
end
%%uz1=squeeze(vez(1,:,:));vz1=squeeze(vez(2,:,:));
%lons(:,1)=lonc;
%lats(:,1)=latc;
%%load steerflow_e01z.mat ve vez lonc latc;
%infile='steerflow_e01z.mat';
%load(infile,'ve','vez','ve_m','vez_m','eta','lonc','latc');
%%u2=ve(1,:); v2=ve(2,:);
%%uz2=squeeze(vez(1,:,:));vz2=squeeze(vez(2,:,:));
%u2=ve_m(1,:); v2=ve_m(2,:);
%uz2=squeeze(vez_m(1,:,:));vz2=squeeze(vez_m(2,:,:));
%lons(:,2)=lonc;
%lats(:,2)=latc;
%%load steerflow_e03z.mat ve vez lonc latc;
%infile='steerflow_e03z.mat';
%load(infile,'ve','vez','ve_m','vez_m','eta','lonc','latc');
%%u3=ve(1,:); v3=ve(2,:);
%%uz3=squeeze(vez(1,:,:));vz3=squeeze(vez(2,:,:));
%u3=ve_m(1,:); v3=ve_m(2,:);
%uz3=squeeze(vez_m(1,:,:));vz3=squeeze(vez_m(2,:,:));
%lons(:,3)=lonc;
%lats(:,3)=latc;

subplot(3,1,1)
xbox=[9.01;9.01;9.98;9.98];
ybox=[5.1;19.9;19.9;5.1];
zdata=ones(4,1);
patch(xbox,ybox,zdata,'facecolor',[0.9 0.9 0.9],'EdgeColor','none');hold on
tpspeed;
set(gca,'Xlim',[5.2 16.7],'Xtick',[0:16],'Ylim',[5 20],'Ytick',[0:5:25],'Yminortick','on',...
'fontsize',12,'xticklabel','  ','position',[0.075 0.81 0.9 0.155],'box','on');
ylabel('Translation speed (km/hr)','fontsize',12)
title('(a) Typhoon translation speed','fontsize',12,'fontweight','bold')
tick_leg={'1500Z','1512Z','1600Z','1612Z','1700Z','1712Z','1800Z'}
yaxis1=5;
is=2;
for i=3:2:13
    xs=i+3.;
    ys=yaxis1-(20)*0.02;
    h=text(xs,ys,tick_leg{is},'fontsize',12,...
    'horizontalalignment','center','verticalalignment','top');
    is=is+1;
end

subplot(3,1,2)
[X,Y] = meshgrid(1:nt,1:1);
line([0 nt+1],[0 1+1],'color','w')
xlim([0 nt])
ylim([0 3+1])
scale=0.35;
fullbar=25;
xbox=[4.01;4.01;4.98;4.98;];
%ybox=[0.61;1.19;1.19;0.61];
ybox=[-4;9.5;9.5;-4];
zdata=ones(4,1);
patch(xbox,ybox,zdata,'facecolor',[0.9 0.9 0.9],'EdgeColor','none');hold on
%windbarbM(X,Y,u1,v1,scale,fullbar,'k',2.);hold on
%windbarbM(X,Y,u2,v2,scale,fullbar,'b',1.);hold on
%windbarbM(X,Y,u3,v3,scale,fullbar,'r',1.);hold on
plot(u1,'-ko');hold on
plot(u2,'-bo')
plot(u3,'-ro')
plot(v1,'-ks');hold on
plot(v2,'-bs')
plot(v3,'-rs')
plot([0 12],[0 0],':k')
plot([0 12],[9.5 9.5],'k')

set(gca,'position',[0.075 0.45 0.9 0.3],'xtick',[0:11],'xticklabel','','box','on',...
'fontsize',12)
%axis([0.2 11.7 0.6 1.2])
axis([0.2 11.7 -4 9.5])

title('(b) Averaged steering flow','fontsize',12,'fontweight','bold')
ylabel('zonal/meridional velocity (m/s)','fontsize',12)
is=2;
for i=1:2:12
    xs=i;
    ys=-4-(13.5)*0.02;
    h=text(xs,ys,tick_leg{is},'fontsize',12,...
    'horizontalalignment','center','verticalalignment','top');
    is=is+1;
end
clear X Y;
subplot(3,1,3)
%for i=1:nt
%    x(1:12,i)=i*2;
%    y(1:12,i)=-levs;
%end
%iselect=[1 3 5 7 9];
%iselect=8:2:15;
iselect=[8 10 12 16];
[X,Y] = meshgrid(1:nt,1:length(iselect));
%Y(:,1)=[0 0.75 1.5 2.25]';
Y(:,1)=[0 0.6 1.2 1.8]';
for i=1:size(Y,2)
    Y(:,i)=Y(:,1);
end
line([0 nt+1],[0 length(iselect)+1],'color','w')
xlim([0 nt])
ylim([0 length(iselect+1)])
scale=0.35;
fullbar=25;

xbox=[4.01;4.01;4.98;4.98];
ybox=[-0.29;2.49;2.49;-0.29];
zdata=ones(4,1);

patch(xbox,ybox,zdata,'facecolor',[0.9 0.9 0.9],'EdgeColor','none');hold on
windbarbM(X,Y,uz1(iselect,:),vz1(iselect,:),scale,fullbar,'k',2.);hold on
windbarbM(X,Y,uz2(iselect,:),vz2(iselect,:),scale,fullbar,'b',1.);hold on
windbarbM(X,Y,uz3(iselect,:),vz3(iselect,:),scale,fullbar,'r',1.);hold on
plot([0 12],[2. 2.],'k')
axis([0.2 11.7 -0.3 2.])
is=2;
for i=1:2:12
    xs=i;
    ys=-0.3-(2.5+0.3)*0.02;
    h=text(xs,ys,tick_leg{is},'fontsize',12,...
    'horizontalalignment','center','verticalalignment','top');
    is=is+1;
end
set(gca,'position',[0.075 0.1 0.9 0.3],'xtick',[0:11],'xticklabel','',...
'ytick',[0:0.6:1.8],'yticklabel',num2str(eta(1,iselect)','%2.2f'),'box','on','fontsize',12)
ylabel('Sigma','fontsize',12)
text(0.5*(0.2+11.7),-0.3-(2.5+0.3)*0.075,'Time','fontsize',12,...
    'horizontalalignment','center','verticalalignment','top');
%h=quiver(x(:,:),y(:,:),uz1(:,:),vz1(:,:));hold on
%h=quiver(ones(12:1),-levs',uz1(:,1),vz1(:,1))
%set(h,'AutoScaleFactor',0.005,'MaxHeadSize',0.9)
%set(h,'color','k');
%h=quiver([1:nt],levs,uz2,vz2,0.5);
%set(h,'color','b');
%h=quiver([1:nt],levs,uz3,vz3,0.5);
%set(h,'color','r');
title('(c) Steering flow at model levels','fontsize',12,'fontweight','bold')
%subplot(2,1,2)
%plot(lons(:,1),lats(:,1),'-ko','linewidth',2);hold on
%plot(lons(:,2),lats(:,2),'-bo','linewidth',2);
%plot(lons(:,3),lats(:,3),'-ro','linewidth',2);
%set(gca,'position',[0.15 0.05 0.7 0.5])

%xlabel('Time','fontsize',12)
set(gcf,'paperorientation','portrait','paperposition',[0.25 .5 8 10.0],'position',[10 100 900 1000])
