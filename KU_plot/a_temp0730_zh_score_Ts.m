
clear;  ccc=':';
close all


% exptext='twin015';   
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN015Pr001qv062221'};   
% expri2={'TWIN001B';'TWIN003B';'TWIN015B'};   
% expnam={'FLAT';'TOPO';'TOPO250'};
% cexp=[0  0.447  0.741; 0.85,0.325,0.098;  0.466,0.674,0.188  ];
%

% exptext='exp010313';   
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN013Pr001qv062221'};   
% expri2={'TWIN001B';'TWIN003B';'TWIN013B'};   
% expnam={'FLAT';'H10';'H05'};
% cexp=[0  0.447  0.741; 0.85,0.325,0.098;  0.466,0.674,0.188  ];

% expri1={'TWIN001Pr001qv062221';'TWIN001Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr01qv062221'};   
% expri2={'TWIN001B';'TWIN001B';'TWIN003B';'TWIN003B'}; 
% exptext='qv01';
% expnam={'FLAT_qv001';'FLAT_qv01';'TOPO_qv001';'TOPO_qv01'};
% cexp=[ 0 0.447 0.741; 0.3 0.745 0.933;  0.85,0.325,0.098; 0.929,0.694,0.125]; 

exptext='temp0730';   
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';...
    'TWIN013Pr001qv062221';'TWIN017Pr001qv062221';'TWIN017Pr0025THM062221'};   
expri2={'TWIN001B';'TWIN003B';'TWIN013B';'TWIN017B';'TWIN017B'};   
expnam={'FLAT';'TOPO';'LOW_TOPO';'SMALL_TOPO_qv';'SMALL_TOPO_THM'};
explin={'-';'-';'-';'-';'--'};
cexp=[0.3 0.3 0.3; 0.85,0.325,0.098;  0.466,0.674,0.188; 0.3,0.745,0.933; 0.3,0.745,0.933 ];

%---setting
stday=22;   sth=23;   lenh=9;  minu=0:10:50;   tint=2;  thres=5;  plotarea=0;
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin/temp0730';

%
titnam='Zh score';   fignam=['zh_score_',exptext,'_'];
%

if plotarea~=0; narea=size(xarea,1); else; narea=0; end
nexp=size(expri1,1);  nminu=length(minu);  ntime=lenh*nminu;
%%
%---
ntii=0;
% scc=zeros(nexp,ntime); %rmse=zeros(nexp,ntime); ETS=zeros(nexp,ntime); bias=zeros(nexp,ntime); 
for ei=1:nexp
  nti=0;
  for ti=1:lenh 
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if mod(ti,tint)==0 
      ntii=ntii+1;    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end   
    for tmi=minu 
      nti=nti+1;     s_min=num2str(tmi,'%2.2d');           
      %------read netcdf data--------
      infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      zh_max1=cal_zh_cmpo(infile1,'WSM6');   
      %---
      infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      zh_max2=cal_zh_cmpo(infile2,'WSM6');    
      %--------------------
      [nx, ny]=size(zh_max1);
      [scc(ei,nti), ~, ~, ~]=cal_score(reshape(zh_max1,nx*ny,1),reshape(zh_max2,nx*ny,1),thres);
      
        
      if mod(nti,5)==0; disp([s_hr,s_min,' done']); end
    end %tmi
  end %ti      
  disp([expri1{ei},' done'])
end %exp
%%
%---plot
hf=figure('position',[100 45 1000 600]);
for ei=1:nexp
  plot(scc(ei,:),'LineWidth',3,'color',cexp(ei,:),'linestyle',explin{ei}); hold on
end
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','ne','FontName','Monospaced');
%
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',16)
set(gca,'ylim',[0.2 1.05])
xlabel('Local time');  ylabel('SCC')
tit=[titnam,' SCC'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
