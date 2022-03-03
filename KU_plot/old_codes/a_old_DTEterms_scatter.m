
% close all
clear; ccc=':';
%---setting 
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
stday=22;   hrs=[23 24 25 26 27];  minu=[0 20 40];  

% xarea=1:150;  yarea=76:175; areatext='moun';
% xarea=151:300;  yarea=201:300; areatext='flat';
xarea=1:300;  yarea=1:300; areatext='whole';


%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='cloud amount to moist DTE';  
fignam=[expri1(8:end),'_cloud-DTE_'];
%
load('colormap/colormap_ncl.mat')
col=colormap_ncl(35:10:end,:);
%%

%---plot
hf=figure('Position',[100 65 900 500]);

nti=0;  j=1;
for ti=hrs 
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  for tmi=minu
    %
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      lgnd=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST']; 
      %---infile 1---
      infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
%       zh_max2=cal_zh_cmpo(infile2,'WSM6');  
%       zh_mean(nti)=mean(mean(  zh_max2(xarea,yarea)  ));
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd = sum(qr+qc+qg+qs+qi,3); 
      hyd_m=sum(sum(hyd(xarea,yarea)));     
      
      %---
      
      [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2);
 
      dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
      dPall = P.f2(:,:,end)-P.f2(:,:,1);
      dPm = dP./repmat(dPall,1,1,size(dP,3)); 
 
      KE2D = sum(dPm.*KE(:,:,1:end-1),3);     KE2D_m=mean(mean(KE2D(xarea,yarea)));
      ThE2D = sum(dPm.*ThE(:,:,1:end-1),3);   ThE2D_m=mean(mean(ThE2D(xarea,yarea)));
      LH2D = sum(dPm.*LH(:,:,1:end-1),3);     LH2D_m=mean(mean(LH2D(xarea,yarea)));
      
      %----
      
      plot(hyd_m,KE2D_m,'^','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:)); hold on 
      plot(hyd_m,LH2D_m,'o','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:));
      plot(hyd_m,ThE2D_m,'s','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:));

      plot(0.004,10^(-2.8+0.23*nti),'o','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:));
      text(0.005,10^(-2.8+0.23*nti),lgnd);

  end % mi
  disp([s_hr,s_min,' done'])
end %ti

% legend(lgnd,'Interpreter','none','fontsize',18,'Location','bestoutside');
set(gca,'fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','Yscale','log')
set(gca,'XLim',[2e-4 1e3],'YLim',[1e-4 1e1])
% xlabel({'Size (km)';'(Diameter of circle with the same area)'}); 
% ylabel({'(Mean of first 10 maximum)','Moist DTE'});
title({expri1,titnam},'fontsize',18)
% %
% s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
% outfile=[outdir,'/',fignam,ym(5:6),num2str(stday),'_',s_sth,s_edh,'_',num2str(length(hrs)),'hrs','min',num2str(minu(1)),num2str(minu(2))];
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
