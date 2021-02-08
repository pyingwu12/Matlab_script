
% plot scatter plot of cloud size to moist DTE over the cloud area
% the cloud area is detected by the funtion <cal_cloudarea_1time>
% P.Y. Wu @ 2021.02.05

close all
clear
%---setting 
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
stday=22;   hrs=[22 23 24 25 26 27];  minu=[20 50];  
% fitid=0;  %if ~=0, plot fitting line !!!!!!!
%
cloudhyd=0.005; % threshold of definition of cloud area (Kg/Kg)
areasize=10;    % threshold of finding cloud area (gird numbers)
ym='201806';
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='size of cloud area to moist DTE';  
fignam=[expri1(8:end),'_cloud-DTE_'];
%
load('colormap/colormap_ncl.mat')
col=colormap_ncl([3 8 17 32 58 81 99 126 147 160 179 203],:);
%%
%---
hf=figure('Position',[100 65 900 480]);
nti=0;  ntii=0; 
for ti=hrs 
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  for mi=minu
    nti=nti+1;
    s_min=num2str(mi,'%2.2d');     
    %
    cloud=cal_cloudarea_1time(indir,expri1,expri2,ym,s_date,s_hr,s_min,areasize,cloudhyd);    
    if ~isempty(cloud) 
      if nti<=3
       plot(cloud.scale,cloud.maxdte,'o','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',[0.1 0.1 0.1]); hold on   
      else
       plot(cloud.scale,cloud.maxdte,'o','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:)); hold on         
      end
      ntii=ntii+1;
      lgnd{ntii}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST']; 
      %----
      disp([s_hr,s_min,' done'])
    end % if ~isempty(cloud)
  end % mi
end %ti

legend(lgnd,'Interpreter','none','fontsize',18,'Location','bestoutside');
set(gca,'fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','Yscale','log')
set(gca,'XLim',[3.5 1e2],'YLim',[2e-2 2e2])
xlabel({'Size (km)';'(Diameter of circle with the same area)'}); 
ylabel({'(Mean of first 10 maximum)','Moist DTE'});
title({expri1,titnam},'fontsize',18)
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,ym(5:6),num2str(stday),'_',s_sth,s_edh,'_',num2str(length(hrs)),'hrs','min',num2str(minu(1)),num2str(minu(2))];
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
