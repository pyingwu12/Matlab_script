close all;  clear;   ccc=':';

% exptext='e0313';  
% expri={'TWIN013B';'TWIN003B'};      
% expnam={'V10H05';'TOPO'};
% cexp=[  0  114  189;  220 85 25]/255;



exptext='e2425';  
expri={'TWIN025B';'TWIN024B'};      
expnam={'V05H075';'V20H075'};
cexp=[0.96 0.6  0.79;  0.47 0.05 0.45];


%---setting
stday=22;   sth=22;   lenh=3;  minu=0:10:50;   tint=2;
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
LFC_indir='/mnt/HDDA/Python_script/LFC_data';
titnam='LFC';   fignam=['LFC_',exptext,'_'];

nexp=size(expri,1);  nminu=length(minu);  ntime=lenh*nminu;
%---
ntii=0;  LFC_min=zeros(ntime,nexp);  
for ei=1:nexp
  nti=0;
  for ti=1:lenh 
  hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');  
    for tmi=minu 
    nti=nti+1;     s_min=num2str(tmi,'%2.2d');       
    if mod(nti,tint)==0 && ei==1
     ntii=ntii+1;   s_hrj=num2str(mod(hr+9,24),'%2.2d');   ss_hr{ntii}=[s_hrj,s_min];
    end 
    %--- filename---
    infile=[indir,'/',expri{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile,'HGT');  
    if nti==1; hgt_max(ei)=max(hgt(:)); end 
    %
    LFC_infile=[LFC_indir,'/',expri{ei},'_',mon,s_date,'_',s_hr,s_min,'_LFC.npy'];
    LFC=readNPY(LFC_infile)+hgt';
    
    LFC_min(nti,ei)=min(LFC(:));
    LFC_max(nti,ei)=max(LFC(:));
    LFC_med(nti,ei)=median(LFC(:));
    
    end  
  end  
end
 %%  
%---plot---       
hf=figure('position',[200 55 1000 500]);
for ei=1:nexp
%   plot(LFC_med(:,ei),'color',cexp(ei,:),'LineWidth',5); hold on
  plot(LFC_min(:,ei),'color',cexp(ei,:),'LineWidth',5); hold on  
end
% for ei=1:nexp
%   line([1 ntime],[hgt_max(ei) hgt_max(ei)],'color',cexp(ei,:),'linewidth',2,'linestyle','-.'); hold on
% end
legend(expnam,'Box','off','Interpreter','none','fontsize',25,'Location','bestout','FontName','Consolas');
%
% line([1 ntime],[hgt_max(1) hgt_max(1)],'color',[0.3 0.8 0.5],'linewidth',5,'linestyle','--')
% line([1 ntime],[hgt_max(2) hgt_max(2)],'color',[0.2 0.5 0.1],'linewidth',5,'linestyle','--')
%---
set(gca,'Xlim',[1 ntime],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
set(gca,'Ylim',[400 1100])
set(gca,'Linewidth',1.2,'fontsize',18)
xlabel('Local time'); ylabel('m')  
%---
tit=titnam;     
title(tit,'fontsize',25)
% 
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
