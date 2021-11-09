clear;  ccc=':';
close all

saveid=1; % save figure (1) or not (0)

%---experiments

% exptext='diffpert';
% expri1={'TWIN201Pr01qv062221';'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';'TWIN201Pr001qv062223';'TWIN201Pr001qv062301'
%         'TWIN003Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221';'TWIN003Pr001qv062223';'TWIN003Pr001qv062301' };   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B'
%         'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B'}; 
% expnam={'FLAT_P10';'FLAT';'FLAT_P01';'FLAT_08LT';'FALT_10LT'
%         'TOPO_P10';'TOPO';'TOPO_P01';'TOPO_08LT';'TOPO_10LT'};
% cexp=[62 158 209;   87 198 229;  154 211 237;     158 169 98;  189 223 110;
%       230 101 99;     242 155 0;   240 220 20;      240 143 152; 246 209 223  ]/255;
%   
%   exptext='FLATdiffpert';
% expri1={'TWIN201Pr01qv062221';'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';'TWIN201Pr001qv062223';'TWIN201Pr001qv062301'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B'}; 
% expnam={'FLAT_P10';'FLAT';'FLAT_P01';'FLAT_08LT';'FALT_10LT'};
% cexp=[62 158 209;   87 198 229;  154 211 237;     158 169 98;  189 223 110  ]/255;


% expri1={'TWIN042Pr001qv062221'; 'TWIN033Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN036Pr001qv062221';'TWIN201Pr001qv062221'; 
%    'TWIN043Pr001qv062221'; 'TWIN003Pr001qv062221';  };   
% expri2={'TWIN042B';'TWIN033B';'TWIN030B'; 'TWIN036B'; 'TWIN201B';
%     'TWIN043B'; 'TWIN003B'}; 
% exptext='FLATOPOU15';
% % cexp=[183 179 162;  109 119 67; 77 191 216; 80 156 156]/255;
% expnam={'U00_FLAT';'U05_FLAT';'NS5_FLAT';'U15_FLAT';'FLAT';'U00_TOPO';'TOPO'};
% cexp=[109 191 230;  109 119 67; 80 156 156; 77 191 216;  183 179 162;  244 199 2 ;227 128 29]/255; 

% expri1={'TWIN003Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221';'TWIN003Pr001qv062223';'TWIN003Pr001qv062301'};   
% expri2={'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B'}; 
% exptext='TOPOdiffpert2';
% expnam={ 'TOPO_01';'TOPO_001';'TOPO_0001';'TOPO_08LT';'TOPO_10LT'};
% cexp=[199 42 50;  227 128 29;  244 199 2;  220 219 147;  238 180 150]/255;

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
% exptext='diffTOPO';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;
 
% expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221noMP';'TWIN003Pr001qv062221';
%          'TWIN003Pr001qv062221noMP';'TWIN013Pr001qv062221';'TWIN013Pr001qv062221noMP'};  
% expri2={'TWIN201B';'TWIN201B062221noMP';'TWIN003B';'TWIN003B062221noMP';'TWIN013B';'TWIN013B062221noMP'};
% exptext='noMP13';
% expnam={'FLAT';'FLATnoMP';'TOPO';'TOPOnoMP';'H500';'H500noMP'};
% cexp=[0,0.447,0.741; 0.3,0.745,0.933;  0.85,0.325,0.098;  0.929,0.694,0.125; 0.466,0.674,0.188; 0.572 0.784 0.396]; 

% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN001Pr0025THM062221';'TWIN003Pr0025THM062221'};   
% expri2={'TWIN001B';'TWIN003B';'TWIN001B';'TWIN003B'}; exptext='THM25';
% expnam={'FLAT';'TOPO';'FLAT_THM25';'TOPO_THM25'};
% cexp=[ 0,0.447,0.741; 0.85,0.325,0.098;  0.3,0.745,0.933; 0.929,0.694,0.125]; 

expri1={'TWIN201Pr001qv062221';'TWIN003Pr001qv062221';'TWIN013Pr001qv062221';
        'TWIN001Pr0025THM062221';'TWIN003Pr0025THM062221';'TWIN013Pr0025THM062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B';'TWIN001B';'TWIN003B';'TWIN013B'}; exptext='THM25';
expnam={'FLAT';'TOPO';'H500';'FLAT_THM25';'TOPO_THM25';'H500_THM25'};
cexp=[87 198 229; 242 155 0; 146 200 101;  47 158 189; 202 115 0; 10 160 61]/255; 

%{
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
%}

%---setting---
plotid='CMDTE'; % "MDTE" or "CMDTE"
stday=22;  sth=21;  lenh=11; minu=[0 20 40];  tint=1;
% stday=22;  sth=21;  lenh=6; minu=0:10:50;  tint=1;

plotarea=0; %if ~=0, plot sub-domain average set below
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam=plotid;   fignam=[plotid,'_Ts_',exptext,'_'];

%---set sub-domain average range---
x1=1:150; y1=76:175;    x2=151:300; y2=201:300;   % SOLA paper
% x1=1:150; y1=51:200;    x2=151:300; y2=51:200;   % 2nd paper
% x1=1:150; y1=26:175;    x2=151:300; y2=26:175;  % ideal wind profile
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'whole';'mount';'plain'};
linestyl={'--',':.'};   
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
      DTE_dm(ei,nti) = mean(mean(DiffE));  % domain mean of 2D DTE      
      if plotarea~=0  % area mean of 2D DTE
        for ai=1:narea
        DTE_am(ei,nti,ai) = mean(mean( DiffE(xarea(ai,:),yarea(ai,:)) ));
        end
      end    
      if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
    end %minu    
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
% close all
% saveid=1;
% cexp=[87 198 229; 242 135 0; 146 200 101; 230 84 80; 239 144 185]/255; 

cexp=[87 198 229; 242 155 0; 146 200 101;  28 88 119; 171 106 105; 125 127 55]/255; 

linexp={'-';'-';'-';':';':';':'};
% linexp={'-';'-';'-';':';':';'-';'-';'-';':';':'};
% linexp={'-';'--';'-';'--';'-';'--'};

% hf=figure('position',[100 55 1200 600]);
hf=figure('position',[100 55 1000 600]);
% for ei=[5 3 2 4 1  10 8 9 7 6] 
% for ei=1:nexp   
for ei=[1 4 3 6 2 5]
  h(ei)= plot(DTE_dm(ei,:),linexp{ei},'LineWidth',4.5,'color',cexp(ei,:),'Markersize',10); hold on
%   h(ei)= plot(DTE_dm(ei,:),'LineWidth',4.5,'color',cexp(ei,:),'Markersize',10); hold on
  if plotarea~=0
    for ai=1:narea
      plot(DTE_am(ei,:,ai),linestyl{ai},'LineWidth',2.5,'color',cexp(ei,:));hold on
    end
  end
end
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Monospaced');
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Monospaced');
%
%---
set(gca,'Linewidth',1.2,'fontsize',20)
set(gca,'YScale','log');  %
set(gca,'Ylim',[2e-4 2e1])
% set(gca,'Ylim',[1e-6 3e1])
% set(gca,'Ylim',[3e-5 2e1])
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)

xlabel('Local time'); ylabel('J kg^-^1')  
title([titnam,' evolution'],'fontsize',23)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
if saveid==1
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
