close all
clear;  ccc=':';
saveid=1; % save figure (1) or not (0)
%----------------
%
% expri={'TWIN001B';'TWIN001Pr001qv062221';'TWIN003B';'TWIN003Pr001qv062221'};   exptext='NHMwspert';   bdy=0;  
% expnam={'FLAT_cntl';'FLAT_pert';'TOPO_cntl';'TOPO_pert'};
% dom={'01';'01';'01';'01'};
% lexp={'-';'--';'-';'--'};  
% cexp=[0  0.447  0.741; 0.3,0.745,0.933; 0.85,0.325,0.098;  0.929,0.694,0.125];


% expri={'TWIN001B';'TWIN030B';'TWIN042B';'TWIN039B';  'TWIN003B'; 'TWIN031B'; 'TWIN043B';'TWIN040B'}; 
% exptext='U00NS5U25';
% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';'U25_FLAT';  'TOPO';'NS5_TOPO';'U00_TOPO';'U25_TOPO'};
% cexp=[87 198 229; 44 125 190; 95 85 147;  24 88 139;     242 155 0; 232 66 44; 168 63 63; 117 79 58]/255; 

expri={'TWIN001B';'TWIN030B';'TWIN042B';  'TWIN003B'; 'TWIN031B'; 'TWIN043B'}; 
exptext='U00NS5';
expnam={'FLAT';'NS5_FLAT';'U00_FLAT';  'TOPO';'NS5_TOPO';'U00_TOPO'};
cexp=[87 198 229; 44 125 190; 95 85 147;     242 155 0; 232 66 44; 168 63 63]/255; 

% expri={'TWIN001B';'TWIN042B';'TWIN039B'}; 
% expnam={'FLAT';'U00_FLAT';'U25_FLAT'};
% cexp=[67 141 199; 109 191 230;  20 20 255]/255;
% exptext='U00U25';

% expri={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
% exptext='diffTOPO';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;



% exptext='alltopo';  
% expri={'TWIN001B';...
%         'TWIN017B';'TWIN013B';'TWIN022B';
%         'TWIN025B';'TWIN019B';'TWIN024B';
%         'TWIN021B';'TWIN003B';'TWIN020B';       
%         'TWIN023B';'TWIN016B';'TWIN018B'
%         };      
%     expnam={'FLAT';
%         'V05H05';'V10H05';'V20H05';
%         'V05H075';'V10H075';'V20H075';
%         'V05H10';'TOPO';'V20H10';
%         'V05H20';'V10H20';'V20H20'
%         };
%     cexp=[ 20 20 20;
%         75 190 237 ; 0  114  189;  5 55 160 ; 
%        245 153 202; 200 50 170; 140 30 135 
%        235 175 32 ;  220 85 25;  160 20 45;  
%        143 204 128;  97 153  48; 35 120 35 
%        ]/255;   
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  
dom={'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01'};

%---setting
stday=21;  sth=16;  lenh=70; minu=0:10:50; tint=6;  typst='mean';%mean/sum/max
ym='201806';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='2-m Temparature';    fignam=['T2_Ts_',exptext,'_'];
%
nexp=size(expri,1); nminu=length(minu);  ntime=lenh*nminu;

%---
plotvar=zeros(nexp,ntime);
for i=1:nexp
  plotvar(i,:)=cal_t2(indir,expri{i},ym,stday,sth,lenh,minu,dom{i},0,typst,ccc);
  disp([expri{i},' done'])
end

%---set x tick---
nti=0; ss_hr=cell(length(tint:tint:lenh),1);
for ti=tint:tint:lenh
  nti=nti+1;  
  ss_hr{nti}=num2str(mod(sth+ti-1+9,24),'%2.2d');
end
%%

% exptext='2ndpaper';  
% fignam=['T2_Ts_',exptext,'_'];
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
% plotid=[1 3 5 2 4];
plotid=1:nexp;
for i=plotid
   h(i)= plot(plotvar(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',4); hold on
end
%
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'location','southeast','FontName','Consolas');
set(legh,'Position',[0.475 0.1233 0.17 0.3006],'fontsize',25)

% legh=legend(h([1 3 8 9 10]),expnam{[1 3 8 9 10]},'Box','off','Interpreter','none','fontsize',30,'location','eastoutside','FontName','Consolas');
%
text(-6,294.8,'6/21','fontsize',20,'HorizontalAlignment', 'center')
text(138,294.8,'6/22','fontsize',20,'HorizontalAlignment', 'center')
text(282,294.8,'6/23','fontsize',20,'HorizontalAlignment', 'center')

%
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',20)
xlabel('Local time');  ylabel('K')
% tit=[titnam,'  (domain ',typst,')  '];   
tit='Domain-averaged 2-m temperature';  
title(tit,'fontsize',25)
%
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/2',fignam,ym(5:6),num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_',typst];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
 
