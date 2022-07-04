clear;  ccc=':';
close all

saveid=1; % save figure (1) or not (0)

%---setting        
% exptext='FLATOPOdiffpert';
% expri1={'TWIN201Pr01qv062221';'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';'TWIN201Pr001qv062223';'TWIN201Pr001qv062301'
%         'TWIN003Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221';'TWIN003Pr001qv062223';'TWIN003Pr001qv062301' };   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B'
%         'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B'}; 
% expnam={'FLAT_P10';'FLAT';'FLAT_P01';'FLAT_08LT';'FLAT_10LT'
%         'TOPO_P10';'TOPO';'TOPO_P01';'TOPO_08LT';'TOPO_10LT'};
% cexp=[62 158 209;   87 198 229;  154 211 237;     158 169 98;  189 223 110;
%       230 101 99;     242 155 0;   240 220 20;      240 143 152; 246 209 223  ]/255;
  
% expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221mem2';'TWIN201Pr001qv062221mem3';'TWIN201Pr001qv062221mem4';'TWIN201Pr001qv062221mem5';
%         'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5';
%         'TWIN013Pr001qv062221';'TWIN013Pr001qv062221mem2';'TWIN013Pr001qv062221mem3';'TWIN013Pr001qv062221mem4';'TWIN013Pr001qv062221mem5';
%         'TWIN021Pr001qv062221';'TWIN021Pr001qv062221mem2';'TWIN021Pr001qv062221mem3';'TWIN021Pr001qv062221mem4';'TWIN021Pr001qv062221mem5'; 
%         'TWIN020Pr001qv062221';'TWIN020Pr001qv062221mem2';'TWIN020Pr001qv062221mem3';'TWIN020Pr001qv062221mem4';'TWIN020Pr001qv062221mem5'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B'; 'TWIN201B';'TWIN201B';
%     'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';
%     'TWIN013B';'TWIN013B';'TWIN013B';'TWIN013B';'TWIN013B';
%     'TWIN021B';'TWIN021B';'TWIN021B';'TWIN021B';'TWIN021B';
%     'TWIN020B';'TWIN020B';'TWIN020B';'TWIN020B';'TWIN020B'}; 
% exptext='TOPO';
% % expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% expnam={'ORI_H00V00';'ORI_H10V10';'ORI_H05V10';'ORI_H10V05';'ORI_H10V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;
% plotexp=[1 3 2 5 4]-1;
% 

expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221mem2';'TWIN201Pr001qv062221mem3';'TWIN201Pr001qv062221mem4';'TWIN201Pr001qv062221mem5';
        'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5';
        'TWIN030Pr001qv062221';'TWIN030Pr001qv062221mem2';'TWIN030Pr001qv062221mem3';'TWIN030Pr001qv062221mem4';'TWIN030Pr001qv062221mem5';
        'TWIN031Pr001qv062221';'TWIN031Pr001qv062221mem2';'TWIN031Pr001qv062221mem3';'TWIN031Pr001qv062221mem4';'TWIN031Pr001qv062221mem5';
        'TWIN042Pr001qv062221';'TWIN042Pr001qv062221mem2';'TWIN042Pr001qv062221mem3';'TWIN042Pr001qv062221mem4';'TWIN042Pr001qv062221mem5';
        'TWIN043Pr001qv062221';'TWIN043Pr001qv062221mem2';'TWIN043Pr001qv062221mem3';'TWIN043Pr001qv062221mem4';'TWIN043Pr001qv062221mem5'};   
expri2={'TWIN201B';'TWIN201B';'TWIN201B'; 'TWIN201B';'TWIN201B';
    'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';
    'TWIN030B';'TWIN030B';'TWIN030B';'TWIN030B';'TWIN030B';
    'TWIN031B';'TWIN031B';'TWIN031B';'TWIN031B';'TWIN031B';
    'TWIN042B';'TWIN042B';'TWIN042B';'TWIN042B';'TWIN042B';
    'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B'}; 
exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
expnam={'ORI_H00V00';'ORI_H10V10';'NS5_H00V00';'NS5_H10V10';'U00_H00V00';'U00_H10V10'};
cexp=[87 198 229; 242 155 0;   24 126 218;  242 80 50;    75 70 154; 155 55 55 ]/255;
plotexp=[5 3 1 2 6 4]-1;



plotid='FSS';  thres=1; nnx=1; nny=nnx;
%---setting
% sthrs=22:33;   minu=0:10:50;  acch=1;
sthrs=22:33;   minu=[0 20 40];  acch=1;
 tint=1;
year='2018'; mon='06'; stday=22;  
dom='01';  infilenam='wrfout';
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
% indir='E:expri_twin'; outdir='E:figures/expri_twin';
% indir='D:expri_twin';   %outdir='D:figures\expri_twin';
% outdir='G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin';
titnam='Hourly rainfall';   %fignam=['accum1h_',plotid,'_',exptext,'_'];


nexp=size(expri1,1);
 nminu=length(minu); 
ntime=length(sthrs)*nminu;
%---
ntii=0;
FSS=zeros(nexp,ntime); 
%%
for ei=1:nexp
  nti=0;  
  if ~exist([indir,'/',expri1{ei}],'dir')
     continue
  end
  for ti=sthrs
    if mod(ti-sthrs(1),tint)==0 && ei==1
       ntii=ntii+1;    ss_hr{ntii}=num2str(mod(ti+9,24),'%2.2d');
    end 
    for tmi=minu
      nti=nti+1;  rall1=cell(1,2); rall2=cell(1,2); 
      s_min=num2str(tmi,'%2.2d');  
      for j=1:2
       hr=(j-1)*acch+ti;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
       %------read netcdf data--------
       infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
