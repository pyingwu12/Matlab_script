clear;  ccc=':';
% close all

%---experiments
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='0103';
% expri2={'TWIN001B';'TWIN003B'};
% expnam={'FLAT';'TOPO'};
% cexp=[  0,0.447,0.741; 0.85,0.325,0.098]; 

expri1={'TWIN001Pr001qv062221';'TWIN001Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr01qv062221'};   
expri2={'TWIN001B';'TWIN001B';'TWIN003B';'TWIN003B'}; 
exptext='qv01';
expnam={'FLAT_qv001';'FLAT_qv01';'TOPO_qv001';'TOPO_qv01'};
cexp=[ 0 0.447 0.741; 0.3 0.745 0.933;  0.85,0.325,0.098; 0.929,0.694,0.125]; 


% expri1={'TWIN001Pr001qv062221';'TWIN001Pr001qv062221noMP';'TWIN003Pr001qv062221';'TWIN003Pr001qv062221noMP'};   exptext='noMP';
% expri2={'TWIN001B';'TWIN001B062221noMP';'TWIN003B';'TWIN003B062221noMP'};
% expnam={'FLAT';'FLATnoMP';'TOPO';'TOPOnoMP'};
% cexp=[0,0.447,0.741; 0.3,0.745,0.933; 0.85,0.325,0.098;  0.929,0.694,0.125]; 

% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN001Pr0025THM062221';'TWIN003Pr0025THM062221'};   
% expri2={'TWIN001B';'TWIN003B';'TWIN001B';'TWIN003B'}; exptext='THM25';
% expnam={'FLAT';'TOPO';'FLAT_THM25';'TOPO_THM25'};
% cexp=[ 0,0.447,0.741; 0.85,0.325,0.098;  0.3,0.745,0.933; 0.929,0.694,0.125]; 

% expri1={'TWIN042Pr001qv062221';'TWIN030Pr001qv062221';'TWIN033Pr001qv062221';'TWIN036Pr001qv062221';'TWIN039Pr001qv062221'};   
% expri2={'TWIN042B';'TWIN030B';'TWIN033B';'TWIN036B';'TWIN039B'}; exptext='FLAT_winds';
% expnam={'noW';'NS5';'U05';'U15';'U25'};
% cexp=[ 0,0.447,0.741; 0.85,0.325,0.098; 0.466,0.674,0.188;  0.3,0.745,0.933; 0.929,0.694,0.125]; 

% expri1={'TWIN043Pr001qv062221';'TWIN031Pr001qv062221';'TWIN034Pr001qv062221';'TWIN037Pr001qv062221';'TWIN040Pr001qv062221'};   
% expri2={'TWIN043B';'TWIN031B';'TWIN034B';'TWIN037B';'TWIN040B'}; exptext='H10_winds';
% expnam={'noW';'NS5';'U05';'U15';'U25'};
% cexp=[ 0,0.447,0.741; 0.85,0.325,0.098; 0.466,0.674,0.188;  0.3,0.745,0.933; 0.929,0.694,0.125]; 

% expri1={'TWIN044Pr001qv062221';'TWIN032Pr001qv062221';'TWIN035Pr001qv062221';'TWIN038Pr001qv062221';'TWIN041Pr001qv062221'};   
% expri2={'TWIN044B';'TWIN032B';'TWIN035B';'TWIN038B';'TWIN041B'}; exptext='H05_winds';
% expnam={'noW';'NS5';'U05';'U15';'U25'};
% cexp=[ 0,0.447,0.741; 0.85,0.325,0.098; 0.466,0.674,0.188;  0.3,0.745,0.933; 0.929,0.694,0.125]; 


%---setting---
plotid='CMDTE'; % "MDTE" or "CMDTE"
stday=22;  sth=21;  lenh=15;  minu=[00 20 40];  tint=2;
% stday=22;  sth=21;  lenh=7;  minu=0:10:50;  tint=1;
% stday=21;  sth=15;  lenh=48;  minu=00;  tint=3;
plotarea=0; %if ~=0, plot sub-domain average set below
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam=plotid;   fignam=[plotid,'_Ts_',exptext,'_'];

%---set sub-domain average range---
% x1=1:150; y1=76:175;    x2=151:300; y2=201:300;   % SOLA paper
% x1=1:150; y1=51:200;    x2=151:300; y2=51:200;   % 2nd paper
x1=1:150; y1=26:175;    x2=151:300; y2=26:175;   % SOLA paper
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'whole';'mount';'plain'};
linestyl={'--',':.'};   
%-----
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;

if plotarea~=0; narea=size(xarea,1); else; narea=0; end
%
%---------------------------------------------------
DTE_dm=zeros(nexp,ntime);  if plotarea~=0; DTE_am=zeros(nexp,ntime,narea); end
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
for ei=1:nexp  
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
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
      [MDTE, CMDTE]=cal_DTE_2D(infile1,infile2);  
      eval(['DiffE=',plotid,';'])
      DTE_dm(ei,nti) = mean(mean(DiffE));  % domain mean of 2D DTE      
      if plotarea~=0  % area mean of 2D DTE
        for ai=1:narea
        DTE_am(ei,nti,ai) = mean(mean( DiffE(xarea(ai,:),yarea(ai,:)) ));
        end
      end      
    end %minu
    if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---set legend---
ni=0;  lgnd=cell(nexp*(narea+1),1);
for ei=1:nexp    
  for ai=0:narea
    ni=ni+1;
    lgnd{ni}=[expnam{ei},'_',arenam{ai+1}];
  end
end
%%
%---plot
hf=figure('position',[100 55 1200 600]);
% hf=figure('position',[100 55 1000 600]);
for ei=1:nexp
  plot(DTE_dm(ei,:),'LineWidth',3,'color',cexp(ei,:)); hold on
  if plotarea~=0
    for ai=1:narea
      plot(DTE_am(ei,:,ai),linestyl{ai},'LineWidth',2.5,'color',cexp(ei,:));hold on
    end
  end
end
legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Monospaced');
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',23,'Location','southeast','FontName','Monospaced');
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',28,'Location','nw','FontName','Monospaced');
%---
set(gca,'Linewidth',1.2,'fontsize',16)
% set(gca,'YScale','log');  set(gca,'Ylim',[2e-4 3e1])
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)

xlabel('Time(JST)'); ylabel('J kg^-^1')  
title(titnam,'fontsize',18)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
