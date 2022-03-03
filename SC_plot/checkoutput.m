clear all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
xlon  =getnc('wrfout_d03_2009-08-07_12:00:00','XLONG');
ylat  =getnc('wrfout_d03_2009-08-07_12:00:00','XLAT');
eta  = getnc('wrfout_d03_2009-08-07_12:00:00','ZNU');

[u1,v1,w1,th,qv,temp,slp,pressure]=getnc_vars('/work/temp/wrfout_d03_2009-08-07_12:00:00',1,xlon,ylat,eta);
[u2,v2,w2,th,qv,temp,slp,pressure]=getnc_vars('/work/temp/output/wrffcst_d03_2009-08-07_12:00:00'),1,xlon,ylat,eta;
[u3,v3,w3,th,qv,temp,slp,pressure]=getnc_vars('/work/temp/wrfanal_d03_2009-08-07_12:00:00',1,xlon,ylat,eta);
figure(1)
subplot(2,2,1)
%contourf(squeeze(u1(5,:,:)),[-30:2:30]);caxis([-30 30])
title('Truth')
subplot(2,2,2)
contourf(squeeze(u2(5,:,:)),[-30:2:30]);caxis([-30 30])
title('Background')
subplot(2,2,3)
contourf(squeeze(u3(5,:,:)),[-30:2:30]);caxis([-30 30])
title('Analysis')
subplot(2,2,4)
contourf(squeeze(abs(u1(5,:,:)-u3(5,:,:))-abs(u1(5,:,:)-u2(5,:,:))),[-10:1:10]);caxis([-10 10])
title('Improvement')

figure(2);clf
subplot(2,2,1)
x=1:3:size(u1,2);
y=1:3:size(u1,3);
%[c,h]=contourf(squeeze(w1(5,:,:)),[-2:0.2:-0.2,0.2:0.2:2]);caxis([-2 2])
hold on
quiver(x,y,squeeze(u1(5,x,y)),squeeze(v1(5,x,y)));hold on
axis([1 99 1 99])
title('Truth')
subplot(2,2,2)
[c,h]=contourf(squeeze(w2(5,:,:)),[-2:0.2:-0.2,0.2:0.2:2]);caxis([-2 2])
hold on
quiver(x,y,squeeze(u2(5,x,y)),squeeze(v2(5,x,y)));
axis([1 99 1 99])
title('Background')
subplot(2,2,3)
[c,h]=contourf(squeeze(w3(5,:,:)),[-2:0.2:-0.2,0.2:0.2:2]);caxis([-2 2])
hold on
quiver(x,y,squeeze(u3(5,x,y)),squeeze(v3(5,x,y)));
axis([1 99 1 99])

title('Analysis')
