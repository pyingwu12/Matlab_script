% function DTEterm_2_cldarea_size(expri,ploterm)
% plot scatter plot of cloud size to moist DTE over the cloud area
%   the cloud area is detected by the funtion <cal_cloudarea_1time>
%----------------
% one experiment; x-axis: size of cloud area; y-axis: error; color: time 
%----------------
% P.Y. Wu @ 2021.02.05
% 2021/02/11: add <ploterm> option for calculating different terms in the MDTE
% 2021/06/10: standerize variable name of time settings

close all; clear; ccc=':';
%---setting 
ploterm='MDTE'; % option: MDTE, CMDTE,  KE, KE3D, SH, LH
expri='TWIN014';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
% expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];  
stday=22;   hrs=[22 23 24 25 26 27];  minu=[20 50];  
% stday=22;   hrs=[23 24 25 26];  minu=0:10:50;  
%
cloudhyd=0.005;  % threshold of definition of cloud area (Kg/Kg)
areasize=10;     % threshold of finding cloud area (gird numbers)
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam=['size of cloud area to ',ploterm];   fignam=[expri1(8:end),'_cloud-',ploterm,'_'];
%
nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%
fload=load('colormap/colormap_ncl.mat');
col=fload.colormap_ncl([3 8 17 32 58 81 99 126 147 160 179 203],:);
% col=fload.colormap_ncl(13:10:end,:);
%
%---
hf=figure('Position',[100 65 900 480]);
nti=0;  ntii=0; 
for ti=hrs 
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  for mi=minu
    nti=nti+1;      s_min=num2str(mi,'%2.2d');     
    %---infile 1---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---    
    cloud=cal_cloudarea_1time(infile1,infile2,areasize,cloudhyd,ploterm);    
    if ~isempty(cloud) 
      ntii=ntii+1;   lgnd{ntii}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST']; 
%       neartopo=find(cloud.todis<=75);
%       fartopo=find(cloud.todis>75);
      if nti<=3
       plot(cloud.scale,cloud.maxdte,'o','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',[0.1 0.1 0.1],'linewidth',1.3); hold on   
      else
%       plot(cloud.scale(neartopo),cloud.maxdte(neartopo),'^','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:)); hold on  
       plot(cloud.scale,cloud.maxdte,'o','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:)); hold on   
      end
%       plot(cloud.scale(neartopo),cloud.maxdte(neartopo),'o','MarkerSize',8,'MarkerFaceColor','none','MarkerEdgeColor',[0.1 0.1 0.1],'linewidth',1.3); 
      %----
      disp([s_hr,s_min,' done'])
    end % if ~isempty(cloud)
  end % mi
end %ti

legend(lgnd,'Interpreter','none','fontsize',18,'Location','bestoutside');
set(gca,'fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','Yscale','log')
set(gca,'XLim',[3.5 1e2],'YLim',[2e-2 2e2])
% set(gca,'XLim',[3.5 1e2],'YLim',[2e-2 6e2])
xlabel({'Size (km)';'(Diameter of circle with the same area)'}); 
ylabel({'(Mean of first 10 maximum)',[ploterm,' ( J kg^-^1)']});
title({expri1,titnam},'fontsize',18)
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
