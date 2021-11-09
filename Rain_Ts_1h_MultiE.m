% close all
clear;  ccc=':';
saveid=1; % save figure (1) or not (0)
%-------------------------------

exptext='alltopo';  
expri={'TWIN201B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'
        };      
    expnam={'FLAT';
        'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'TOPO';'V20H10';
        'V05H20';'V10H20';'V20H20'
        };
    cexp=[ 20 20 20;
        75 190 237 ; 0  114  189;  5 55 160 ; 
       245 153 202; 200 50 170; 140 30 135 
       235 175 32 ;  220 85 25;  160 20 45;  
       143 204 128;  97 153  48; 35 120 35 
       ]/255;   
   
   
   
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
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
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
% hf=figure('position',[100 45 1000 600]);
hf=figure('position',[100 45 1400 800]);
plotid=[1 3 10 9 8 ];
for i=1:nexp
% for i=plotid
 h(i)=plot(1.5:ntime+0.5,plotvar(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',4); hold on
end
%
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',30,'location','eastoutside','FontName','Monospaced');
% legh=legend(h([1 3 8 9 10]),expnam{[1 3 8 9 10]},'Box','off','Interpreter','none','fontsize',30,'location','eastoutside','FontName','Monospaced');
%
% text(0,-0.08,'6/21','fontsize',20,'HorizontalAlignment', 'center')
% text(145,-0.08,'6/22','fontsize',20,'HorizontalAlignment', 'center')
% text(289,-0.08,'6/23','fontsize',20,'HorizontalAlignment', 'center')


set(gca,'XLim',[1 ntime+1],'XTick',1 : tint*nminu : ntime ,'XTickLabel',ss_hr,'fontsize',20,'linewidth',1.5)
% set(gca,'XLim',[20 ntime-26])
% set(gca,'Ylim',[0 1])
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
