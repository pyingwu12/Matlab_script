clear;  ccc=':';
% close all

%---experiments
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp0103';
expri2={'TWIN001B';'TWIN003B'};
expnam={'FLAT';'TOPO'};
%---set sub-domain average range---
% xarea=1:150;  yarea=76:175; areatext='moun';
xarea=1:300;  yarea=1:300; areatext='whole';

%---setting---
stday=22;  sth=21;  lenh=20;  minu=[00 20 40];  tint=2;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam='Terms of moist DTE';   fignam=['DTEterms_',exptext,'_'];
%
nexp=size(expri1,1); 
nminu=length(minu);  ntime=lenh*nminu;
%---
ss_hr=cell(length(tint:tint:lenh),1); ntint=0;
KE2D_m=zeros(nexp,ntime); ThE2D_m=zeros(nexp,ntime); LH2D_m=zeros(nexp,ntime);
for ei=1:nexp  
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntint=ntint+1; ss_hr{ntint}=num2str(mod(hr+9,24),'%2.2d'); %xticks
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---
      
      [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2);
 
      dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
      dPall = P.f2(:,:,end)-P.f2(:,:,1);
      dPm = dP./repmat(dPall,1,1,size(dP,3)); 
 
      KE2D = sum(dPm.*KE(:,:,1:end-1),3);     KE2D_m(ei,nti)=mean(mean(KE2D(xarea,yarea)));
      ThE2D = sum(dPm.*ThE(:,:,1:end-1),3);   ThE2D_m(ei,nti)=mean(mean(ThE2D(xarea,yarea)));
      LH2D = sum(dPm.*LH(:,:,1:end-1),3);     LH2D_m(ei,nti)=mean(mean(LH2D(xarea,yarea)));

    end %minu
    if mod(ti,5)==0; disp([s_hr,' done']); end
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---plot
% hf=figure('position',[100 55 1200 600]);
hf=figure('position',[100 55 1000 600]);
linestyl={'-';'--'};

for ei=1:nexp  
  plot(KE2D_m(ei,:),'LineWidth',2.5,'color',[0.929,0.694,0.125],'linestyle',linestyl{ei}); hold on
  plot(ThE2D_m(ei,:),'LineWidth',2.5,'color',[0.466,0.674,0.188],'linestyle',linestyl{ei});
   plot(LH2D_m(ei,:),'LineWidth',2.5,'color',[0.494,0.184,0.556],'linestyle',linestyl{ei});
end
legh=legend({'KE','ThE','LH'},'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Monospaced');
%---
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'YScale','log');
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Time(JST)'); ylabel('JKg^-^1')  
title([titnam,'  (area:',areatext,')'],'fontsize',18)

%---
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min_',areatext];
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
