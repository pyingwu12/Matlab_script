clear;  ccc=':';
close all

saveid=1; % save figure (1) or not (0)

%---experiments

% 
expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
exptext='diffTOPO';
expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% cexp=[87 198 229; 242 155 0;       24 126 218; 242 80 50;      75 70 154;  155 55 55]/255; %R3


cloudtpw=0.7; 
%---setting---
plotid='CMDTE'; % "MDTE" or "CMDTE"
stday=22;  sth=21;  lenh=12; minu=[0 20 40];  tint=1;

plotarea=1; %if ~=0, plot sub-domain average set below
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
% indir='D:expri_twin';  %outdir='D:/figures/expri_twin';
% outdir='G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin/';
titnam=plotid;   fignam=[plotid,'_Ts_',exptext,'_'];

%---set sub-domain average range---
% x1=1:150; y1=76:175;    x2=151:300; y2=201:300;   % SOLA paper
x1=1:150; y1=51:200;    x2=151:300; y2=51:200;   % 2nd paper


xarea=[x1; x2];  yarea=[y1; y2];
arenam={'whole';'mount';'plain'};
linestyl={'--',':'};   
%-----
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
%---------------------------------------------------
DTE_dm=zeros(nexp,ntime);  if plotarea~=0; DTE_am=zeros(nexp,ntime,narea); end
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
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
      DTE_dm(nti,ei) = mean(mean(DiffE));  % domain mean of 2D DTE      
      
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     
     P=double(ncread(infile2,'P')+ncread(infile2,'PB'));
     hyd  = qr+qc+qg+qs+qi;        dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
     tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
     TPW=squeeze(sum(tpw,3)./9.81); 
     
     cgr_dm(nti,ei) = length(TPW(TPW>cloudtpw)) / (size(TPW,1)*size(TPW,2)) *100 ;
     
      
      if plotarea~=0  % area mean of 2D DTE
        for ai=1:narea
        DTE_am(nti,ei,ai) = mean(mean( DiffE(xarea(ai,:),yarea(ai,:)) ));

TPWsub=TPW(xarea(ai,:),yarea(ai,:));
cgr_am(nti,ei,ai) = length(TPWsub(TPWsub>cloudtpw)) / (size(TPWsub,1)*size(TPWsub,2)) *100 ;

        end
      end    
      if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
    end %minu    
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---set legend---
% ni=0;  lgnd=cell(nexp*(narea+1),1);
% for ei=1:nexp    
%   for ai=0:narea
%     ni=ni+1;
%     lgnd{ni}=[expnam{ei},'_',arenam{ai+1}];
%   end
% end
%%
DTE_log=log(DTE_dm);
DTE_rate_dm = (DTE_log(4:end,:)-DTE_log(1:end-3,:));

DTE_log=log(DTE_am);
DTE_rate_am = (DTE_log(4:end,:,:)-DTE_log(1:end-3,:,:));

%%
%---plot

% % hf=figure('position',[100 55 1200 600]);
% hf=figure('position',[100 105 1000 600]);
hf=figure('position',[200 65 930 830]); %JAS paper

plotexp=1:nexp;

ax2=subplot('position',[0.12 0.1 0.78 0.54]);
for ei=plotexp
  h(ei)=plot(DTE_dm(:,ei),'color',cexp(ei,:),'LineWidth',3.8,'linestyle','-','Marker','none'); hold on
  if plotarea~=0
    for ai=1:narea
      plot(DTE_am(:,ei,ai),linestyl{ai},'LineWidth',2.5,'color',cexp(ei,:));hold on
    end
  end
end
set(ax2,'Yscale','log','Ylim',[2e-4 1.5e1],'fontsize',18,'LineWidth',1.2,'TickDir','out'); %JAS paper ?
set(ax2,'Xlim',[0 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)

ylabel('CMDTE (J kg^-^1)'); xlabel('Local time'); 
% legend(h,expnam,'Box','off','Interpreter','none','fontsize',27,'Location','east','FontName','Monospaced');

ax1=subplot('position',[0.12 0.655 0.78 0.25]);
for ei=plotexp
  plot(cgr_dm(:,ei),'color',cexp(ei,:),'LineWidth',3,'linestyle','-','Marker','none'); hold on
  if plotarea~=0
    for ai=1:narea
      plot(cgr_am(:,ei,ai),linestyl{ai},'LineWidth',2.2,'color',cexp(ei,:));hold on
    end
  end
end
set(ax1,'Yscale','log','Ylim',[1.5e-3 2.2e1],'fontsize',16,'LineWidth',1.2,'TickDir','out'); 
set(ax1,'Xlim',[0 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',[],'YTick',[0.01 0.1 1 10])
ylabel('cloud grid ratio (%)') 

% legh=legend(h(plotexp),expnam{plotexp},'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Consolas');
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Consolas');
%
title([titnam,' evolution'],'fontsize',23)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
if saveid==1
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

%%

hf=figure('position',[100 105 1000 600]);

plotexp=1:nexp;

for ei=plotexp
%   h(ei)=plot(DTE_dm(:,ei)./cgr_dm(:,ei),'color',cexp(ei,:),'LineWidth',3.8,'linestyle','-','Marker','none'); hold on
  if plotarea~=0
    for ai=1:narea
      plot(DTE_am(:,ei,ai)./cgr_am(:,ei,ai),linestyl{ai},'LineWidth',2.5,'color',cexp(ei,:));hold on
    end
  end
end
set(gca,'Xlim',[0 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)

ylabel('CMDTE/cgr'); xlabel('Local time'); 
% legend(h,expnam,'Box','off','Interpreter','none','fontsize',27,'Location','east','FontName','Monospaced');

%---
set(gca,'Linewidth',1.2,'fontsize',20)
set(gca,'YScale','log');  %
% set(gca,'Ylim',[1e-6 3e1])
% set(gca,'Ylim',[2e-4 2e1])
% set(gca,'Ylim',[1e-6 2e1])
% set(gca,'Ylim',[3e-5 2e1])

% set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)

% xlabel('Local time'); ylabel('J kg^-^1')  
title([titnam,'/cgr evolution'],'fontsize',23)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
% outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
% if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
% if saveid==1
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
% end
