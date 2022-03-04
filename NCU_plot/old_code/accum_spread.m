
clear
%close all


[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
expri='MRcycle09';

load (['/work/pwin/plot_cal/Rain/',expri,'/obs_acci_1600_1700.mat'])
acci=wrfacci;

for i=1:40
  A(:,:,i)=acci{i};
end
meanA=mean(A,3);
se1=zeros(size(meanA));  se2=zeros(size(meanA));
for i=1:40    
  se1=se1+(A(:,:,i)-obsacci).^2;   
  se2=se2+(A(:,:,i)-meanA).^2;   
end
rmse=(se1./(size(A,3))-1).^0.5;
sprd=(se2./(size(A,3))-1).^0.5;
%
figure('position',[2000 100 400 300])
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c hp]=m_contourf(xi,yj,rmse,15);   set(hp,'linestyle','none');
m_grid('fontsize',12);
%m_gshhs_h('color','k');
m_coast('color','k');
colorbar;   caxis([0 30]);
title('rmse')
%}
figure('position',[2000 100 400 300])
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c hp]=m_contourf(xi,yj,sprd,15);   set(hp,'linestyle','none');
m_grid('fontsize',12);
%m_gshhs_h('color','k');
m_coast('color','k');
colorbar;   caxis([0 30]);
title('spread')