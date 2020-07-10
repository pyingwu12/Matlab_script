clear
close all


%--- setting ----
year='2019';  mon='08';  date='19';  hr='00';  minu='00';
figname='wind_prof_shionomisaki_weaken';
Wind=importdata('/mnt/e/data/sounding/shionomisaki_20190819_0000_wind_weaken.txt');

% h=A{1}./1000;
% u=A{4};
% v=A{5};
% spd=sqrt(u.^2+v.^2);
spd=Wind(:,3);
h=Wind(:,2)./1000;

figure('Position',[100 45 300 600],'color','w');
plot(spd,h,'linewidth',2.2);
%hold on; line([0 0],[0 30],'color','k','linestyle','--')
set(gca,'linewidth',1.2,'fontsize',15)
%title('Shionomisaki')
xlabel('wind speed (m/s)','fontsize',17); ylabel('Height (km)','fontsize',17)
%print('-dpng',['/mnt/e/figures/',figname,'.png'])