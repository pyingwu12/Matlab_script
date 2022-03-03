clear

%cexp=[0 0 1; 1 0 0; 0 1 0]; 
%exp={'szvrzh124';'szvrzh364';'szvrzh364L'};
%exp={'e01';'e02'};  exptext='_largens';  cmap=[0 1 0; 0 0 1];
exp={'e01';'e04';'e05';'e02'};  exptext='_largens';  cmap=[0.1 0.7 0.1; 0.6 0.9 0.5; 0.1 0.8 0.7; 0.05 0.45 1];


hm='00:15';  range=[-5 -3 0 3 5];  landid=0;

%---experimental setting---
dom='02'; day='20080616';    % time setting
%obsdir='obs_morakot'; expdir='morakot_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/IOP8_morakot/';
%obsdir='obs_201206'; expdir='what_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/what/';
%obsdir='obs_sz6414'; expdir='sz_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/IOP8/';
obsdir='obs_sz6414'; expdir='largens_wrf2obs_';  outdir='/SAS011/pwin/201work/plot_cal/largens/';
%---
nexp=size(exp,1);
varinam='number of Vr impr.';   filenam='vr-impr_hist_';  

if landid==1; type='land'; elseif landid==-1; type='sea'; else type='all'; end

%--------------------
len=length(range)+1;
hi=zeros(len,nexp);
%-----
for i=1:nexp 
   expri=[expdir,exp{i}];
   hi(:,i)=a_vr_cal_impr_hist(expri,range,hm,day,dom,obsdir,landid);
end

figure('position',[100 500 880 490]) 
hb=bar(1:len,hi);
colormap(cmap);
legh=legend(exp,'Location','BestOutside'); set(legh,'fontsize',14)

set(gca,'fontsize',13,'XLim',[0 len+1],'XTick',0.5:len+0.5,'XTickLabel',[-inf,range,inf])
xlabel('improvement (m/s)','fontsize',14);   ylabel('number(%)','fontsize',14);

tit=[varinam,'  ',hm(1:2),hm(4:5),'z (',type,')'];
title(tit,'fontsize',15)
outfile=[outdir,filenam,hm(1:2),hm(4:5),'_',type];
 set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
 system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
 system(['rm ',[outfile,'.pdf']]);  


