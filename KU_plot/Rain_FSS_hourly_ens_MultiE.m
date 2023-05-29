clear;  ccc=':';
close all

saveid=1; % save figure (1) or not (0)

%---setting      
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
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;

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
% cexp=[87 198 229; 24 126 218; 75 70 154;     242 155 0; 242 80 50; 155 55 55]/255; 



%---
plotid='FSS';
thres=1;  nnx=50; nny=nnx;
%---
sthrs=22:33; minu=[0 20 40];  acch=1; tint=1;
%---
year='2018'; mon='06'; stday=22;  
dom='01';  infilenam='wrfout';
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='Hourly rainfall';   fignam=['accum_',plotid,'_',exptext,'_'];

%
nexp=size(expri1,1);
nminu=length(minu); 
ntime=length(sthrs)*nminu;
%---
ntii=0;  fss=zeros(nexp,ntime);
%
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
       if exist([indir,'/',expri1{ei}],'dir') && ~exist(infile1,'file') 
        fss(ei,nti)=NaN;
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
      if isnan(fss(ei,nti))
          continue
      end
      rain1=double(rall1{2}-rall1{1});  rain1(rain1+1==1)=0;
      rain2=double(rall2{2}-rall2{1});  rain2(rain2+1==1)=0;     
      %--------------------
      fss(ei,nti)=FSS(rain1,rain2,nnx,nny,thres);
    end
  end %ti      
  disp([expri1{ei},' done'])
end %exp
fss(fss==0)=NaN;
%%
for ei=1:nexp/5
 fss_mean(ei,:)=mean(fss(5*(ei-1)+1:5*ei,:),1);
end
%---plot
linestyl={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};
%
hf=figure('position',[100 55 900 600]);
for ei=1:nexp
% for ei=[0*5+(1:5) 2*5+(1:5) 1*5+(1:5) 4*5+(1:5) 3*5+(1:5)]    
  colei=ceil(ei/5);
col=cexp(colei,:)+[0.3 0.15 0.3]; col(col>1)=1;
  plot(fss(ei,:),'LineWidth',2,'color',col); hold on
  if mod(ei,5)==0
      h(colei)=plot(fss_mean(colei,:),'LineWidth',3,'color',cexp(colei,:),'LineStyle','-'); 
  end
end
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',26,'location','sw','FontName','Consolas');
% set(gca,'Xlim',[0 ntime+1],'XTick',1:ntime,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
%
set(gca,'Xlim',[-1.5 ntime-1.5],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',20)
set(gca,'YLim',[0.1 1])

xlabel('Start time of hourly rainfall (LT)');  ylabel(plotid)
tit=[titnam,'  ',plotid,'  (n=',num2str(nnx),')'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',...
    num2str(length(sthrs)),'hr_',num2str(nminu),'min_acch',num2str(acch),'_thr',num2str(thres),'_n',num2str(nnx)];
if saveid~=0
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end