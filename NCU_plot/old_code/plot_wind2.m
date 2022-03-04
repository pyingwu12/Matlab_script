clear 
close all

for i=15:20;
hr=num2str(i);
load (['wind_',hr,'.mat'])


sp=(ui.^2+vi.^2).^0.5;

uplot=ui(1:5:196,1:5:196,:);
vplot=vi(1:5:196,1:5:196,:);
xi=x(1:5:196,1:5:196);
yi=y(1:5:196,1:5:196);

scax=zeros(40); scay=zeros(40); 
scax(27,12)=10; 
sca=(uplot(27,12,7)^2+vplot(27,12,7)^2)^0.5;

%---
figure
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')

[c h]=m_contourf(x,y,sp(:,:,7),15);
set(h,'linestyle','none');
hc=colorbar;
caxis([0 50]);

hold on
m_quiver(xi,yi,uplot(:,:,7),vplot(:,:,7),2,'k');

m_grid('fontsize',12);
%m_coast('color','k');
m_gshhs_h('color','k');

tit=['single wrf wind ( ',hr,'z )'];
  title(tit,'fontsize',13)
 outfile=['sing_wind_',hr,'z.png'];
  saveas(gca,outfile,'png');
end  
  
  