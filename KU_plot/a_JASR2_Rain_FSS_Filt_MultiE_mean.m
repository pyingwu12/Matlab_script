% close all
clear; ccc=':';
%---setting

saveid=1; % save figure (1) or not (0)

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
% exptext='diffTOPO';
% % expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% expnam={'ORI_H00V00';'ORI_H10V10';'ORI_H05V10';'ORI_H10V05';'ORI_H10V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 84 80; 239 144 185]/255; 

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00NS5';
% % expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% expnam={'ORI_H00V00';'ORI_H10V10';'NS5_H00V00';'NS5_H10V10';'U00_H00V00';'U00_H10V10'};
% cexp=[87 198 229; 242 155 0;       24 126 218; 242 80 50;      75 70 154;  155 55 55]/255;
%----

expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221mem2';'TWIN201Pr001qv062221mem3';'TWIN201Pr001qv062221mem4';'TWIN201Pr001qv062221mem5';
        'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5';
        'TWIN013Pr001qv062221';'TWIN013Pr001qv062221mem2';'TWIN013Pr001qv062221mem3';'TWIN013Pr001qv062221mem4';'TWIN013Pr001qv062221mem5';
        'TWIN021Pr001qv062221';'TWIN021Pr001qv062221mem2';'TWIN021Pr001qv062221mem3';'TWIN021Pr001qv062221mem4';'TWIN021Pr001qv062221mem5'; 
        'TWIN020Pr001qv062221';'TWIN020Pr001qv062221mem2';'TWIN020Pr001qv062221mem3';'TWIN020Pr001qv062221mem4';'TWIN020Pr001qv062221mem5'};   
expri2={'TWIN201B';'TWIN201B';'TWIN201B'; 'TWIN201B';'TWIN201B';
    'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';
    'TWIN013B';'TWIN013B';'TWIN013B';'TWIN013B';'TWIN013B';
    'TWIN021B';'TWIN021B';'TWIN021B';'TWIN021B';'TWIN021B';
    'TWIN020B';'TWIN020B';'TWIN020B';'TWIN020B';'TWIN020B'}; 
exptext='TOPO';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
expnam={'ORI_H00V00';'ORI_H10V10';'ORI_H05V10';'ORI_H10V05';'ORI_H10V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;
plotexp=[1 3 2 5 4]-1;

% expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221mem2';'TWIN201Pr001qv062221mem3';'TWIN201Pr001qv062221mem4';'TWIN201Pr001qv062221mem5';
%         'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5';
%         'TWIN030Pr001qv062221';'TWIN030Pr001qv062221mem2';'TWIN030Pr001qv062221mem3';'TWIN030Pr001qv062221mem4';'TWIN030Pr001qv062221mem5';
%         'TWIN031Pr001qv062221';'TWIN031Pr001qv062221mem2';'TWIN031Pr001qv062221mem3';'TWIN031Pr001qv062221mem4';'TWIN031Pr001qv062221mem5';
%         'TWIN042Pr001qv062221';'TWIN042Pr001qv062221mem2';'TWIN042Pr001qv062221mem3';'TWIN042Pr001qv062221mem4';'TWIN042Pr001qv062221mem5';
%         'TWIN043Pr001qv062221';'TWIN043Pr001qv062221mem2';'TWIN043Pr001qv062221mem3';'TWIN043Pr001qv062221mem4';'TWIN043Pr001qv062221mem5'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B'; 'TWIN201B';'TWIN201B';
%     'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';
%     'TWIN030B';'TWIN030B';'TWIN030B';'TWIN030B';'TWIN030B';
%     'TWIN031B';'TWIN031B';'TWIN031B';'TWIN031B';'TWIN031B';
%     'TWIN042B';'TWIN042B';'TWIN042B';'TWIN042B';'TWIN042B';
%     'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B'}; 
% exptext='U00NS5';
% % expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% expnam={'ORI_H00V00';'ORI_H10V10';'NS5_H00V00';'NS5_H10V10';'U00_H00V00';'U00_H10V10'};
% cexp=[87 198 229; 242 155 0;   24 126 218;  242 80 50;    75 70 154; 155 55 55 ]/255;
% plotexp=[1 3 5 2 4 6]-1;

% 
% timemark={'o';'^';'s';'p';'v';'d';'h'};


% stday=23;   sthrs=[2 4 6 8];   acch=[1];
stday=23;   sthrs=[2 5 8];   acch=[1];

scales=[1 3 5 10 15 20 25 35 40 45 50 60 70 80 90 100]; 


