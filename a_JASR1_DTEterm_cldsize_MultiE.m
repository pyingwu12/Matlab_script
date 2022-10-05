% function DTEterm_2_cldarea_size(expri,ploterm)
% plot scatter plot of cloud size to moist DTE over the cloud area
%   the cloud area is detected by the funtion <cal_cloudarea_1time>
%----------------
% one experiment; x-axis: size of cloud area; y-axis: error; color: time 
%----------------
% P.Y. Wu @ 2021.02.05
% 2021/02/11: add <ploterm> option for calculating different terms in the MDTE
% 2021/06/10: standerize variable name of time settings
% 2021/06/16: plot multi experiments
% 2021/09/06: using TPW for detecting cloud area


close all; 
clear; ccc=':';
saveid=1;

expmsize=[19 24 24 29];
% % 
% expri1={'TWIN201Pr001qv062221';'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221'};
% exptext='ORI_H05';
% expri2={'TWIN201B';'TWIN017B';'TWIN013B';'TWIN022B'};    
% expnam={ 'ORI_H00V00';'ORI_H05V05';'ORI_H05V10';'ORI_H05V20'};
% % expnam={ 'FLAT';'H500_V05';'H500';'H500_V20'};
% expmark={'s';'o';'^';'p'}; 
% skipti=9;

% expri1={'TWIN201Pr001qv062221';'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221'};
% exptext='H750';
% expri2={'TWIN201B';'TWIN025B';'TWIN019B';'TWIN024B'};    
% expnam={ 'FLAT';'V05H075';'V10H075';'V20H075'};
% expmark={'s';'o';'^';'p'};   
% skipti=9;

% expri1={'TWIN201Pr0025THM062221';'TWIN025Pr0025THM062221';'TWIN019Pr0025THM062221';'TWIN024Pr0025THM062221'};
% exptext='H750_THM';
% expri2={'TWIN001B';'TWIN025B';'TWIN019B';'TWIN024B'};    
% expnam={ 'FLAT';'V05H075';'V10H075';'V20H075'};
% expmark={'s';'o';'^';'p'};  
% skipti=9;

