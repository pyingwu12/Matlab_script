close all; clear;   ccc=':';

%---setting
expri='';  day=22;   hrs=[23 24];  minu=0:10:50;  
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='';   fignam=[expri,''];
%
nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%
load('colormap/colormap_ncl.mat'); col=colormap_ncl(25:floor(254/ntime)-1:end,:);

%---
nti=0;   lgnd=cell(length(ntime),1);
for ti=hrs
  hr=ti;   s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  for mi=minu    
    nti=nti+1;    s_min=num2str(mi,'%2.2d');
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
    %---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---
    xxx = ncread(infile,'');
   %
  end %mi
  disp([s_hr,s_min,' done'])
end %ti

%%
%---plot---
hf=figure('position',[45 350 800 650]);
for ti=1:ntime
  plot(xxx,'color',col(ti,:),'linewidth',3);     hold on  
end
legend(lgnd,'box','off','fontsize',18,'location','eastoutside')

set(gca,'fontsize',18,'LineWidth',1.2)    
set(gca,'Ytick',ytick,'Yticklabel',ytick./1000) 
xlabel('');    ylabel('')    
tit=[expri,'  ',titnam];
title(tit,'fontsize',18)
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
