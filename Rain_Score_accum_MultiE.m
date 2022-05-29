clear;  ccc='-';
close all

saveid=1; % save figure (1) or not (0)

%---setting      

lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% cexp=[87 198 229; 242 155 0;   44 125 190;  232 66 44;   95 85 147; 168 63 63]/255; 

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
exptext0='TOPO';
expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;

% expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221mem2';'TWIN201Pr001qv062221mem3';'TWIN201Pr001qv062221mem4';'TWIN201Pr001qv062221mem5';
%         'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B'; 'TWIN201B';'TWIN201B';
%     'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B'}; 
% exptext='FLATOPOmem';
% expnam={'FLAT';'TOPO'};
% cexp=[87 198 229; 242 155 0]/255;

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00';
% expnam={'FLAT';'TOPO';'U00_FLAT';'U00_TOPO'};
% cexp=[87 198 229; 242 155 0;   95 85 147; 168 63 63]/255; 

% expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221mem2';'TWIN201Pr001qv062221mem3';'TWIN201Pr001qv062221mem4';'TWIN201Pr001qv062221mem5';
%         'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5';
%         'TWIN042Pr001qv062221';'TWIN042Pr001qv062221mem2';'TWIN042Pr001qv062221mem3';'TWIN042Pr001qv062221mem4';'TWIN042Pr001qv062221mem5';
%         'TWIN043Pr001qv062221';'TWIN043Pr001qv062221mem2';'TWIN043Pr001qv062221mem3';'TWIN043Pr001qv062221mem4';'TWIN043Pr001qv062221mem5'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B'; 'TWIN201B';'TWIN201B';
%     'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';
%     'TWIN042B';'TWIN042B';'TWIN042B';'TWIN042B';'TWIN042B';
%     'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B'}; 
% exptext='U00mem';
% expnam={'FLAT';'TOPO';'U00_FLAT';'U00_TOPO'};
% cexp=[87 198 229; 242 155 0;    75 70 154; 155 55 55 ]/255;

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
% exptext='diffTOPO';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255; 

plotarea=0;

%---setting
intm=20;
stday=22;  sthr=22;  accm=00:intm:720;   thres=1;  
year='2018'; mon='06';  dom='01';  infilenam='wrfout'; 
%
% indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
indir='D:expri_twin';   %outdir='D:figures\expri_twin';
outdir='G:/我的雲端硬碟/3.博班/研究/figures/expri_twin';
titnam='Rainfall SCC';  % fignam=['accum_score_',exptext,'_'];

nexp=size(expri1,1);
ntime=length(accm)-1;
%---
scc=zeros(nexp,ntime); %rmse=zeros(nexp,ntime); ETS=zeros(nexp,ntime); bias=zeros(nexp,ntime); 
for ei=1:nexp
  nti=0;     

  s_date=num2str(stday,'%2.2d');   s_hr=num2str(sthr,'%2.2d'); s_min= num2str(accm(1),'%2.2d');
  
  infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    rall1{1} = ncread(infile1,'RAINC');
    rall1{1} = rall1{1} + ncread(infile1,'RAINSH');
    rall1{1} = rall1{1} + ncread(infile1,'RAINNC');
  infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    rall2{1} = ncread(infile2,'RAINC');
    rall2{1} = rall2{1} + ncread(infile2,'RAINSH');
    rall2{1} = rall2{1} + ncread(infile2,'RAINNC');  
  
  for ai=accm(2:end)
      nti=nti+1;
     
      s_min=num2str(mod(ai,60),'%2.2d');
      s_hr=num2str(mod(sthr+fix(ai/60),24),'%2.2d');
      s_date=num2str(stday+fix( (sthr+fix(ai/60)) /24),'%2.2d'); 
      
      %------read netcdf data--------
      infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];      
      rall1{2} = ncread(infile1,'RAINC');
      rall1{2} = rall1{2} + ncread(infile1,'RAINSH');
      rall1{2} = rall1{2} + ncread(infile1,'RAINNC');
      %---
      infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      rall2{2} = ncread(infile2,'RAINC');
      rall2{2} = rall2{2} + ncread(infile2,'RAINSH');
      rall2{2} = rall2{2} + ncread(infile2,'RAINNC');   
      
      rain1=double(rall1{2}-rall1{1});
      rain2=double(rall2{2}-rall2{1});
      %--------------------
      [nx, ny]=size(rain1);
      [scc(ei,nti), ~, ~, ~]=cal_score(reshape(rain1,nx*ny,1),reshape(rain2,nx*ny,1),thres);     
% disp([s_date,s_hr,s_min,' done'])
  end %ai  
  disp([expri1{ei},' done'])
end %exp
%%

%---set title and filename text
  titext=['accumulated from ',num2str(mod(sthr+9,24),'%2.2d'),' LT'];
%   fitext=['from',num2str(sthr,'%2.2d'),'_',num2str(length(acch)),'acch'];
%%
%---plot
linestyl={'-';'-';'-';'-';':';':'};

exptext=[exptext0,'mem'];   fignam=['accum_score_',exptext,'_'];

hf=figure('position',[100 55 900 600]);
% for ei=[1 3 5 2 4 6]
 for ei=1:nexp    
     
  colei=ceil(ei/5);
  h(colei)=plot(scc(ei,:),'LineWidth',2,'color',cexp(colei,:)); hold on

%  h(ei)= plot(scc(ei,:),'LineWidth',5,'color',cexp(ei,:),'linestyle',linestyl{ei}); hold on
end
% legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'location','sw','FontName','Consolas');

set(gca,'Xlim',[0.5 ntime+0.5],'XTick',60/intm:60/intm:ntime,'XTickLabel',1:fix(ntime/(60/intm)),'fontsize',20,'linewidth',1.2)
set(gca,'Ylim',[0.2 1],'YTick',0:0.2:1)
xlabel('Accumulated period (h)');  ylabel('SCC')
tit=[titnam,' (',titext,')'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthr(1),'%2.2d'); s_edh=num2str(mod(sthr(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),num2str(sthr,'%2.2d'),num2str(accm(1),'%.2d'),'_',num2str(accm(end)),'m'];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
%%
exptext=[exptext0,'mean'];    fignam=['accum_score_',exptext,'_'];

for ei=1:nexp/5
 scc_mean(ei,:)=mean(scc(5*(ei-1)+1:5*ei,:),1);
end

hf=figure('position',[100 55 900 600]);
for ei=1:nexp/5
   h(ei)=plot(scc_mean(ei,:),'LineWidth',5,'color',cexp(ei,:)); hold on
end
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'location','sw','FontName','Consolas');

set(gca,'Xlim',[0.5 ntime+0.5],'XTick',60/intm:60/intm:ntime,'XTickLabel',1:fix(ntime/(60/intm)),'fontsize',20,'linewidth',1.2)
set(gca,'Ylim',[0.2 1],'YTick',0:0.2:1)
xlabel('Accumulated period (h)');  ylabel('SCC')
tit=[titnam,' (',titext,')'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthr(1),'%2.2d'); s_edh=num2str(mod(sthr(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),num2str(sthr,'%2.2d'),num2str(accm(1),'%.2d'),'_',num2str(accm(end)),'m'];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}