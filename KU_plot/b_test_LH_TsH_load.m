%----------------------------------------------------
% vertical cross section of averaged error over a specific sub-domain (decided by <xsub> and <ysub>)
%                                                          ^^^^^^^^^^^
% load files from matfile/isoh_subdom
% One experiments; x-axis: time; y-axis: Height
% PY WU @2021/06/22
%----------------------------------------------------
% close all;
clear; ccc=':';

%---setting 
% expri='TWIN001';   hrs=[24 25 26 27];
expri='TWIN003';   hrs=[22 23 24 25];
stday=22;    minu=0:10:50;   tint=2; 
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='./matfile/isoh_subdom';     fignam=[expri,'_DTEterms-ht_'];
% indir='./matfile/isoh_subdom_THM';     fignam=[expri,'_DTEterms-ht_THM_'];
outdir=['/mnt/e/figures/expri_twin/',expri];
titnam=[expri,'  height-time'];  
%
nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%
g=9.81; 
%%
%---
nti=0;  ntii=0;
for ti=hrs 
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  for mi=minu
    nti=nti+1;      s_min=num2str(mi,'%2.2d');  
    if mod(nti,tint)==0
     ntii=ntii+1;   s_hrj=num2str(mod(hr+9,24),'%2.2d');   ss_hr{ntii}=[s_hrj,s_min];
    end
    %---infile---
    infile=[indir,'/',expri,'_',mon,s_date,'_',s_hr,s_min,'.mat'];
    LF=load(infile,'LH_sub','zgi');
    zgi(:,nti)=LF.zgi;
    % 

    %---mean of errors---
    LH_m(:,nti)=mean(LF.LH_sub,[1 2],'omitnan');

 
  end % tmi
  disp([s_hr,s_min,' done'])
end %ti    
%%
%
ytick=1000:2000:zgi(end);
%
xi=repmat(1:ntime,size(zgi,1),1);
%---
 hf=figure('position',[80 350 1100 550]);

 imagesc(flip(LH_m))
 
 colorbar;
 set(gca,'ColorScale','log')
 
 caxis([1e-4 2.5e1])
 
 hold on
 contour(flip(LH_m),[0.001 0.005 0.05 0.5],'k','linewidth',2)
% set(gca,'fontsize',16,'LineWidth',1.2)
% set(gca,'Ylim',[0 15000],'Ytick',ytick,'Yticklabel',ytick./1000)
% set(gca,'Xlim',[1 ntime],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
% % set(gca,'Xlim',[3 ntime-3],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
% 
% xlabel('Local time'); ylabel('Height (km)')
% title(titnam)
% 
% %
% s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
% outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
% print(hf,'-dpng',[outfile,'.png'])    
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