% expri1={'TWIN201Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
% expri2={'TWIN201B';'TWIN021B';'TWIN003B';'TWIN020B'};    
% % expnam={ 'FLAT';'V05';'TOPO';'V20'};
% expnam={ 'ORI_H00V00';'ORI_H10V05';'ORI_H10V10';'ORI_H10V20'};
% expmark={'s';'o';'^';'p'};     
% exptext='ORI_H10';
% skipti=9;

% expri1={'TWIN042Pr001qv062221';'TWIN045Pr001qv062221';'TWIN043Pr001qv062221';'TWIN046Pr001qv062221'};
% expri2={'TWIN042B';'TWIN045B';'TWIN043B';'TWIN046B'};    
% expnam={ 'U00_H00V00';'U00_H10V05';'U00_H10V10';'U00_H10V20'};
% expmark={'s';'o';'^';'p'};     
% exptext='U00_H10';
% skipti=7;

% expri1={'TWIN030Pr001qv062221';'TWIN047Pr001qv062221';'TWIN031Pr001qv062221';'TWIN048Pr001qv062221'};
% expri2={'TWIN030B';'TWIN047B';'TWIN031B';'TWIN048B'};    
% % expnam={'NS5_FLAT';'NS5_V05';'NS5_TOPO';'NS5_V20'};
% expnam={ 'NS5_H00V00';'NS5_H10V05';'NS5_H10V10';'NS5_H10V20'};
% expmark={'s';'o';'^';'p'};     
% exptext='NS5_H10';
% skipti=7;

% expri1={'TWIN042Pr001qv062221';'TWIN049Pr001qv062221';'TWIN043Pr001qv062221';'TWIN050Pr001qv062221'};
% expri2={'TWIN042B';'TWIN049B';'TWIN043B';'TWIN050B'};    
% expnam={'FLAT';'V05H10';'V10H10';'V20H10'};
% expmark={'s';'o';'^';'p'};     
% exptext='U25_H1000';
% skipti=9;


% expri1={'TWIN201Pr0025THM062221';'TWIN021Pr0025THM062221';'TWIN003Pr0025THM062221';'TWIN020Pr0025THM062221'};
% expri2={'TWIN201B';'TWIN021B';'TWIN003B';'TWIN020B'};    
% expnam={ 'FLAT';'V05H10';'V10H10';'V20H10'};
% expmark={'s';'o';'^';'p'};     
% exptext='H1000_THM';
% skipti=9;


% expri1={'TWIN201Pr001qv062221';'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
% expri2={'TWIN201B';'TWIN023B';'TWIN016B';'TWIN018B'};    
% expnam={ 'FLAT';'V05H20';'V10H20';'V20H20'};
% expmark={'s';'o';'^';'p'};     
% exptext='H2000';
% skipti=9;


% expri1={'TWIN201Pr0025THM062221';'TWIN023Pr0025THM062221';'TWIN016Pr0025THM062221';'TWIN018Pr0025THM062221'};
% expri2={'TWIN201B';'TWIN023B';'TWIN016B';'TWIN018B'};    
% expnam={ 'FLAT';'V05H20';'V10H20';'V20H20'};
% expmark={'s';'o';'^';'p'};     
% exptext='H2000_THM';
% skipti=9;
% 
% expri1={'TWIN201Pr001qv062221';'TWIN003Pr001qv062221'};
% expri2={'TWIN201B';'TWIN003B'};    
% expnam={ 'ORI_H00V00';'ORI_H10V10'};
% expmark={'s';'^'};     
% expmsize=[19 24];
% exptext='FLATOPO2';
% skipti=20;

expri1={'TWIN201Pr001qv062221';'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5'};
expri2={'TWIN201B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B'};    
expnam={ 'ORI_H00V00';'ORI_H10V10';'ORI_H10V10m2';'ORI_H10V10m3';'ORI_H10V10m4';'ORI_H10V10m5'};
expmark={'s';'^';'^';'^';'^';'^'};     
expmsize=[19 24 24 24 24 24 24];
exptext='FLATOPOmem';
skipti=9;


%---setting 
ploterm='CMDTE'; % option: MDTE, CMDTE,  KE, KE3D, SH, LH
% day=22;   hrs=[22 23 24 25 26];   minu=[0 20 40]; 
day=22;   hrs=[23 24 25 26 27];   minu=[0 20 40];  
% day=22;   hrs=[23 24 25 26 27];   minu=[0]; 
%
% cloudhyd=0.003;  % threshold of definition of cloud area (Kg/Kg)
cloudtpw=0.7;
areasize=10;     % threshold of finding cloud area (gird numbers)
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';   outdir='/mnt/e/figures/expri_twin/JAS_R1';
% indir='D:expri_twin';   outdir='D:figures';
titnam=['size of cloud area to ',ploterm];   fignam=[ploterm,'_cldsize','_',exptext,'_'];
%
nexp=size(expri1,1);  nhr=length(hrs); nminu=length(minu);  ntime=nhr*nminu;
%
fload=load('colormap/colormap_ncl.mat');
% col=fload.colormap_ncl([3 8 17 32 58 81 99 126 147 160 179 203],:);
col=fload.colormap_ncl(12:15:end,:);
% col=fload.colormap_ncl([17 32 58 81 99 126 147 160 179 203 219 242],:);

%
%---
hf=figure('Position',[100 65 900 690]);
for ei=1:nexp
  nti=0;
  for ti=hrs 
%     if ei~=1 && ti>25; break; end
%     if ei~=1 && ti>24; break; end
      hr=ti;  s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    for mi=minu        
      nti=nti+1;      s_min=num2str(mi,'%2.2d'); 
%       if ei~=1 && nti>7; break; end
      if ei~=1 && nti>skipti; break; end

      if ei==1
        lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
      end
%       if ei==1 && ti<25; continue; end
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---    
%       cloud=cal_cloudarea_1time(infile1,infile2,areasize,cloudhyd,ploterm);    
      cloud=cal_cloudarea_1time(infile1,infile2,areasize,cloudtpw,ploterm);   
      if ~isempty(cloud) 
          if ei==1; edgcol=col(nti,:); alp=0.7;  else; edgcol='k'; alp=0.8; end
%        plot(cloud.scale,cloud.maxdte,expmark{ei},'MarkerSize',expmsize(ei),'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',edgcol); hold on  
 scatter(cloud.size,cloud.maxdte,expmsize(ei)*10,expmark{ei},'MarkerEdgeColor',edgcol,'MarkerFaceColor',col(nti,:),'MarkerFaceAlpha',alp); hold on

      end % if ~isempty(cloud)

    end % mi
    disp([s_hr,s_min,' done'])
  end %ti
  disp([expri1{ei}(1:7),' done'])
end %ei

set(gca,'fontsize',16,'LineWidth',1.2,'Xscale','log','Yscale','log','box','on') 
set(gca,'XLim',[1e1 5e3],'YLim',[1e-2 2.5e2])
% set(gca,'YLim',[1e-3 4e2])
% set(gca,'XLim',[3.5 30],'YLim',[1e-2 2.5e2])
xlabel({'Size';'(Grid numbers)'}); 
ylabel({'(Mean of first 10 maximum)',[ploterm,' ( J kg^-^1)']});
title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
%%
%---colorbar for time legend----  
tickint=1;
L1=( (1:tickint:ntime)*diff(caxis)/ntime )  +  min(caxis()) -  diff(caxis)/ntime/2;
n=0; for i=1:tickint:ntime; n=n+1; llll{n}=lgnd{i}; end
colorbar('YTick',L1,'YTickLabel',llll,'fontsize',13,'LineWidth',1.2);
colormap(col(1:ntime,:))  
%%
%---plot legent for experiments---
xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
for ei=1:nexp  
  plot(10^(log10(xlimit(2))-1.03) , 10^(log10(ylimit(1))+0.3*ei) ,expmark{ei},'MarkerSize',15,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
  text(10^(log10(xlimit(2))-0.95) , 10^(log10(ylimit(1))+0.3*ei) ,expnam{ei},'fontsize',20,'FontName','Mono','Interpreter','none'); 
end
% for ei=1:nexp  
%   plot(10^(log10(xlimit(2))-0.25) , 10^(log10(ylimit(1))+0.3*ei) ,expmark{ei},'MarkerSize',15,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
%   text(10^(log10(xlimit(2))-0.20) , 10^(log10(ylimit(1))+0.3*ei) ,expnam{ei},'fontsize',20,'FontName','Consolas','Interpreter','none'); 
% end
 %--
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),'_tpw',num2str(cloudtpw*10,'%.2d')];
if saveid==1
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end