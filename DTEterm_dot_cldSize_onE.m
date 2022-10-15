% function DTEterm_dot_cldSize_onE(expri,cloudtpw)
% plot scatter plot of cloud size to moist DTE over the cloud area
%   the cloud area is detected by the funtion <cal_cloudarea_1time>
%----------------
% one experiment; x-axis: size of cloud area; y-axis: error; color: time 
%----------------
% P.Y. Wu @ 2021.02.05
% 2021/02/11: add <ploterm> option for calculating different terms in the MDTE
% 2021/06/10: standerize variable name of time settings
% 2021/08/05: change cloud area criteria to TPW=0.7

close all; 
clear; 
ccc='-';
saveid=1;
%---setting 
ploterm='CMDTE'; % option: MDTE, CMDTE,  KE, KE3D, SH, LH
expri='TWIN201'; 
% expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
% expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];  
expri1=[expri,'Prl001qv062221'];  expri2=[expri,'B'];  
% day=22;   hrs=[27 26 25 24 23];  minu=[30 0];  
% day=22;   hrs=[26 25 24 23];  minu=[40 20 0]; 
day=22;   hrs=[27 26 25 24 23];  minu=[50 20];  %thesis F3.9
% day=22;   hrs=[25 24 23];  minu=50:-10:0;  
% day=23;   hrs=2;  minu=20;  %day=23;   hrs=0;  minu=50;

% cloudhyd=0.003;  % threshold of definition of cloud area (Kg/Kg)
cloudtpw=0.7;
% cloudtpw=0.3;
% cloudtpw=0.7;

areasize=10;     % threshold of finding cloud area (gird numbers)
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
% indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/JAS_R1'];
% indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
indir='D:expri_twin';   outdir=['G:/我的雲端硬碟/3.博班/研究/figures/expri_twin/',expri]; %outdir=['D:figures/',expri];
titnam=['size of cloud area to ',ploterm];   %fignam=[expri1(8:end),'_cloud-',ploterm,'_'];
 fignam=[expri1,'_cloud-',ploterm,'_'];
%
nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%
fload=load('colormap/colormap_ncl.mat');
% col=fload.colormap_ncl([3 8 17 32 58 81 99 126 147 160 179 203],:);
% col=fload.colormap_ncl([81],:);
% col=fload.colormap_ncl([147],:);
% col=fload.colormap_ncl(30:13:end,:);
% col=fload.colormap_ncl(30:28:end,:);
col=fload.colormap_ncl([17 32 58 81 99 126 147 160 179 203 219 242],:);% %thesis F3.9
% col=fload.colormap_ncl(30:15:end,:); %thesis 2?

alp=0.8;
% alp=1;
%
%---
hf=figure('Position',[100 65 900 480]);
% hf=figure('Position',[100 65 900 580]);
nti=0;  ntii=0; 
for ti=hrs 
  hr=ti;   s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  for mi=minu
    nti=nti+1;      s_min=num2str(mi,'%2.2d');     
    %---infile 1---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---        
%    cloud=cal_cloudarea_1time(infile1,infile2,areasize,cloudhyd,ploterm);   
%    cloud=cal_cloudarea_1time_subdom(infile1,infile2,areasize,cloudhyd,ploterm,1,300,76,225);
    cloud=cal_cloudarea_1time(infile1,infile2,areasize,cloudtpw,ploterm);   
    if ~isempty(cloud) 
      ntii=ntii+1;   lgnd{ntii}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
%      plot(cloud.scale,cloud.maxdte,'o','MarkerSize',8,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:)); hold on   
      scatter(cloud.size,cloud.maxdte,120,'o','MarkerEdgeColor',col(nti,:),'MarkerFaceColor',col(nti,:),'MarkerFaceAlpha',alp); hold on

% scatter(cloud.scale,cloud.maxdte,120,'o','MarkerEdgeColor',col(nti,:),'MarkerFaceColor',col(nti,:),'MarkerFaceAlpha',alp); hold on
      %----
      disp([s_hr,s_min,' done'])
    end % if ~isempty(cloud)
  end % mi
end %ti

legend(lgnd,'Interpreter','none','fontsize',20,'Location','bestoutside','box','off');

set(gca,'fontsize',18,'LineWidth',1.2,'box','on') 
set(gca,'Xscale','log','Yscale','log')
% set(gca,'XLim',[10 1e4],'YLim',[8e-3 4e2])
set(gca,'XLim',[10 1e4],'YLim',[2e-3 4e2])
% set(gca,'XLim',[3.5 1e2],'YLim',[2e-2 2e2])
% set(gca,'XLim',[3.5 1e2],'YLim',[2e-2 4e2])
%  set(gca,'XLim',[3.5 1e2],'YLim',[1e-4 4e2])
xlabel({'Size';'(Grid numbers)'}); 
ylabel({'(Mean of first 10 maximum)',[ploterm,' ( J kg^-^1)']});
title({expri1,titnam},'fontsize',18)
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
% outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),'_hyd',num2str(cloudhyd*1e3)];
outfile=[outdir,'/',fignam,mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),'_tpw',num2str(cloudtpw*100,'%.3d')];
if saveid~=0
print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end