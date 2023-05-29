close all
clear; ccc=':';
%---setting

saveid=1; % save figure (1) or not (0)

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
% exptext='diffTOPO';
% % expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% expnam={'ORI_H00V00';'ORI_H10V10';'ORI_H05V10';'ORI_H10V05';'ORI_H10V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 84 80; 239 144 185]/255; 

expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
expnam={'ORI_H00V00';'ORI_H10V10';'NS5_H00V00';'NS5_H10V10';'U00_H00V00';'U00_H10V10'};
cexp=[87 198 229; 242 155 0;       24 126 218; 242 80 50;      75 70 154;  155 55 55]/255;

% 
timemark={'o';'^';'s';'p';'v';'d';'h'};

% stday=22;   sthrs=[23];   acch=[3 6 12]; 
% stday=22;   sthrs=[26 30];   acch=[1]; 
stday=23;   sthrs=[2 5 8];   acch=[1];
% stday=23;   sthrs=[2 5 8];   acch=3;
% stday=23;   sthrs=[2 3 4 5 6 7 8];   acch=[1]; 

filt_len=[1 5 10 15 20 25 35 40 45 50 60 70 80 90 100]; 

thres=1; 
%---
year='2018'; mon='06';  s_min='00';  
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir='/mnt/e/figures/expri_twin/JAS_R2';
% indir='D:expri_twin';   %outdir='D:figures\expri_twin';
% outdir='G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin';
%
titnam='FSS of different scales';   fignam=['accum-fss-scale_',exptext,'_'];
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
%       rainfilt1=low_pass_filter(rain1,fi,dx,dy); 
%       rainfilt2=low_pass_filter(rain2,fi,dx,dy);
%       [FSS(nfi), ~, ~, ~]= cal_score(reshape(rainfilt1,300*300,1),reshape(rainfilt2,300*300,1),3);

      [FSS(nfi), fss_use(nfi)]=cal_FSS(rain1,rain2,fi,fi,thres);    
    end

lgndi=lgndi+1;

    h(lgndi)=plot(FSS,timemark{nti},'color',cexp(ei,:),'linewidth',3,'Markersize',10); hold on

    skidx=(find(FSS>=fss_use,1)); % the scale with score higher than skillful threshold
%     plot(skidx,FSS(skidx),'.','Markersize',12,'color','k','linewidth',1.2)
    cexp2=cexp-0.2; cexp2(cexp2<0)=0;
    plot(skidx,FSS(skidx),'x','Markersize',10,'color','k','linewidth',1.5)

    if ei==1 && nti==1
     lgnd{lgndi}=[expnam{ei},'  ',num2str(mod(ti+9,24),'%2.2d'),s_min,'+',num2str(ai),'h'];
    elseif ei==1
     lgnd{lgndi}=['            ',num2str(mod(ti+9,24),'%2.2d'),s_min,'+',num2str(ai),'h'];
    elseif ei~=1 && nti==1
     lgnd{lgndi}=expnam{ei};
    else
     lgnd{lgndi}='';
    end
  end %acch
  
  clear fss
end %ti
 disp([expri1{ei},' done'])
end

 lh= legend(h,lgnd);
 set(lh,'fontsize',18,'Location','eastoutside','FontName','Monospaced','box','off','Interpreter','none')
 
%%
if length(sthrs)<length(acch)     
  fitext=['from',num2str(sthrs,'%2.2d'),'_',num2str(length(acch)),'acch'];
elseif length(sthrs)>=length(acch)
  sth=num2str(mod(sthrs(1)+9,24),'%.2d'); edh=num2str(mod(sthrs(end)+9,24),'%.2d');
  fitext=[sth,edh,'_',num2str(length(sthrs)),'st_',num2str(acch),'h'];
end
%
set(gca,'fontsize',18,'LineWidth',1.2) 
set(gca,'Ylim',[0.2 1])
set(gca,'xtick',1:length(filt_len),'Xticklabel',filt_len)
xlabel('Length (km)'); ylabel('FSS');
tit=titnam;
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',fitext];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}