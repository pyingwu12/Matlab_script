clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat'


s_hr='16'; expri='MRcycle06';
%----set---- 
point=17294; % west of radar
%point=14730;
vari='Corr.';   filenam=[expri,'_corr_'];  type='Vr-Qr';  
expdir=['/work/pwin/plot_cal/Corr./',expri,'/'];
%----
cmap=colormap_br;
L=[-0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 -0.05 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7];


%----load file----
load([expdir,'bgrd_VRQR_1km_',s_hr,'.mat']); 
%----cal----
A=reshape(VR_1km,198*198,40);
B=reshape(QR_1km,198*198,40);  %%%
%---
At=real(mean(A,2));  Bt=real(mean(B,2));
for i=1:40
Be(:,i)=B(:,i)-Bt;  Ae(:,i)=A(:,i)-At;
end
%---
Bbar=real(mean(Be,2));  Abar=real(mean(Ae,2));
for i=1:40
Bdiff(:,i)=Be(:,i)-Bbar;  Adiff(:,i)=Ae(:,i)-Abar;
end

A1=Adiff(point,:); 
varA=(A1*A1')/40;
for i=1:198*198;
varB(1,i)=(Bdiff(i,:)*Bdiff(i,:)')/40;
end

cov = (A1*Bdiff')/40 ;
corr0=cov./(varA^0.5)./(varB.^0.5);
corr=reshape(corr0,198,198);

  % cmap(8,:)=[1 1 1];
L2=[min(min(corr)),L];
figure('position',[500 100 600 500]) 
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c hp]=m_contourf(x,y,corr,L2);   set(hp,'linestyle','none');  hold on; 
m_plot(x(point),y(point),'ok','MarkerFaceColor',[0.1 0 0.1],'MarkerSize',7.3)
m_grid('fontsize',12);
% m_coast('color','k');
m_gshhs_h('color','k');
colorbar;   cm=colormap(cmap);    %caxis([-0.8 0.8])
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
tit=[expri,'  ',vari,' ',type,'  ',s_hr,'z (1km)'];
title(tit,'fontsize',15)
outfile=[expdir,filenam,type,'_',s_hr,'_',num2str(point),'.png'];
print('-dpng',outfile,'-r350')
%}
