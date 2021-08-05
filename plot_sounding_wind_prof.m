clear
close all


%--- setting ----
year='2019';  mon='08';  date='19';  hr='00';  minu='00';
figname='wind_prof_shionomisaki';
Wind=importdata('/mnt/e/data/sounding/shionomisaki_20190819_0000_wind.txt');

% h=A{1}./1000;
% u=A{4};
% v=A{5};
% spd=sqrt(u.^2+v.^2);
spd=Wind(:,3);
h=Wind(:,2)./1000;

figure('Position',[100 100 300 600],'color','w');
plot(spd,h,'linewidth',2.2);
%hold on; line([0 0],[0 30],'color','k','linestyle','--')
set(gca,'linewidth',1.2,'fontsize',15)
%title('Shionomisaki')
xlabel('wind speed (m/s)','fontsize',17); ylabel('Height (km)','fontsize',17)
%print('-dpng',['/mnt/e/figures/',figname,'.png'])

%%
%---idealized wind profile-------
z=h; %km
z0=3; %km

Us05= 5; U05=Us05*tanh(z./z0);
Us10=10; U10=Us10*tanh(z./z0);
Us15=15; U15=Us15*tanh(z./z0);
Us20=20; U20=Us20*tanh(z./z0);
Us25=25; U25=Us25*tanh(z./z0);

figure('position',[400 100 700 600])
plot(spd,h,'linewidth',2.5,'color',[0.4 0.4 0.4]);
hold on
plot(U05,h,'linewidth',2.8)
% plot(U10,h,'linewidth',2.8)
plot(U15,h,'linewidth',2.8)
% plot(U20,h,'linewidth',2.8)
plot(U25,h,'linewidth',2.8)

% legend('sounding','U05','U10','U15','U20','U25','location','bestout','fontsize',20)
legend('sounding','U05','U15','U25','location','bestout','fontsize',20)

set(gca,'linewidth',1.2,'fontsize',15)
%title(['Us= ',num2str(Us20)],'fontsize',20)

xlabel('wind speed (m/s)','fontsize',17); ylabel('Height (km)','fontsize',17)
print('-dpng','/mnt/e/figures/idealized_wind_profile_WeismanKlemp2.png')

%%
%---idealized wind profile-------
z=h; %km
z0=0.00003; %km

ust=0.1;
k=0.4;

ubar005=0.05/k*log(z./z0);

ubar01=0.1/k*log(z./z0);

ubar02=0.2/k*log(z./z0);

ubar03=0.3/k*log(z./z0);

ubar04=0.4/k*log(z./z0);
 
figure('position',[400 100 700 600])
% plot(spd,h,'linewidth',2.5,'color',[0.4 0.4 0.4])
hold on
plot(ubar005,z,'linewidth',2.8)
plot(ubar01,z,'linewidth',2.8)
plot(ubar02,z,'linewidth',2.8)
plot(ubar03,z,'linewidth',2.8)
plot(ubar04,z,'linewidth',2.8)

% legend('sounding','U05','U10','U15','U20','U25','location','bestout','fontsize',20)

set(gca,'linewidth',1.2,'fontsize',15)
%title(['Us= ',num2str(Us20)],'fontsize',20)

xlabel('wind speed (m/s)','fontsize',17); ylabel('Height (km)','fontsize',17)
% print('-dpng','/mnt/e/figures/idealized_wind_profile_eq.png')
