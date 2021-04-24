close all
clear;  ccc=':';
%-------------------------------
% expri={'TWIN001B';'TWIN001Pr001qv062221';'TWIN003B';'TWIN003Pr001qv062221'};   exptext='NHMwspert';   bdy=0;  
% expnam={'FLAT_cntl';'FLAT_pert';'TOPO_cntl';'TOPO_pert'};
dom={'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01';'01'};
% lexp={'-';'--';'-';'--'};  
% cexp=[0  0.447  0.741; 0.3,0.745,0.933; 0.85,0.325,0.098; 0.929,0.694,0.125];

exptext='all';  bdy=0;  

expri={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'
        };  
    
    expnam={'FLAT';
        'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'TOPO';'V20H10';
        'V05H20';'V10H20';'V20H20'};

    cexp=[ 20 20 20;
        75 190 237 ; 0  114  189;  5 55 160 ; 
       245 153 202; 200 50 170; 140 30 135 
       235 175 32 ;  220 85 25;  160 20 45;  
       143 204 128;  97 153  48; 35 120 35 ]/255;
   
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  


%---setting
sth=18;  lenh=24;  tint=2;  typst='mean';%mean/sum/max
ymdm='2018062200';  
%
% indir='/mnt/HDD003/pwin/Experiments/expri_test/'; outdir='/mnt/e/figures/expri_test';
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='Hourly rainfall';   fignam=['accum-hrly_',exptext,'_'];
nexp=size(expri,1);
%---
plotvar=zeros(nexp,lenh);
for i=1:nexp
   plotvar(i,:)=cal_accum_hrly(indir,expri{i},ymdm,sth,lenh,dom{i},bdy,typst,ccc);
   disp([expri{i},' done'])
end
%---------------------
%---set x tick---
nti=0; ss_hr=cell(length(tint:tint:lenh),1);
for ti=tint:tint:lenh
  nti=nti+1;  
  ss_hr{nti}=num2str(mod(sth+ti-1+9,24),'%2.2d');
end
%%
%---plot
hf=figure('position',[100 45 1000 600]);
for i=1:nexp
plot(1.5:lenh+0.5,plotvar(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'location','nw','FontName','Monospaced');
%
set(gca,'XLim',[1 lenh+1],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
%set(gca,'XLim',[20 lenh+1])
% set(gca,'Ylim',[0 1])
xlabel('Time (JST)');  ylabel('Rain rate (mm)')
tit=[titnam,'  (domain ',typst,')  '];   
title(tit,'fontsize',18)
%
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,ymdm(5:6),ymdm(7:8),'_',s_sth,ymdm(9:10),'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