%        if nti==12; disp(infile1); end
       if exist([indir,'/',expri1{ei}],'dir') && ~exist(infile1,'file') 
        FSS(ei,nti)=NaN;
        continue
       end
       rall1{j} = ncread(infile1,'RAINC');
       rall1{j} = rall1{j} + ncread(infile1,'RAINSH');
       rall1{j} = rall1{j} + ncread(infile1,'RAINNC');
       %---
       infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
       rall2{j} = ncread(infile2,'RAINC');
       rall2{j} = rall2{j} + ncread(infile2,'RAINSH');
       rall2{j} = rall2{j} + ncread(infile2,'RAINNC');   
      end %j=1:2      
      if isnan(FSS(ei,nti))
          continue
      end
      rain1=double(rall1{2}-rall1{1});  rain1(rain1+1==1)=0;
      rain2=double(rall2{2}-rall2{1});  rain2(rain2+1==1)=0;     
      %--------------------
      [nx, ny]=size(rain1);
%       [SCC(ei,nti), RMSE(ei,nti), ~, ~]=cal_score(reshape(rain1,nx*ny,1),reshape(rain2,nx*ny,1),thres);  
      FSS(ei,nti)=cal_FSS(rain1,rain2,nnx,nny,thres);    
 
    end
  end %ti      
  disp([expri1{ei},' done'])
end %exp
%%
eval(['rain_score=',plotid,';'])
rain_score(rain_score==0)=NaN;     
%%
%---plot

% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';'TOPO';'NS5_TOPO';'U00_TOPO'};
% linestyl={'-';'-';'-';'-';':';':'};
% linestyl={'-';'-';'-';':';':';'-';'-';'-';':';':'};
linestyl={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};

%%
exptext1=[exptext,'mem'];  fignam=['accum1h_',plotid,'_',exptext1,'_'];
hf=figure('position',[100 55 900 600]);

for ei0=1:nexp/5
for ei=plotexp(ei0)*5+(1:5)
    
  colei=ceil(ei/5);
  h(colei)=plot(rain_score(ei,:),'LineWidth',2,'color',cexp(colei,:)); hold on

end
end
set(gca,'Xlim',[-1.5 ntime-1.5],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime+1,'XTickLabel',7:19,'Linewidth',1.2,'fontsize',20)
set(gca,'YLim',[0 1],'YTick',0.2:0.2:1)

xlabel('Start time of hourly rainfall (LT)');  ylabel(plotid)
tit=[titnam,'  ',plotid];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',num2str(length(sthrs)),'hr_',num2str(nminu),'min_acch',num2str(acch),'_thr',num2str(thres),'_n',num2str(nnx)];
if saveid~=0
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%% ens mean

exptext1=[exptext,'mean'];  fignam=['accum1h_',plotid,'_',exptext1,'_'];

for ei=1:nexp/5
 score_mean(ei,:)=mean(rain_score(5*(ei-1)+1:5*ei,:),1);
end
hf=figure('position',[100 55 900 600]);

for ei=plotexp+1
   h(ei)=plot(score_mean(ei,:),'LineWidth',5,'color',cexp(ei,:)); hold on
end
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',26,'location','sw','FontName','Monospaced');
%
% set(gca,'Xlim',[0 ntime+1],'XTick',1:ntime,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
set(gca,'Xlim',[-1.5 ntime-1.5],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime+1,'XTickLabel',7:19,'Linewidth',1.2,'fontsize',20)
set(gca,'YLim',[0 1],'YTick',0.2:0.2:1)

xlabel('Start time of hourly rainfall (LT)');  ylabel(plotid)
tit=[titnam,'  ',plotid];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',num2str(length(sthrs)),'hr_',num2str(nminu),'min_acch',num2str(acch),'_thr',num2str(thres),'_n',num2str(nnx)];
if saveid~=0
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%% ens spread

exptext1=[exptext,'sprd'];  fignam=['accum1h_',plotid,'_',exptext1,'_'];

for ei=1:nexp/5
spread(ei,:) = (mean((rain_score( 5*(ei-1)+1:5*ei ,:)-score_mean(ei,:)).^2,1)).^0.5;
end
%---plot
hf=figure('position',[100 55 900 200]);
for ei=plotexp+1
   h(ei)=plot(spread(ei,:),'LineWidth',2,'color',cexp(ei,:)); hold on
end
% legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',26,'location','sw','FontName','Monospaced');
%
% set(gca,'Xlim',[0 ntime+1],'XTick',1:ntime,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
set(gca,'Xlim',[-1.5 ntime-1.5],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime+1,'XTickLabel',7:19,'Linewidth',1.2,'fontsize',20)
set(gca,'YLim',[0 0.1],'YTick',[0 0.05 0.1])

xlabel('Start time of hourly rainfall (LT)');  ylabel('spread')
% tit=[titnam,'  ',plotid];   
% title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',num2str(length(sthrs)),'hr_',num2str(nminu),'min_acch',num2str(acch),'_thr',num2str(thres),'_n',num2str(nnx)];
if saveid~=0
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end