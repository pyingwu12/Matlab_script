clear
close all


%--- setting ----
%
year='2019';  mon='08';  date='19';  hr='00';  minu='00';
figname='wind_prof_shionomisaki';
Wind=importdata('/mnt/e/data/sounding/shionomisaki_20190819_0000_wind.txt');
% Wind=importdata('D:/data/sounding/shionomisaki_20190819_0000_wind.txt');
outfile='/mnt/e/figures/expri_twin/wind_profiles_U00NS5';

spd=Wind(:,3);
h=Wind(:,2)./1000;

%%
%---idealized wind profile-------
z=h; %km
z0=3; %km

% Us05= 5; U05 = Us05*tanh(z./z0);
% Us10=10; U10 = Us10*tanh(z./z0);
% Us15=15; U15 = Us15*tanh(z./z0);
% Us20=20; U20 = Us20*tanh(z./z0);
Us25=25; U25 = Us25*tanh(z./z0);


U25shear = (U25(2:end)-U25(1:end-1))./ ((h(2:end)-h(1:end-1))*1000);

u=Wind(:,3).*cos((270-Wind(:,4))*pi/180);
v=Wind(:,3).*sin((270-Wind(:,4))*pi/180);

u_shear=(u(2:end)-u(1:end-1))  ./ ((h(2:end)-h(1:end-1))*1000);
v_shear=(v(2:end)-v(1:end-1))  ./ ((h(2:end)-h(1:end-1))*1000);
spd_shear= (u_shear.^2 + v_shear.^2).^0.5;

%%
close all

s_col=[183 179 162]/255;
% NS5_col=[104 111 18]/255;
NS5_col=[77 191 216]/255;
U00_col=[246 190 0]/255;
U25_col=[77 191 216]/255;


hf=figure('position',[50 200 800 700]);

ax1=subplot(1,3,1);
set(ax1,'position',[0.09 0.1406 0.3099 0.7844])
plot(Wind(:,4),h(1:end),'linewidth',3.8,'color',s_col);hold on
% plot([270 270],[0 h(end-1)],'linewidth',3.5,'color',U25_col);
plot([270 270],[0 h(end-1)],'linewidth',3.8,'color',NS5_col,'linestyle',':');
  xlabel(ax1,'Direction','position',[180 -2 -1.0000]); 
 ylabel(ax1,'Height (km)')
    set(ax1,'linewidth',1.2,'fontsize',18,'Ylim',[0 27],'Xlim',[0 360],'xtick',[0 90 180 270 360],'xticklabel',{'N','E','S','W'})
% title('wind direction')

ax2=subplot(1,3,2);
set(ax2,'position',[0.5 0.1406 0.3099 0.7844])
ploth(1)=plot(spd,h,'linewidth',3.8,'color',s_col);  hold on
% plot(U25,h,'linewidth',3.5,'color',U25_col);
ploth(2)=plot([5 5],[0 h(end)],'linewidth',3.8,'color',NS5_col,'linestyle',':');
ploth(3)=plot([0 0],[0 h(end)],'linewidth',3.8,'color',U00_col,'linestyle','--');
  xlabel(ax2,'Speed (m s^-^1)','position',[12 -1.6 -1.0000]);
    set(ax2,'linewidth',1.2,'fontsize',18,'Ylim',[0 27],'Xlim',[0 25],'XTick',[0 5 10 15 20]) 
% title('wind speed')
    
% sgtitle('Wind','fontsize',25)
% ax3=subplot(1,3,3);
% set(ax3,'position',[0.61 0.1406 0.2099 0.7844])
% ploth(1)=plot(spd_shear,h(1:end-1),'linewidth',3.5,'color',s_col);hold on
% % ploth(4)=plot(U25shear,h(1:end-1),'linewidth',3.5,'color',U25_col); 
% ploth(2)=plot([0 0],[0 h(end-1)],'linewidth',3.5,'color',NS5_col,'linestyle',':');
% ploth(3)=plot([0 0],[0 h(end-1)],'linewidth',3.5,'color',U00_col,'linestyle','--');
%   xlabel('Vertical shear (s^-^1)','position',[0.01 -2.4 -1.0000]);
%   set(ax3,'linewidth',1.2,'fontsize',20,'Ylim',[0 27],'Xlim',[0 0.02])
  
%   hlg=legend(ploth,'Sounding','NS5','U00','U25','location','se','fontsize',20);
%   set(hlg,'position',[0.8  0.183  0.16  0.25])
   hlg=legend(ploth,'Sounding','NS5','U00','location','se','fontsize',20);
  set(hlg,'position',[0.76  0.183  0.2  0.18])


print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

