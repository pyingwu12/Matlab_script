% read
clear all
iread=1;
nt=13;
if(iread==0)

for nf=1:3
dd0=15;
hh0=00;
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
      savefile='steerflow_truth.mat';
    case(2)
      file='/SAS001/ailin/exp09/osse/e01/AVG//wrfout_d01_2006-09-15_12:00:00.avg';
      savefile='steerflow_e01.mat';
    case(3)
      file='/SAS001/ailin/exp09/osse/e03/AVG//wrfout_d01_2006-09-15_12:00:00.avg';
      savefile='steerflow_e03.mat';
    end
    [ve(:,i),lonc(i),latc(i)]=steering(file,yyyy,mm,dd,hh,-1,-1)
    hh0=hh0+6;
    if(hh0>=24);
       dd0=dd0+1;    
       hh0=hh0-24;
    end
end
%eval(['save ',savefile,' ve;'])
save(savefile,'ve','lonc','latc');
end
end
load steerflow_truth.mat ve lonc latc;
u1=ve(1,:);v1=ve(2,:);
lons(:,1)=lonc;
lats(:,1)=latc;
load steerflow_e01.mat ve lonc latc;
u2=ve(1,:); v2=ve(2,:);
lons(:,2)=lonc;
lats(:,2)=latc;
load steerflow_e03.mat ve lonc latc;
u3=ve(1,:);
v3=ve(2,:);
lons(:,3)=lonc;
lats(:,3)=latc;
Ues=[u1;u2;u3];
Ves=[v1;v2;v3];
figure(2);clf
subplot(2,1,1)
h=quiver([1:nt],ones(1,nt),u1,v1,0.5);hold on
set(h,'color','k');
h=quiver([1:nt],ones(1,nt)-2,u2,v2,0.5);
set(h,'color','b');
h=quiver([1:nt],ones(1,nt)-2,u3,v3,0.5);
set(h,'color','r');
axis([-1 14 -3 3])
set(gca,'position',[0.05 0.65 0.9 0.25])
subplot(2,1,2)
plot(lons(:,1),lats(:,1),'-ko','linewidth',2);hold on
plot(lons(:,2),lats(:,2),'-bo','linewidth',2);
%plot(lons(:,3),lats(:,3),'-ro','linewidth',2);
set(gca,'position',[0.15 0.05 0.7 0.5])
set(gcf,'paperorientation','portrait','paperposition',[0.025 2.5 8.0 6.0],'position',[50 50 400 400])
