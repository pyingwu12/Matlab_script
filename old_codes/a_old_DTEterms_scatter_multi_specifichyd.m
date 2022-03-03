
% plot scatter plot of summation of hydrometeor to mean of terms of DTE
% P.Y. Wu @ 2021.02.08

% close all
clear; ccc=':';

%---experiments---
% expri1 ={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp0103';
% expri2 ={'TWIN001B';'TWIN003B'};
% expnam ={'FLAT';'TOPO'};
% expmark={'o';'^'};

expri1 ={'TWIN001Pr001THM062221';'TWIN003Pr001THM062221';'TWIN013Pr001THM062221'};   exptext='exp13THM';
expri2 ={'TWIN001B';'TWIN003B';'TWIN013B'};
expnam ={'FLAT';'H10V10';'H05V10THM'};
expmark={'s';'^';'p'};

% exptext='allTHM';
% 
% expri1={'TWIN001Pr001THM062221';...
%        'TWIN017Pr001THM062221';'TWIN013Pr001THM062221';'TWIN022Pr001THM062221';
%        'TWIN025Pr001THM062221';'TWIN019Pr001THM062221';'TWIN024Pr001THM062221';
%        'TWIN021Pr001THM062221';'TWIN003Pr001THM062221';'TWIN020Pr001THM062221';
%        'TWIN023Pr001THM062221';'TWIN016Pr001THM062221';'TWIN018Pr001THM062221'
%         };
% 
% expri2={'TWIN001B';...
%         'TWIN017B';'TWIN013B';'TWIN022B';
%         'TWIN025B';'TWIN019B';'TWIN024B';
%         'TWIN021B';'TWIN003B';'TWIN020B';       
%         'TWIN023B';'TWIN016B';'TWIN018B'
%         };    
%    
% expnam={'FLAT';
%        'v05h05';'v10h05';'v20h05';
%        'v05h07';'v10h07';'v20h07';
%        'v05h10';'v10h10';'v20h10';
%         'v05h20';'v10h20';'v20h20'
%         };
%     
% expmark={'s';        
%          'o'; '^'; 'p';         
%          'o'; '^'; 'p';
%          'o'; '^'; 'p';
%          'o'; '^'; 'p';
%          };
%      
     cexp=[0.1 0.1 0.1; 
    0.85,0.325,0.098; 0.85,0.325,0.098;  0.85,0.325,0.098; 
    0.929,0.694,0.125; 0.929,0.694,0.125;  0.929,0.694,0.125; 
    0.466,0.674,0.188; 0.466,0.674,0.188; 0.466,0.674,0.188;  
    0.3,0.745,0.933;  0.3,0.745,0.933;  0.3,0.745,0.933;
    ];


hydlim1=0.1;
hydlim2=100;

stday=22;   hrs=[23 24 25 26 27];  minu=0:10:50;  
ploterm='DTE'; % KE, ThE, LH, or DTE

%---area setting---
% xarea=1:150;  yarea=76:175; areatext='moun';
% xarea=151:300;  yarea=201:300; areatext='flat';
xarea=1:300;  yarea=1:300;  areatext='whole';
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
if strcmp(ploterm,'DTE')==1
  titnam='cloud amount to DTE';  fignam=['DTE2hyd',num2str(hydlim1*10,'%.2d'),num2str(hydlim2),'_',exptext,'_'];
else
  titnam=['cloud amount to ',ploterm,' difference'];  fignam=['Diff',ploterm,'2hyd',num2str(hydlim1*10,'%.2d'),num2str(hydlim2),'_',exptext,'_'];
end
%
nexp=size(expri1,1); 

%---plot
for ei=1:nexp  
  npi=0;
  for ti=hrs 
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for tmi=minu
      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
%       zh_max2=cal_zh_cmpo(infile2,'WSM6');  zh_mean(nti)=mean(mean(  zh_max2(xarea,yarea)  ));
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd = sum(qr+qc+qg+qs+qi,3); 
      hyd_m=sum(sum(hyd(xarea,yarea)));           
      
      if hyd_m > hydlim1 && hyd_m <= hydlim2
          npi=npi+1;
      %---      
        [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2); 
        dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
        dPall = P.f2(:,:,end)-P.f2(:,:,1);
        dPm = dP./repmat(dPall,1,1,size(dP,3)); 
      %
        if strcmp(ploterm,'DTE')==1
          DTE3D = KE + ThE + LH ;
          DiffE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + Ps;
        else
          eval(['DiffE2D = sum(dPm.*',ploterm,'(:,:,1:end-1),3);'])
        end
        DiffE_m{ei}(npi)=mean(mean(DiffE2D(xarea,yarea)));        
        hyd_sum{ei}(npi)=hyd_m;  
        
      elseif hyd_m > hydlim2
          
         break 
      
      end
    
    end % mi
      if hyd_m > hydlim2
        break       
      end
    disp([s_hr,s_min,' done'])
  end %ti  
  disp([expri2{ei},' done'])
end %ei

%%



hf=figure('Position',[100 65 1100 500]);

for ei=1:nexp
    % plot(hyd_m{ei},DiffE_m{ei},expmark{ei},'MarkerSize',9,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:));    hold on  
plot(hyd_sum{ei},DiffE_m{ei},expmark{ei},'MarkerSize',9,'linestyle','-','MarkerFaceColor',cexp(ei,:),'MarkerEdgeColor',cexp(ei,:),'color',cexp(ei,:));    hold on  
end

legend(expnam,'location','eastout','fontsize',18)

set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
xlabel('Amount of hydrometeor (kg/kg)'); 
ylabel(['Mean of ',ploterm,' (J/kg)']);
title([titnam,'  (area: ',areatext,')'],'fontsize',18)

%---plot legent for experiments---
% xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
% for ei=1:nexp  
%   plot(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.5*ei) ,expmark{ei},'MarkerSize',10,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
%   text(10^(log10(xlimit(1))+0.4) , 10^(log10(ylimit(2))-0.5*ei) ,expnam{ei},'fontsize',18,'FontName','Monospaced'); 
% end
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(length(hrs)),'hrs','min',num2str(minu(1)),num2str(minu(2)),'_',areatext];
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
