clear 
close all

for i=15:20;
hr=num2str(i);
load (['wind_',hr,'.mat'])

uplot=umean(1:5:196,1:5:196,:);
vplot=vmean(1:5:196,1:5:196,:);
xi=x(1:5:196,1:5:196);
yi=y(1:5:196,1:5:196);

scax=zeros(40); scay=zeros(40); 
scax(27,12)=10; 
sca=(uplot(27,12,7)^2+vplot(27,12,7)^2)^0.5;

%---
figure
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')


m_quiver(xi,yi,uplot(:,:,7),vplot(:,:,7),2,'k');
hold on
%h2=m_quiver(xi,yi,scax,scay,1,'r');
m_text(122.52,21.85,num2str(sca),'color','r')

m_grid('fontsize',12);
%m_coast('color','k');
m_gshhs_h('color','k');

tit=['ori wrf wind ( ',hr,'z ensemble mean)'];
  title(tit,'fontsize',13)
 outfile=[hr,'z_ori_wind.png'];
  saveas(gca,outfile,'png');
end  
  
  