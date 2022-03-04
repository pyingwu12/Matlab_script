%close all
%
%clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')

hr='17';
load (['slp_',hr,'.mat'])
%---
bestx=120.4;
besty=25.2;
 rang=1.5;
 xr=[fix(bestx)-rang fix(bestx)+rang]; yr=[fix(besty)-rang fix(besty)+rang];
 finr=find(x>=xr(1) & x<=xr(2) & y>=yr(1) & y<=yr(2)); 
 xg=x(finr); yg=y(finr);

fin=find(landm>0);
%
for i=1:40  
   slp{i}(fin)=NaN;
   slpi0(:,:,i)=slp{i};
   
   slpi=slp{i}(finr); 
   [mslp mI]=min(slpi);
   locx(i)=xg(mI);
   locy(i)=yg(mI);
   minslp(i)=mslp;   
end

 slpmean=mean(slpi0,3); 
  [Y mxI]=min(slpmean);
  [mslp myi]=min(Y);
  mxi=mxI(myi); 
  locx(41)=x(mxi,myi);
  locy(41)=y(mxi,myi);
  minslp(41)=mslp;
%}
%
%---------plot-----------------------------
figure('position',[500 100 600 500])
m_proj('Lambert','lon',[117.5 123.5],'lat',[21.65 27],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
h1=m_plot(locx(1:40),locy(1:40),'o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 1],'MarkerSize',4); hold on
h2=m_plot(bestx,besty,'+r');
m_plot(locx(41),locy(41),'xr');
m_grid('fontsize',12);
m_gshhs_h('color','k');
%m_coast('color','k');
 entitle=['MR15 typhoon center (',hr,'z)'];
  title(entitle,'fontsize',14)
 outfile=['MR15_tycent_',hr,'z.png'];
  %saveas(gca,outfile,'png');
%}
%{
for n=1
figure
m_proj('Lambert','lon',[117.5 123.5],'lat',[21.65 27],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c2 hc2]=m_contourf(x,y,slp{n},20); hold on
set(hc2,'LineStyle','none'); colorbar;
h2=m_plot(bestx,besty,'+r');
h3=m_plot(locx(n),locy(n),'o','MarkerEdgeColor','none','MarkerFaceColor',[1 0 0],'MarkerSize',4);
m_grid('fontsize',12);
m_gshhs_h('color','k');
%m_coast('color','k');
 entitle=['MR15 typhoon center (',hr,'z mem',num2str(n),')'];
  title(entitle,'fontsize',14)
 outfile=['MR15_tycent_',hr,'z_',num2str(n),'.png'];
  saveas(gca,outfile,'png');
end
%}