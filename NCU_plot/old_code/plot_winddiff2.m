clear 
close all
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')

for i=15:20
hr=num2str(i);
load (['wind_diff_',hr,'.mat'])

%sp=(udiff.^2+vdiff.^2).^0.5;
sp=spdiff;

uplot=udiff(1:5:196,1:5:196,:);
vplot=vdiff(1:5:196,1:5:196,:);
xi=x(1:5:196,1:5:196);
yi=y(1:5:196,1:5:196);
nscale=20;
uplot(28,12,7)=nscale;
vplot(28,12,7)=0;

%---
figure
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c h]=m_contourf(x,y,sp(:,:,7),15);
m_grid('fontsize',12);
%m_coast('color','k');
m_gshhs_h('color','k');
set(h,'linestyle','none');
hc=colorbar;
caxis([-10 10]);
hold on
m_quiver(xi,yi,uplot(:,:,7),vplot(:,:,7),2,'k');
m_text(122.65,21.90,num2str(nscale),'color','k')

tit=['MR15 - ori wrf wind diff ( ',hr,'z )'];
  title(tit,'fontsize',13)

 outfile=['windspdiff_MR15_ori_',hr,'z.png'];
  saveas(gca,outfile,'png');
  
end 
  