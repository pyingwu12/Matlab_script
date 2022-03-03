clf
subplot(2,1,1)
[c,h]=contourf(xlon,ylat,squeeze(uerr1(12,:,:)),[-15:1.5:15]);
set(h,'linestyle','none')
caxis([-15 15])
hold on
[c,h]=contour(xlon,ylat,squeeze(y1(:,:,12)'),[-10:1:10]);  
set(h,'edgecolor','k')   
axis([115 130 10 35])

subplot(2,1,2)
[c,h]=contourf(xlon,ylat,squeeze(uerr2(12,:,:)),[-15:1.5:15]);
set(h,'linestyle','none')
caxis([-15 15])
hold on
[c,h]=contour(xlon,ylat,squeeze(y2(:,:,12)'),[-10:1:10]);  
set(h,'edgecolor','k')   
axis([115 130 10 35])
