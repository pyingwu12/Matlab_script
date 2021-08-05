%----------------------------------------------------
% vertical cross section of averaged error over a specific sub-domain (decided by <xsub> and <ysub>)
%                                                          ^^^^^^^^^^^
% load files from matfile/isoh_subdom
% One experiments; x-axis: time; y-axis: Height
% PY WU @2021/06/22
%----------------------------------------------------
close all;
clear; ccc=':';

%---setting 
% expri='TWIN001';   hrs=[24 25 26 27];
expri='TWIN003';   hrs=[22 23 24 25];
stday=22;    minu=0:10:50;   tint=2; 
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
% indir='./matfile/isoh_subdom';     fignam=[expri,'_DTEterms-ht_'];  titnam=[expri,'  height-time'];  
indir='./matfile/isoh_subdom_THM'; fignam=[expri,'_DTEterms-ht_THM_'];   titnam=[expri,'_THM  height-time'];  
outdir=['/mnt/e/figures/expri_twin/',expri];

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
    LF=load(infile,'qr_sub2','qc_sub2','qi_sub2','qg_sub2','qs_sub2','KE3D_sub','SH_sub','LH_sub','zgi','w_sub2',...
        'qr_sub1','qc_sub1','qi_sub1','qg_sub1','qs_sub1');
    zgi(:,nti)=LF.zgi;
    % 

%   DiW=1/2*(LF.w_sub1 - LF.w_sub2).^2;

    hyd1=LF.qr_sub1+LF.qc_sub1+LF.qi_sub1+LF.qs_sub1+LF.qg_sub1;
    hyd2=LF.qr_sub2+LF.qc_sub2+LF.qi_sub2+LF.qs_sub2+LF.qg_sub2;
    rmsd_hyd(:,nti)=(mean((hyd1-hyd2).^2,[1 2])).^0.5;
    
    %---maxmum of hydrometeors---
    qr_m(:,nti)= max(LF.qr_sub2,[],[1 2]);
    qc_m(:,nti)= max(LF.qc_sub2,[],[1 2]);
    qi_m(:,nti)= max(LF.qi_sub2,[],[1 2]);
    qs_m(:,nti)= max(LF.qs_sub2,[],[1 2]);
    qg_m(:,nti)= max(LF.qg_sub2,[],[1 2]);      

    %---mean of errors---
    KE3D_m(:,nti)=mean(LF.KE3D_sub,[1 2],'omitnan');
%     KE_m(:,nti)=mean(LF.KE_sub,[1 2]);
    SH_m(:,nti)=mean(LF.SH_sub,[1 2],'omitnan');
    LH_m(:,nti)=mean(LF.LH_sub,[1 2],'omitnan');
%     DiW_m(:,nti)=mean(DiW,[1 2]);
        
    w_m(:,nti)= max(LF.w_sub2,[],[1 2],'omitnan');
%   wdiff_n(:,nti)=min(wdiff,[],[1 2]);
               
%   KE3D_m(:,nti)= squeeze(quantile(LF.KE3D_sub,0.9,[1 2]));
%   SH_m(:,nti)= squeeze(quantile(LF.SH_sub,0.9,[1 2]));
%   LH_m(:,nti)= squeeze(quantile(LF.LH_sub,0.9,[1 2]));
          
  end % tmi
  disp([s_hr,s_min,' done'])
