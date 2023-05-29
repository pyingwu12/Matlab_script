clear;  ccc=':';
close all

saveid=0; % save figure (1) or not (0)

%---experiments
exptext='test';
expri1={'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';
        'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221'};   
expri2={'TWIN201B';'TWIN201B';'TWIN003B';'TWIN003B'}; 
expnam={'FLAT';'FLAT_P01';'TOPO';'TOPO_P01'};
cexp=[  87 198 229;  154 211 237; 242 155 0;   240 220 20; ]/255;
%   

cp=1004.9;
R=287.04;
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
Pr=1000;

%---setting---
plotid='CMDTE'; % "MDTE" or "CMDTE"
stday=22;  sth=21;  lenh=10; minu=[0];  tint=1;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
% indir='D:expri_twin';  %outdir='D:/figures/expri_twin';
% outdir='G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin/';
titnam=plotid;   fignam=[plotid,'_Ts_',exptext,'_'];
%-----
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
%---------------------------------------------------
DTE_dm=zeros(nexp,ntime); ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
cntl_TE=zeros(nexp,ntime);
%% 
for ei=1:nexp
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1;     ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---
      if exist([indir,'/',expri1{ei}],'dir') && ~exist(infile1,'file') 
        DTE_dm(ei,nti)=NaN;
        continue
      end
      [MDTE, CMDTE]=cal_DTE_2D(infile1,infile2);  
      eval(['DiffE=',plotid,';'])
      DTE_dm(ei,nti) = mean(mean(DiffE));  % domain mean of 2D DTE  



 u.stag = ncread(infile2,'U');   v.stag = ncread(infile2,'V');   w.stag = ncread(infile2,'W');
 u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
 v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
 w.f2=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5; 
 p=ncread(infile2,'P');  pb = ncread(infile2,'PB');  P.f2 = double(pb+p)/100; 
 th.f2=double(ncread(infile2,'T'))+300;  
 t.f2=th.f2.*(1e3./P.f2).^(-R/cp);
 qv.f2=double(ncread(infile2,'QVAPOR')); 
 ps.f2 = ncread(infile2,'PSFC')/100; 

 dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
 dPall = P.f2(:,:,end)-P.f2(:,:,1);
 dPm = dP./repmat(dPall,1,1,size(dP,3));

cntl_TE(ei,nti)=  mean( sum(dPm.*(u.f2(:,:,1:end-1)+v.f2(:,:,1:end-1)+w.f2(:,:,1:end-1)+t.f2(:,:,1:end-1)+qv.f2(:,:,1:end-1)),3)...
    +ps.f2 ,'all' );


      if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
    end %minu    
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---plot
linexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};

hf=figure('position',[100 105 1000 600]);
plotexp=1:nexp;
for ei=plotexp
  h(ei)= plot(real(DTE_dm(ei,:)),linexp{ei},'LineWidth',4.5,'color',cexp(ei,:)); hold on
plot(real(cntl_TE(ei,:)),'--','LineWidth',3.5,'color',cexp(ei,:))
end
%
legh=legend(h(plotexp),expnam{plotexp},'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Consolas');
%
%---
set(gca,'Linewidth',1.2,'fontsize',20)
set(gca,'YScale','log');  %
% set(gca,'Ylim',[1e-6 3e1])

set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)

xlabel('Local time'); ylabel('J kg^-^1')  
title([titnam,' evolution'],'fontsize',23)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if saveid==1
print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
