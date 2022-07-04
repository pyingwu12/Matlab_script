close all
clear;  ccc='-';
saveid=0; % save figure (1) or not (0)
%-------------------------------
   
% expri={'TWIN201B';'TWIN030B';'TWIN042B';'TWIN039B';  'TWIN003B'; 'TWIN031B'; 'TWIN043B';'TWIN040B'}; 
% exptext='U00NS5U25';
% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';'U25_FLAT';  'TOPO';'NS5_TOPO';'U00_TOPO';'U25_TOPO'};
% cexp=[87 198 229; 44 125 190; 95 85 147;  24 88 139;     242 155 0; 232 66 44; 168 63 63; 117 79 58]/255; 

% expri={'TWIN201B';'TWIN030B';'TWIN042B';  'TWIN003B'; 'TWIN031B'; 'TWIN043B'}; 
% exptext='U00NS5';
% expnam={'FLAT';'NS5_FLAT';'U00_FLAT'; 'TOPO';'NS5_TOPO';'U00_TOPO'};
% % cexp=[87 198 229; 44 125 190; 95 85 147;    242 155 0; 232 66 44; 168 63 63]/255; 
% cexp=[87 198 229; 242 155 0;       24 126 218; 242 80 50;      75 70 154;  155 55 55]/255; %R3

expri={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
exptext='diffTOPO';
expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;

   
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  
dom={'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01'};

% expri={'TWIN001B';'TWIN003B'}; 
% exptext='FLATOPO';
% expnam={'FLAT';'TOPO'};
% cexp=[87 198 229; 242 155 0]/255; 
% lexp={'-';'-';'-'};  
% dom={'01';'01';'01'};

%---setting
sth=15;   lenh=71;   minu=0:10:50;  tint=6; 
typst='mean';%mean/sum/max
ymd='20180621';   bdy=0;  
%
% indir='/mnt/HDD003/pwin/Experiments/expri_test/'; outdir='/mnt/e/figures/expri_test';
%indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
% indir='E:expri_twin'; outdir='E:figures/expri_twin';
indir='D:expri_twin';  
outdir='G:/我的雲端硬碟/3.博班/研究/figures/expri_twin';
titnam='Hourly rainfall';   fignam=['accum-1h_Ts_',exptext,'_'];
%
nexp=size(expri,1); nminu=length(minu);  ntime=lenh*nminu;
%---
plotvar=zeros(nexp,ntime);
for i=1:nexp
   plotvar(i,:)=cal_accum_1h(indir,expri{i},ymd,sth,minu,lenh,dom{i},bdy,typst,ccc);
   disp([expri{i},' done'])
end
%---------------------
%---set x tick---
nti=0; ss_hr=cell(length(0:tint:lenh),1);
for ti=0:tint:lenh
  nti=nti+1;  
  ss_hr{nti}=num2str(mod(sth+ti+9,24),'%2.2d');
end
%%
% exptext='2ndpaper';  
% fignam=['accum-1h_Ts_',exptext,'_'];
% close all
%     cexp=[87 198 229 ;
%         75 190 237 ; 146 200 101;  5 55 160 ; 
%        245 153 202; 115 66 150; 140 30 135 
%        230 70 80 ;  242 155 0;  239 154 183;  
%        143 204 128; 154 170 178 ; 35 120 35 
%        ]/255;   
% lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  
%---plot
hf=figure('position',[100 45 1200 800]);
% hf=figure('position',[100 45 1400 800]);
plotid=[1 3 5 2 4];
% plotid=1:nexp;
for i=plotid
 h(i)=plot(1.5:ntime+0.5,plotvar(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',4); hold on
end
%
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',30,'location','eastoutside','FontName','Consolas');
%
% legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',30,'location','north','FontName','Consolas');
% set(legh,'Position',[0.31 0.5 0.1743 0.374])

% legh=legend(h([1 3 8 9 10]),expnam{[1 3 8 9 10]},'Box','off','Interpreter','none','fontsize',30,'location','eastoutside','FontName','Consolas');
%
text(0,-0.115,'6/22','fontsize',20,'HorizontalAlignment', 'center')
text(145,-0.115,'6/23','fontsize',20,'HorizontalAlignment', 'center')
text(289,-0.115,'6/24','fontsize',20,'HorizontalAlignment', 'center')


set(gca,'XLim',[1 ntime+1],'XTick',1 : tint*nminu : ntime ,'XTickLabel',ss_hr,'fontsize',20,'linewidth',1.5)
% set(gca,'XLim',[20 ntime-26])
set(gca,'Ylim',[0 1.3])
xlabel('Local time');  ylabel('mm')
tit=[titnam,'  (domain ',typst,')  '];   
% tit=['Domain-averaged hourly rainfall'];   
title(tit,'fontsize',25)
%
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,ymd(5:6),ymd(7:8),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_',typst];

if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
