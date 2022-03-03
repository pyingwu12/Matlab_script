clear;  ccc=':';
close all

saveid=0; % save figure (1) or not (0)

%---experiments

% exptext='diffpert2';
% expri1={'TWIN201Pr01qv062221';'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';'TWIN201Pr001qv062223';'TWIN201Pr001qv062301'
%         'TWIN003Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221';'TWIN003Pr001qv062223';'TWIN003Pr001qv062301' };   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B'
%         'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B'}; 
% expnam={'FLAT_P10';'FLAT';'FLAT_P01';'FLAT_08LT';'FLAT_10LT'
%         'TOPO_P10';'TOPO';'TOPO_P01';'TOPO_08LT';'TOPO_10LT'};
% cexp=[62 158 209;   87 198 229;  154 211 237;     158 169 98;  189 223 110;
%       230 101 99;     242 155 0;   240 220 20;      240 143 152; 246 209 223  ]/255;
%   
%   exptext='FLATdiffpert';
% expri1={'TWIN201Pr01qv062221';'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';'TWIN201Pr001qv062223';'TWIN201Pr001qv062301'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B'}; 
% expnam={'FLAT_P10';'FLAT';'FLAT_P01';'FLAT_08LT';'FALT_10LT'};
% cexp=[62 158 209;   87 198 229;  154 211 237;     158 169 98;  189 223 110  ]/255;

% exptext='diffpertU00';
% expri1={'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';
%         'TWIN042Pr001qv062221';'TWIN042Pr0001qv062221';
%         'TWIN039Pr001qv062221';'TWIN039Pr0001qv062221';
%         'TWIN013Pr001qv062221';'TWIN013Pr0001qv062221';
%         'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN042B';'TWIN042B';'TWIN039B';'TWIN039B'
%         'TWIN013B';'TWIN013B';'TWIN003B';'TWIN003B'}; 
% expnam={'FLAT';'FLAT_P01';'U00';'U00_P01';'U25';'U25_P01'
%         'H500';'H500_P01';'TOPO';'TOPO_P01'};
% cexp=[87 198 229; 87 198 229;     95 85 147;   95 85 147;    24 88 139;   24 88 139
%        146 200 101;  146 200 101;   242 155 0;   242 155 0; ]/255;

exptext='diffpertU002';
expri1={'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';
        'TWIN042Pr001qv062221';'TWIN042Pr0001qv062221';        
        'TWIN013Pr001qv062221';'TWIN013Pr0001qv062221';
        'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221'};   
expri2={'TWIN201B';'TWIN201B';'TWIN042B';'TWIN042B';'TWIN013B';'TWIN013B';'TWIN003B';'TWIN003B'}; 
expnam={'FLAT';'FLAT_P01';'U00_FLAT';'U00_FLAT_P01';'H500';'H500_P01';'TOPO';'TOPO_P01'};
cexp=[87 198 229; 87 198 229;     95 85 147;   95 85 147;  
       146 200 101;  146 200 101;   242 155 0;   242 155 0; ]/255;

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
% cexp=[87 198 229; 143 189 227;     242 155 0; 211 127 143;     146 200 101;  170 178 84]/255; 


% expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221noMP';'TWIN201Pr0025THM062221';'TWIN201Pr0025THM062221noMP'};  
% expri2={'TWIN201B';'TWIN201B062221noMP';'TWIN201B';'TWIN201B062221noMP'};
% exptext='THMnoMP';
% expnam={'FLAT';'FLATnoMP';'FLAT_THM';'FLAT_THMnoMP'};
% cexp=[87 198 229; 143 189 227;    28 88 119;  12 12 66 ]/255; 


% expri1={'TWIN201Pr001qv062221';'TWIN003Pr001qv062221';'TWIN013Pr001qv062221';
%         'TWIN001Pr0025THM062221';'TWIN003Pr0025THM062221';'TWIN013Pr0025THM062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B';'TWIN001B';'TWIN003B';'TWIN013B'}; exptext='THM25';
% expnam={'FLAT';'TOPO';'H500';'FLAT_THM25';'TOPO_THM25';'H500_THM25'};
% cexp=[87 198 229; 242 155 0; 146 200 101;  28 88 119; 171 106 105; 125 127 55]/255; 

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

% linexp={'-';'-';'-';':';':';':'};
linexp={'-';':';'-';':';'-';':';'-';':';'-';':'};
% linexp={'-';'--';'-';'--';'-';'--';'-';'--'};

% exptext='noMP';  fignam=[plotid,'_Ts_',exptext,'_'];
% cexp=[87 198 229; 143 189 227;     242 155 0; 211 127 143;     146 200 101;  170 178 84]/255; 
% expnam={'FLAT';'FLATnoMP';'TOPO';'TOPOnoMP';'H500';'H500noMP'};


% hf=figure('position',[100 55 1200 600]);
hf=figure('position',[100 55 1000 600]);
plotexp=[1 2 3 4 7 8];
% plotexp=1:nexp;
% plotexp=[1 2 5 6 3 4];
for ei=plotexp
  h(ei)= plot(DTE_dm(ei,:),linexp{ei},'LineWidth',4.5,'color',cexp(ei,:)); hold on
%   h(ei)= plot(DTE_dm(ei,:),'LineWidth',4.5,'color',cexp(ei,:)); hold on
%   if plotarea~=0
%     for ai=1
%       plot(DTE_am(ei,:,ai),linestyl{ai},'LineWidth',2.5,'color',cexp(ei,:));hold on
%     end
%   end
end
legh=legend(h(plotexp),expnam{plotexp},'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Monospaced');
% ni=0;  lgnd=cell(nexp*(narea),1);
% for ei=plotexp
%   for ai=0:1
%     ni=ni+1;
%     lgnd{ni}=[expnam{ei},' (',arenam{ai+1},')'];
%   end
% end
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Monospaced');
%
%---
set(gca,'Linewidth',1.2,'fontsize',20)
set(gca,'YScale','log');  %
% set(gca,'Ylim',[2e-4 2e1])
% set(gca,'Ylim',[1e-6 2e1])
set(gca,'Ylim',[1e-6 3e1])
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
