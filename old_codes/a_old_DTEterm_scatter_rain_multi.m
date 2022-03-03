
% plot scatter plot of summation of rainfall to mean of terms of DTE
% P.Y. Wu @ 2021.02.08

% close all
clear; ccc=':';

%---experiments---
% expri1 ={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp0103';
% expri2 ={'TWIN001B';'TWIN003B'};
% expnam ={'FLAT';'TOPO'};
% expmark={'s';'^'};
% 
expri1 ={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp13';
expri2 ={'TWIN001B';'TWIN003B'};
expnam ={'FLAT';'H10V10'};
expmark={'s';'^';'p'};

stday=22;   hrs=[24 25 26 27 28];  minu=[0 20 40];  
ploterm='LH'; % KE, ThE, LH, or DTE

%---area setting---
% xarea=1:150;  yarea=76:175; areatext='moun';
% xarea=151:300;  yarea=201:300; areatext='flat';
xarea=1:300;  yarea=1:300;  areatext='whole';
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
if strcmp(ploterm,'DTE')==1
  titnam='Rainfall to DTE';  fignam=['DTE2hyd_',exptext,'_'];
else
  titnam=['Rainfall to ',ploterm,' difference'];  fignam=['Diff',ploterm,'2hyd_',exptext,'_'];
end
%
load('colormap/colormap_ncl.mat');  col=colormap_ncl(35:10:end,:);
nexp=size(expri1,1); 

%---plot
hf=figure('Position',[100 65 900 500]);
for ei=1:nexp  
  nti=0;
  for ti=hrs 
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for tmi=minu
    %
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST']; 
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
%       zh_max2=cal_zh_cmpo(infile2,'WSM6');  zh_mean(nti)=mean(mean(  zh_max2(xarea,yarea)  ));

      if hr==0; s_hrr='23';                  s_dater=num2str(stday+hrday-1,'%2.2d'); 
      else;     s_hrr=num2str(hr-1,'%2.2d'); s_dater=s_date; end
      infile0=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_dater,'_',s_hrr,ccc,s_min,ccc,'00'];

      rain2 = ncread(infile2,'RAINC') + ncread(infile2,'RAINSH') + ncread(infile2,'RAINNC')...
              -  (ncread(infile0,'RAINC') + ncread(infile0,'RAINSH') + ncread(infile0,'RAINNC') );          
%       rain2_m = sum(sum(rain2(xarea,yarea)));
      rain2_m = max(max(rain2(xarea,yarea)));

      %---      
      [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2); 
      dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
      dPall = P.f2(:,:,end)-P.f2(:,:,1);
      dPm = dP./repmat(dPall,1,1,size(dP,3)); 
      %
      if strcmp(ploterm,'DTE')==1
        DTE3D = KE + ThE + LH ;
        DiffE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + Ps;
      else
        eval(['DiffE2D = sum(dPm.*',ploterm,'(:,:,1:end-1),3);'])
      end
      DiffE_m=mean(mean(DiffE2D(xarea,yarea)));  
      %---plot points---
%       plot(rain2_m,DiffE_m,expmark{ei},'MarkerSize',9,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:));    hold on  
      plot(DiffE_m,rain2_m,expmark{ei},'MarkerSize',9,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:));    hold on  

      
    end % mi
    disp([s_hr,s_min,' done'])
  end %ti  
  disp([expri2{ei},' done'])
end %ei

% set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','fontsize',16,'LineWidth',1.2) 

xlabel('Amount of rainfall (mm/h)'); 
ylabel(['Mean of ',ploterm,' (J/kg)']);
title([titnam,'  (area: ',areatext,')'],'fontsize',18)

%---colorbar for time legend----
L1=( (1:nti)*diff(caxis)/nti )  +  min(caxis()) -  diff(caxis)/nti/2;
hc=colorbar('YTick',L1,'YTickLabel',lgnd,'fontsize',13,'LineWidth',1.2);
colormap(col(1:nti,:))
%---plot legent for experiments---
xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
% for ei=1:nexp  
%   plot(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.5*ei) ,expmark{ei},'MarkerSize',10,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
%   text(10^(log10(xlimit(1))+0.4) , 10^(log10(ylimit(2))-0.5*ei) ,expnam{ei},'fontsize',18,'FontName','Monospaced'); 
% end
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(length(hrs)),'hrs','min',num2str(minu(1)),num2str(minu(2)),'_',areatext];
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);