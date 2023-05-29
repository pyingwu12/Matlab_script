close all
clear

ccc=':';
% expri={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'};
%  expnam={'FLAT';'V05H10';'TOPO';'V20H10'};
%  cexp=[0.1 0.1 0.1; 0.93 0.69 0.13; 0.86 0.33 0.10; 0.64 0.08 0.18];
% exptext='H1000';

exptext='all'; 
expri={'TWIN001B';
       'TWIN017B';'TWIN013B';'TWIN022B';
       'TWIN025B';'TWIN019B';'TWIN024B';
       'TWIN021B';'TWIN003B';'TWIN020B';
       'TWIN023B';'TWIN016B';'TWIN018B'};  
   
 expnam={'FLAT';
        'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'TOPO';'V20H10';
        'V05H20';'V10H20';'V20H20'
        };
    
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  
    
cexp=[0.1 0.1 0.1; 
      0.32 0.8  0.95; 0    0.45 0.74; 0.01 0.11 0.63; 
      0.96 0.6  0.79; 0.78 0.19 0.67; 0.47 0.05 0.45;  
      0.95 0.8  0.13; 0.85 0.43 0.10; 0.70 0.08 0.18;
      0.65 0.85 0.35; 0.38 0.6  0.13; 0.01 0.48 0.15
      ];

stday=22;   sth=22;  lenh=12;  minu=0:10:50;   tint=2;

year='2018'; mon='06';  infilenam='wrfout'; dom='01';      
indir='/mnt/HDD123/pwin/Experiments/expri_twin';
outdir='/mnt/e/figures/expri_twin';

titnam=['Number of cloud grids'];   fignam=['Con_Ts_cld_',exptext,'_'];

nexp=size(expri,1);  nminu=length(minu);  ntime=lenh*nminu;

cloudhyd=0.005;  % threshold of definition of cloud area (Kg/Kg)

plotvar1=zeros(nexp,ntime);  plotvar2=zeros(nexp,ntime);  
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
for ei=1:nexp  
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1;   ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile---
      infile=[indir,'/',expri{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];      
      
      qr = double(ncread(infile,'QRAIN'));   
      qc = double(ncread(infile,'QCLOUD'));
      qg = double(ncread(infile,'QGRAUP'));  
      qs = double(ncread(infile,'QSNOW'));
      qi = double(ncread(infile,'QICE')); 
      
      hyd = sum(qr+qc+qg+qs+qi,3);      % vertical sumation of hydrometeors
  
      [nx,ny]=size(hyd);
%       cldgratio(ei,nti)=length(find(hyd>=cloudhyd))/(nx*ny);
      plotvar1(ei,nti)=length(find(hyd>=cloudhyd));      
      
      rephyd =repmat(hyd,3,3);  
      %----definition of cloud area ---  
      BW = rephyd > cloudhyd;  
      %---find individual cloud---  
      stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');
      %---calculate parameters for each cloud area
      if ~isempty(stats)  
          plotvar2(ei,nti)=max(stats.Area);
      else
          plotvar2(ei,nti)=NaN;
      end      
    end
  end
  disp([expri{ei},' done'])
end
%%
hf=figure('position',[100 55 1000 600]);
% hf=figure('position',[100 550 800 500]);
for ei=1:nexp
  plot(plotvar1(ei,:),'LineWidth',2.5,'color',cexp(ei,:)); hold on
end
for ei=1:nexp
  plot(plotvar2(ei,:),'LineWidth',2.5,'color',cexp(ei,:),'linestyle','--');
end
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','best','FontName','Consolas');

%---
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Local time'); ylabel('Grid numbers')  
title(titnam,'fontsize',18)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_cld',num2str(cloudhyd*1000)];

print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

%%
fignam=['Con_Ts_cldmax_',exptext,'_'];
hf=figure('position',[100 55 1000 600]);
% hf=figure('position',[100 550 800 500]);
for ei=1:nexp
  plot(plotvar2(ei,:),'LineWidth',2.8,'color',cexp(ei,:)); hold on
end
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','nw','FontName','Consolas');

%---
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Local time'); ylabel('Grid numbers')  
title(titnam,'fontsize',18)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_cld',num2str(cloudhyd*1000)];

print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