thres=1; 
%---
year='2018'; mon='06';  s_min='00';  
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir='/mnt/e/figures/expri_twin/JAS_R2';
% indir='D:expri_twin';   %outdir='D:figures\expri_twin';
% outdir='G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin';
%
titnam='FSS at different scales';   fignam=['accum-fss-scale_',exptext,'_'];
%
nexp=size(expri1,1);
nscale=length(scales);
ntime=length(sthrs)*length(acch);
%---
lgndi=0;  fss=zeros(nexp,ntime,nscale); fss_use=zeros(nexp,ntime);
for ei=1:nexp
nti=0;
for ti=sthrs
  for ai=acch
    nti=nti+1;
    for j=1:2
      hr=(j-1)*ai+ti;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
      %---infile 1, perturbed state---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      rall1{j} = ncread(infile1,'RAINC');
      rall1{j} = rall1{j} + ncread(infile1,'RAINSH');
      rall1{j} = rall1{j} + ncread(infile1,'RAINNC');
      %---infile 2, based state---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      rall2{j} = ncread(infile2,'RAINC');
      rall2{j} = rall2{j} + ncread(infile2,'RAINSH');
      rall2{j} = rall2{j} + ncread(infile2,'RAINNC');
    end %j=1:2    
    rain1=double(rall1{2}-rall1{1});   rain1(rain1+1==1)=0;
    rain2=double(rall2{2}-rall2{1});   rain2(rain2+1==1)=0;

    %---- 
    nxi=0;
    for nxi=1:nscale
      nnx=scales(nxi); nny=nnx;
      if nxi==1
        [fss(ei,nti,nxi), fss_use(ei,nti)]=cal_FSS(rain1,rain2,nnx,nny,thres);    
      else
        [fss(ei,nti,nxi), ~]=cal_FSS(rain1,rain2,nnx,nny,thres);
      end
    end

  end %acch  
end %ti
disp([expri1{ei},' done'])
end %exp
%---cal mean
for ei=1:nexp/5
 fss_mean(ei,:,:)=mean(fss(5*(ei-1)+1:5*ei,:,:),1);
 fss_use_mean(ei,:)=fss_use(5*(ei-1)+1,:);
end
%%
close all
% hf=figure('position',[100 55 1200 600]);
hf=figure('position',[100 55 900 650]);

% linestyl={':';'--';'-.';'-'};  linewidth=[3 2 3.5 2]; 
linestyl={':';'-';'-.';'-'};  linewidth=[3 4 3 2]; 

  for ti=1:ntime   
      for ei=plotexp+1

    if ti==2
     h(ei)=plot(squeeze(fss_mean(ei,ti,:)),'LineWidth',linewidth(ti),'color',cexp(ei,:),'linestyle',linestyl{ti}); hold on
    else
     plot(squeeze(fss_mean(ei,ti,:)),'LineWidth',linewidth(ti),'color',cexp(ei,:),'linestyle',linestyl{ti}); hold on   
    end
  end
end
%---skillful threshold marker
tmarker={'s';'^';'+'}; markersize=[10 11 13 ]; linewd=[1.5 1 2.8 ];
  for ti=1:ntime
      for ei=plotexp+1

    skidx=(find(fss_mean(ei,ti,:)>=fss_use_mean(ei,ti),1)); % the scale with score higher than skillful threshold
     cexp2=cexp-0.2; cexp2(cexp2<0)=0;
    plot(skidx,fss_mean(ei,ti,skidx),tmarker{ti},'color',cexp2(ei,:),...
         'MarkerFaceColor',cexp(ei,:),'MarkerSize',markersize(ti),'linewidth',linewd(ti))
  end
end 
%
lh=legend(h,expnam);
% set(lh,'fontsize',22,'Location','southeast','FontName','Monospaced','box','off','Interpreter','none','NumColumns',2)
set(lh,'fontsize',22,'Location','southeast','FontName','Monospaced','box','off','Interpreter','none')
%
set(gca,'Ylim',[0.05 1])
set(gca,'xtick',1:length(scales),'Xticklabel',scales,'xlim',[1 length(scales)],'fontsize',18,'LineWidth',1.2)
xlabel('Length (km)'); ylabel('FSS');
tit=titnam;  title(tit,'fontsize',18)
%
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',num2str(length(sthrs)),'sth',num2str(sthrs([1,end]),'%2.2d'),'_'...
         ,num2str(length(acch)),'acch_',num2str(nscale),'scl'];
if saveid~=0
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end