% close all
clear;  ccc=':';
%----------------

exptext='all'; 
expri={'TWIN001B';
       'TWIN017B';'TWIN013B';'TWIN022B';
       'TWIN025B';'TWIN019B';'TWIN024B';
       'TWIN021B';'TWIN003B';'TWIN020B';
       'TWIN023B';'TWIN016B';'TWIN018B'};  
   
 expnam={'FLAT';
        'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'TOPO';'V20H10';
        'V05H20';'V10H20';'V20H20'
        };
    
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  
    
cexp=[0.1 0.1 0.1; 
      0.32 0.8  0.95; 0    0.45 0.74; 0.01 0.11 0.63; 
      0.96 0.6  0.79; 0.78 0.19 0.67; 0.47 0.05 0.45;  
      0.95 0.8  0.13; 0.85 0.43 0.10; 0.70 0.08 0.18;
      0.65 0.85 0.35; 0.38 0.6  0.13; 0.01 0.48 0.15
      ];

%---setting
stday=22;  sth=22;  lenh=12;  minu=0:10:50;  tint=2;    typst='max';%mean/sum/max

year='2018'; mon='06'; infilenam='wrfout';  dom='01';  
scheme='WSM6';
%
% indir='/mnt/HDD003/pwin/Experiments/expri_test/'; outdir='/mnt/e/figures/expri_test';
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='Zh';    fignam=['Con_Ts-zh_',exptext,'_'];
%
nexp=size(expri,1);  nminu=length(minu);  ntime=lenh*nminu;
%---
zhall=zeros(nexp,ntime);  ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
for ei=1:nexp  
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1; ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d'); %xticks
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      infile = [indir,'/',expri{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      zh_max=cal_zh_cmpo(infile,'WSM6');        
      switch(typst)
      case('mean')
        zhall(ei,nti)=mean(mean(zh_max));
      case('max')
        zhall(ei,nti)=max(max(zh_max));
      case('min')
        zhall(ei,nti)=min(min(zh_max));
      end %switch   
    end %minu
    if mod(ti,5)==0; disp([s_hr,' done']); end
  end %ti
  disp([expri{ei},' done'])
end % expri

%%
%---plot---
hf=figure('position',[100 45 1000 600]);
for ei=1:nexp
  plot(zhall(ei,:),'color',cexp(ei,:),'Linestyle',lexp{ei},'LineWidth',2.8); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','best','FontName','Monospaced');
%
set(gca,'fontsize',16,'linewidth',1.2)
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Local time');  ylabel('Zh (dBZ)')

tit=[titnam,'  (domain ',typst,')  '];   
title(tit,'fontsize',18)
%
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_',typst];

print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
 %%
 
% hf=figure('position',[100 100 1200 500]);
% imagesc(zhall,[0 75])
% colorbar
% set(gca,'ytick',1:nexp,'yticklabel',expnam,'fontsize',16,'linewidth',1.2)
% set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
% xlabel('Local time');  
% 
% outfile=[outdir,'/',fignam,'imagesc_',mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_',typst];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