end %ti    
%%
KE3D_m(1:2,:)=NaN;
SH_m(1:2,:)=NaN;
LH_m(1:2,:)=NaN;
%---colormap of cloud---
cmap=[1 1 1; 0.95 0.95 0.95; .9 .9 .9; 0.85 0.85 0.85; 0.8 0.8 0.8; 0.75 0.75 0.75; 0.65 0.65 0.65];
cmap2=cmap*255;  cmap2(:,4)= (zeros(1,size(cmap2,1))+255)*0.5;
L=[0.1 1 5 10 15 20];
%---settings of contours---
LHcol=[0.7 0.2 0.8]; KEcol=[0.3 0.75 0.94]; SHcol=[0.9 0.65 0.1];  %KEcol=[0.1 0.2 0.9];
dhydcol=[0.3 0.3 0.3]; wcol=[0.9 0.1 0.1];
DTElw=4;
%
ytick=1000:2000:zgi(end);
%
xi=repmat(1:ntime,size(zgi,1),1);
%
plotvar=(qr_m+qc_m+qc_m+qs_m+qg_m)*1e3;
pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end

%---
 hf=figure('position',[80 350 1100 600]);
[~, hp]=contourf(xi,zgi,plotvar,L2,'linestyle','none');   hold on
% contour(xi,zgi,qc_m*1e3,[0.1 0.1],'color',[0.1 0.1 0.1],'linewidth',2,'linestyle','--');


LSpac=500; Lfs=15;
%---horizontal mean of root mean square difference of hydrometeor---
[c,hdis]=contour(xi,zgi,rmsd_hyd*1e3,[0.01 0.1],'color',dhydcol,'linewidth',3,'linestyle','-'); 
clabel(c,hdis,[0.01 0.1],'fontsize',Lfs,'color',dhydcol,'LabelSpacing',LSpac)   
%---horizontal mean errors---
ctr_int=[0.005  0.5];
[c,hdis]=contour(xi,zgi,LH_m,ctr_int,'color',LHcol,'linewidth',DTElw,'linestyle','-'); 
clabel(c,hdis,ctr_int,'fontsize',Lfs,'color',LHcol,'LabelSpacing',LSpac)   
[c,hdis]=contour(xi,zgi,KE3D_m,ctr_int,'color',KEcol,'linewidth',DTElw,'linestyle','-'); 
clabel(c,hdis,ctr_int,'fontsize',Lfs,'color',KEcol,'LabelSpacing',LSpac)  
[c,hdis]=contour(xi,zgi,SH_m,ctr_int,'color',SHcol,'linewidth',DTElw,'linestyle','-'); 
clabel(c,hdis,ctr_int,'fontsize',Lfs,'color',SHcol,'LabelSpacing',LSpac)   

%---horizontal max updraft of cntl simulation
[c,hdis]=contour(xi,zgi,w_m,[2 10],'color',wcol,'linewidth',2.5,'linestyle','--'); 
clabel(c,hdis,[2 10],'fontsize',Lfs,'color',wcol,'LabelSpacing',LSpac)   

set(gca,'fontsize',16,'LineWidth',1.2)
set(gca,'Ylim',[0 14000],'Ytick',ytick,'Yticklabel',ytick./1000)
set(gca,'Xlim',[1 ntime],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
% set(gca,'Xlim',[3 ntime-3],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)

xlabel('Local time'); ylabel('Height (km)')
title(titnam,'Interpreter','none')

%---colorbar---
fi=find(L>0);
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
colormap(cmap); title(hc,'g/kg','fontsize',14);  drawnow;
hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
for idx = 1 : numel(hFills)
  hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
end  
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
%%
%---check vertical velocity---
%{
ytick=1000:2000:zgi(end);
xi=repmat(1:ntime,size(zgi,1),1);
figure('position',[80 350 1200 400]);
[~, hp]=contourf(xi,zgi,w_m,30,'linestyle','none');   hold on
colorbar
caxis([0 7])
hold on
[c,hdis]=contour(xi,zgi,w_m,[0.3 1 10],'color',[0.9 0.1 0.1],'linewidth',2,'linestyle','--'); 
set(gca,'fontsize',16,'LineWidth',1.2)
set(gca,'Ylim',[0 5000],'Ytick',ytick,'Yticklabel',ytick./1000)
set(gca,'Xlim',[1 ntime],'Xtick',tint:tint:ntime,'Xticklabel',ss_hr)
%}
