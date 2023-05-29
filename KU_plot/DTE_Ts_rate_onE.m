% function DTE_Ts_slope_cgr_onE(expri)

clear;  
% close all;  
ccc=':';
saveid=0; % save figure (1) or not (0)

expri='TWIN039'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 

xsub=1:300; ysub=1:300;
cloudtpw=0.7;

%---
stday=22;   sth=21;   lenh=13;  minu=0:10:50;   tint=1;

year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='CMDTE and cloud ratio';   fignam=[expri1(8:end),'_CMDTE_Ts_'];
%
nminu=length(minu);  ntime=lenh*nminu;
%%
%---plot
cgr=zeros(ntime,1);  DTE_m=zeros(ntime,1); %TPW_m=zeros(ntime,1); 
nti=0;  ntii=0;
for ti=1:lenh 
  hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  if mod(ti,tint)==0 
    ntii=ntii+1;    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
  end   
  for tmi=minu 
    nti=nti+1;      s_min=num2str(tmi,'%.2d');
    %---infile 1---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     
     P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
     hyd  = qr+qc+qg+qs+qi;   
     dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
     tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
     TPW=squeeze(sum(tpw,3)./9.81);
          
     TPWsub=TPW(xsub,ysub);
     
     cgr(nti) = length(TPWsub(TPWsub>cloudtpw)) / (size(TPWsub,1)*size(TPWsub,2)) *100 ;
     
     TPW_m(nti)=mean(TPWsub(:));

    %---
    [~,CMDTE] = cal_DTE_2D(infile1,infile2) ;     
    
    DTE_m(nti)=mean(mean(CMDTE(xsub,ysub)));
        
  end % tmi 
  disp([s_hr,s_min,' done']);
end %ti    
%%
%----slope
DTE_log=log(DTE_m);
DTE_slope = (DTE_log(4:end)-DTE_log(1:end-3)); 

%--plot
hf=figure('position',[200 45 1000 600]);
colororder({'k','k'})

yyaxis left
h1=plot(DTE_m,'color',[0,0.447,0.741],'LineWidth',3,'linestyle','-'); hold on
h2=plot(cgr,'color',[0,0.447,0.741],'LineWidth',3,'linestyle','--');
%   plot(TPW_m,'color',[0,0.447,0.741],'LineWidth',3,'linestyle','--');

[~,b]=max(cgr);
plot([b b],[2e-4 4e1],'linestyle',':','color',[0,0.447,0.741],'LineWidth',1.2)

set(gca,'Yscale','log','Ylim',[2e-4 4e1])
ylabel('CMDTE (J kg^-^1) & cloud ratio (%)')  

%---
yyaxis right
h3=plot(2.5:1:ntime-1.5,DTE_slope,'color',[0,0.447,0.741],'LineWidth',3,'linestyle',':'); hold on
plot([1 ntime-1],[0.01 0.01],'LineWidth',2,'color','k')

ylabel('CMDTE growth rate')  
set(gca,'Ylim',[-1.3 2.7])

legend([h1,h2,h3],{'CMDET','cloud ratio','growth rate'},'Box','off','Interpreter','none','fontsize',18,'Location','se');

set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'Xlim',[0 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Local time'); 
tit=[expri1,'  ',titnam];     
title(tit,'fontsize',18)

%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
s_sub=['x',num2str(xsub(1)),num2str(xsub(end)),'y',num2str(ysub(1)),num2str(ysub(end))];
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_tpw',num2str(cloudtpw),'_',s_sub];
if saveid~=0
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);  
end
% disp([expri,' done']);
