close all
clear; ccc='-';
%---setting

saveid=1; % save figure (1) or not (0)

% exptext='H500';
% expri1={'TWIN201Pr001qv062221';'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221'};
% expri2={'TWIN201B';'TWIN017B';'TWIN013B';'TWIN022B'};    
% expnam={ 'FLAT';'V05H05';'V10H05';'V20H05'};
% cexp=[0.4 0.4 0.4;  0.32 0.8  0.95; 0   0.45 0.74; 0.01 0.11 0.63];
% lexp={'-';'-.';'--';'-';':'};

% exptext='H750';
% expri1={'TWIN201Pr001qv062221';'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221'};
% expri2={'TWIN201B';'TWIN025B';'TWIN019B';'TWIN024B'};    
% expnam={'FLAT';'V05H075';'V10H075';'V20H075'};
% cexp=[0.4 0.4 0.4;   0.96 0.6  0.79; 0.78 0.19 0.67; 0.47 0.05 0.45];
% lexp={'-';'-.';'--';'-';':'};

% exptext='H1000';
% expri1={'TWIN201Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
% expri2={'TWIN201B';'TWIN021B';'TWIN003B';'TWIN020B'};    
% expnam={ 'FLAT';'V05H10';'V10H10';'V20H10'};
% cexp=[0.4 0.4 0.4; 0.95 0.8  0.13; 0.85 0.43 0.10; 0.70 0.08 0.18];
% lexp={'-';'-.';'--';'-';':'};

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221mem2'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
% exptext='diffTOPO';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% % cexp=[87 198 229; 242 135 0; 146 200 101; 230 84 80; 239 144 185]/255; 
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 84 80; 239 144 185]/255; 

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% % cexp=[0  50  90; 220 77 11; 0 163 209; 236 121 33; 147 195 233; 239 157 112]/255; 
% cexp=[87 198 229; 242 155 0;       44 125 190;  232 66 44;  95 85 147; 168 63 63]/255; 
% lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';};

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN003Pr001qv062221mem2'; 'TWIN003Pr001qv062221mem3';};   
% expri2={'TWIN201B';'TWIN003B';'TWIN003B'; 'TWIN003B'}; 
% exptext='TOPOmem';
% expnam={'FLAT';'TOPO';'TOPOmem2';'TOPOmem3'};
% cexp=[0,0.447,0.741; 0.85,0.325,0.098;  0.6350 0.0780 0.1840;   0.929,0.694,0.125]; 
% lexp={'-';'-.';'--';'-';':';'-'};


expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221mem2'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
exptext='diffTOPO';
expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 84 80; 239 144 185]/255; 

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221mem2'};   
% expri2={'TWIN201B';'TWIN003B'}; 
% exptext='FLATOPO';
% expnam={'FLAT';'TOPO'};
% cexp=[87 198 229; 242 155 0]/255; 

timemark={'o';'^';'+';'p';'*'};


% stday=22;   sthrs=[23];   acch=[3 6 12]; 
stday=22;   sthrs=[26 30];   acch=[1]; 
filt_len=[1 5 10 15 20 25 35 40 45 50 60 70 80 90 100];  dx=1; dy=1; % km
%---
year='2018'; mon='06';  s_min='00';  
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
% indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir='/mnt/e/figures/expri_twin';
indir='D:expri_twin';   %outdir='D:figures\expri_twin';
outdir='G:/我的雲端硬碟/3.博班/研究/figures/expri_twin';
%
titnam='SCC of accumu. rainfall at different scale';   fignam=['accum-scc-scale_',exptext,'_'];
%
nexp=size(expri1,1);

%---
hf=figure('position',[100 55 1200 600]);
lgndi=0;
for ei=1:nexp
nti=0;
for ti=sthrs
%   s_sth=num2str(ti,'%2.2d');
  for ai=acch
%     s_edh=num2str(mod(ti+ai,24),'%2.2d'); 
    nti=nti+1;
    for j=1:2
      hr=(j-1)*ai+ti;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');

      %---infile 1, perturbed state---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      rall1{j} = ncread(infile1,'RAINC');
      rall1{j} = rall1{j} + ncread(infile1,'RAINSH');
      rall1{j} = rall1{j} + ncread(infile1,'RAINNC');
      %---infile 2, based state---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      rall2{j} = ncread(infile2,'RAINC');
      rall2{j} = rall2{j} + ncread(infile2,'RAINSH');
      rall2{j} = rall2{j} + ncread(infile2,'RAINNC');
    end %j=1:2    
    rain1=double(rall1{2}-rall1{1});   rain1(rain1+1==1)=0;
    rain2=double(rall2{2}-rall2{1});   rain2(rain2+1==1)=0;
    %---- 
    nfi=0;
    for fi=filt_len
      nfi=nfi+1;
      rainfilt1=low_pass_filter(rain1,fi,dx,dy); 
      rainfilt2=low_pass_filter(rain2,fi,dx,dy);
      [scc(nfi), ~, ~, ~]= cal_score(reshape(rainfilt1,300*300,1),reshape(rainfilt2,300*300,1),3);
    end

%     plot(scc,'color',cexp(ei,:),'linewidth',.5,'linestyle',lexp{ei}); hold on
    h=plot(scc,timemark{nti},'color',cexp(ei,:),'linewidth',2.5,'Markersize',10); hold on

    lgndi=lgndi+1;
    if ei==1 && nti==1
     lgnd{lgndi}=[expnam{ei},'  ',num2str(mod(ti+9,24),'%2.2d'),s_min,'+',num2str(ai),'h'];
    elseif ei==1
     lgnd{lgndi}=['      ',num2str(mod(ti+9,24),'%2.2d'),s_min,'+',num2str(ai),'h'];
    elseif ei~=1 && nti==1
     lgnd{lgndi}=expnam{ei};
    else
     lgnd{lgndi}='';
    end
  end %acch
  clear scc
end %ti

end

 lh= legend(lgnd);
 set(lh,'fontsize',20,'Location','eastoutside','FontName','Consolas','box','off')
 
%%
if length(sthrs)<length(acch)     
  fitext=['from',num2str(sthrs,'%2.2d'),'_',num2str(length(acch)),'acch'];
elseif length(sthrs)>=length(acch)
  sth=num2str(mod(sthrs(1)+9,24),'%.2d'); edh=num2str(mod(sthrs(end)+9,24),'%.2d');
  fitext=[sth,edh,'_',num2str(length(sthrs)),'st_',num2str(acch),'h'];
end
%
set(gca,'fontsize',18,'LineWidth',1.2) 
set(gca,'Ylim',[0 1])
set(gca,'xtick',1:length(filt_len),'Xticklabel',filt_len)
xlabel('Wave length (km)'); ylabel('SCC');
tit=titnam;
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',fitext];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}
