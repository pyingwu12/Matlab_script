clear

%cexp=[0 0 1; 1 0 0; 0 1 0]; 
%exp={'szvrzh124';'szvrzh364';'szvrzh364L'};
%exp={'vrzh124';'vrzh364';'vrzh364L'};  cmap=[0.7 0.7 0.7; 0.2 0.75 0.2; 1 0.45 0.05];
%exp={'e01';'e02'};  exptext='_largens';  cmap=[0.2 0.75 0.2; 1 0.45 0.05];
exp={'e01';'e04';'e02';'e07'};  exptext='_largens';  cmap=[0.1 0.7 0.1; 0.6 0.9 0.5; 0.1 0.1 0.7; 0.5 0.6 0.9];

hm='00:00';  range=-15:5:15;  landid=0;  %landid=1:land, =-1:sea, else:all

%---experimental setting---
dom='02'; day='20080616';    % time setting
%obsdir='obs_morakot'; expdir='morakot_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/IOP8_morakot/';
%obsdir='obs_201206'; expdir='what_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/what/';
%obsdir='obs_sz6414'; expdir='sz_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/IOP8/';
obsdir='obs_sz6414'; expdir='largens_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/largens/';
%---
nexp=size(exp,1);
varinam='number of Zh impr.';   filenam='zh-impr_hist_';  

if landid==1; type='land'; elseif landid==-1; type='sea'; else type='all'; end

%--------------------------
len=length(range)+1;
hi=zeros(len,nexp);
%-----
for i=1:nexp 
   expri=[expdir,exp{i}];
   hi(:,i)=zh_cal_impr_hist(expri,range,hm,day,dom,obsdir,landid);
end

figure('position',[100 500 880 490]) 
hb=bar(1:len,hi);  
colormap(cmap);
legh=legend(exp,'Location','BestOutside'); set(legh,'fontsize',14)

set(gca,'fontsize',13,'XLim',[0 len+1],'XTick',0.5:len+0.5,'XTickLabel',[-inf,range,inf])
xlabel('improvement(dBZ)','fontsize',14);   ylabel('number(%)','fontsize',14);

tit=[varinam,'  ',hm(1:2),hm(4:5),'z (',type,')'];
title(tit,'fontsize',15)
outfile=[outdir,filenam,hm(1:2),hm(4:5),exptext,'_',type];
    
 set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
 system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
 system(['rm ',[outfile,'.pdf']]);  
    
