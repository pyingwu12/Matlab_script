%------------------------------------------
% calculate different total engergy of two experiments
%------------------------------------------
close all
clear;  
%---
% expri1={'TWIN003Pr001qv062221';'TWIN017Pr001qv062221';'TWIN018Pr001qv062221'};   
% expri2={'TWIN003B';'TWIN017B';'TWIN018B'}; exptext='mountainsW1';
% expnam={'TOPO';'TOPOV05H05';'TOPOV2H2'};
% col=[0.85,0.325,0.098; 0.3,0.745,0.933; 0.494,0.184,0.556]; 

expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
      'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
        'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
        'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221';
        };
         
expri2={'TWIN001B';...
       'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
       'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B';
        };   
expnam={'FLAT';
       'v05h05';'v10h05';'v20h05';
    'v05h07';'v10h07';'v20h07';
       'v05h10';'v10h10';'v20h10';
        'v05h20';'v10h20';'v20h20'
        };
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  

col=[0.1 0.1 0.1; 
    0.3,0.745,0.933; 0  0.447  0.741;  0 0.3 0.55; 
  0.85,0.1,0.9; 0.494,0.184,0.556; 0.4 0.01 0.35;  
   0.49 0.8 0.22; 0.466,0.674,0.188; 0.3 0.45 0.01;  
    0.929,0.694,0.125; 0.85,0.325,0.098;  0.65,0.125,0.008;
    ];
%---
stday=22;  hrs=[21 22 23 24 25 26 27 28];  minu=[00 20 40];
lev=1:33;  
%--
% year='2018';  mon='06';
% infilenam='wrfout'; dom='01'; 
%
%indir='/mnt/HDD008/pwin/Experiments/expri_twin';  
outdir='/mnt/e/figures/expri_twin/';
titnam='moist DTE spectra';   fignam=['moDTE_growth',];
%
% load('colormap/colormap_ncl.mat')
% col0=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
%     191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
% col=col0(1:2:end,:);
nexp=size(expri1,1);
%---
for ei=1:nexp  
  KEp_kh{ei}=cal_DTEmo_spectr(expri1{ei}, expri2{ei}, stday, hrs, minu, lev);
  disp([expri1{ei},' done'])
end %ti

%%
%---set x tick---
tint=2;
ss_hr=cell(length(1:tint:length(hrs)),1); 
nti=0;
for ti=1:tint:length(hrs)
    nti=nti+1;
    ss_hr{nti}=num2str(mod(hrs(ti)+9,24),'%2.2d');
end
%%
wave_num=40;

hf=figure('position',[100 45 1000 660]) ;
for ei=1:nexp
plot(KEp_kh{ei}(wave_num,:),'linewidth',2.5,'linestyle',lexp{ei},'color',col(ei,:)); hold on
end
set(gca,'YScale','log')
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'Xlim',[1 length(hrs)*length(minu)],'XTick',1:tint*length(minu):length(minu)*length(hrs),'XTickLabel',ss_hr)
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Monospaced');
%%
hf=figure('position',[100 45 1000 660]) ;
for ei=1:nexp
plot(KEp_kh{ei}(wave_num,2:end)-KEp_kh{ei}(wave_num,1:end-1),'linewidth',2.5,'linestyle',lexp{ei},'color',col(ei,:)); hold on
end
%set(gca,'YScale','log')
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'Xlim',[1 length(hrs)*length(minu)],'XTick',1:tint*length(minu):length(minu)*length(hrs),'XTickLabel',ss_hr)
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Monospaced');
%%
for ei=1:nexp  
  KEp_kh_grow(:,:,ei)=KEp_kh{ei}(:,2:end)-KEp_kh{ei}(:,1:end-1);
end %ti
%%
wave_num=40;

hf=figure('position',[100 45 1000 660]) ;
for ei=1:nexp
plot(max(KEp_kh_grow(:,:,ei)),'linewidth',2.5,'linestyle',lexp{ei},'color',col(ei,:)); hold on
end
set(gca,'YScale','log')
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'Xlim',[1 length(hrs)*length(minu)],'XTick',1:tint*length(minu):length(minu)*length(hrs),'XTickLabel',ss_hr)
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Monospaced');