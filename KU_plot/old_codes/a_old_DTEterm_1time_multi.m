% close all
clear;  ccc=':';
%----------------
%
% expri={'TWIN001B';'TWIN003B'};   exptext='twin0103B';   bdy=0;  
% expnam={'FLAT_cntl';'TOPO_cntl'};
% lexp={'-';'-';'-';'-'};  
% cexp=[0  0.447  0.741;0.85,0.325,0.098];

exptext='all';   ploterm='DTE'; 
% xarea=1:150;  yarea=50:150;   areatext='moun1';
xarea=1:300;  yarea=1:300;   areatext='whole';

expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'
        };

expri2={'TWIN001B';...
       'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
       'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'
        };    
   
expnam={'FLAT';
       'v05h05';'v10h05';'v20h05';
       'v05h07';'v10h07';'v20h07';
       'v05h10';'v10h10';'v20h10';
        'v05h20';'v10h20';'v20h20'
        };

hyd_tre=10;
s_hr1={ '01';  '00';'00';'00';  '00';'00';'00';   '00';'00';'00';   '00';'00';'00'   };
s_hr2={ '01';  '00';'00';'00';  '00';'00';'00';   '00';'00';'00';   '01';'00';'00'   };   
s_min1={'20';  '30';'40';'40';  '40';'20';'30';   '40';'40';'30';   '50';'40';'10'   };
s_min2={'30';  '40';'50';'50';  '50';'30';'40';   '50';'50';'40';   '00';'50';'20'   };      

%hyd_tre=55;
% s_hr1={ '03';  '01';'01';'01';  '01';'00';'01';   '01';'00';'01';   '01';'01';'01'   };
% s_min1={'30';  '00';'20';'10';  '30';'50';'20';   '30';'50';'00';   '20';'00';'00'   };
% s_hr2={ '03';  '01';'02';'01';  '01';'01';'01';   '01';'01';'02';   '01';'02';'01'   };   
% s_min2={'40';  '10';'20';'20';  '40';'00';'30';   '40';'50';'00';   '30';'00';'10'   };   

to_wide=[150 50 70 100 40.7 57 81.4 35 50 70 25 35 50];
to_height=[500 500 500 500 750 750 750 1000 1000 1000 2000 2000 2000];



% cexp=[0.1 0.1 0.1; 
%     0.3,0.745,0.933; 0  0.447  0.741;  0 0.3 0.55; 
%     0.85,0.1,0.9; 0.494,0.184,0.556; 0.4 0.01 0.35;  
%     0.49 0.8 0.22; 0.466,0.674,0.188; 0.3 0.45 0.01;  
%     0.929,0.694,0.125; 0.85,0.325,0.098;  0.65,0.125,0.008
%     ];
cexp=[0.1 0.1 0.1; 
    0.929,0.894,0.125; 0.929,0.894,0.125;  0.929,0.894,0.125; 
    0.929,0.694,0.125; 0.929,0.694,0.125;  0.929,0.694,0.125; 
    0.85,0.325,0.098; 0.85,0.325,0.098; 0.85,0.325,0.098;  
    0.65,0.125,0.008;  0.65,0.125,0.008;  0.65,0.125,0.008;
    ];

expmark={'o';
         '^';'s';'p';
         '^';'s';'p';
         '^';'s';'p';
         '^';'s';'p'
         };
   
%---setting
year='2018';  mon='06';  s_date='23'; 
infilenam='wrfout';  dom='01';
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='Zh';    fignam=['zh_',exptext,'_'];
nexp=size(expri1,1); 

load('colormap/colormap_dte.mat')
cmap=colormap_dte; 
%  Lmap=[0.5 2 4 6 8 10 15 20 25 35];

%---
% hf=figure('Position',[100 65 900 500]);    

for ei=1:nexp   
    %%
     infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr1{ei},ccc,s_min1{ei},ccc,'00'];
     infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr1{ei},ccc,s_min1{ei},ccc,'00'];     
     
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
      DiffE_m1=mean(mean(DiffE2D(xarea,yarea)));  

      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd = sum(qr+qc+qg+qs+qi,3); 
      hyd_m1=sum(sum(hyd(xarea,yarea)));        
      
      %---
          
     infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr2{ei},ccc,s_min2{ei},ccc,'00'];
     infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr2{ei},ccc,s_min2{ei},ccc,'00'];     
     
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
      DiffE_m2=mean(mean(DiffE2D(xarea,yarea)));  

      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd = sum(qr+qc+qg+qs+qi,3); 
      hyd_m2=sum(sum(hyd(xarea,yarea)));    
      %---           
%       DiffE_10(ei)=interp1([hyd_m1 hyd_m2],log10([DiffE_m1 DiffE_m2]),10,'linear');     
      DiffE_10(ei)=interp1([hyd_m1 hyd_m2],[DiffE_m1 DiffE_m2],hyd_tre,'linear');

%       plot(to_height,to_wide,DiffE_10(ei),expmark{ei},'MarkerSize',9,'MarkerFaceColor',cexp(ei,:),'MarkerEdgeColor',cexp(ei,:));   hold on 
%       plot_dot(to_wide(ei),to_height(ei),DiffE_10(ei),cmap,Lmap,'o',12)   

      disp([expri2{ei},' done'])
      %%
end % expri
%%
% legend(expnam,'box','off','location','eastoutside','fontsize',14)
 Lmap=[0.007 0.009 0.011 0.013 0.015 0.017 0.019 0.021 0.023 0.025];
%  Lmap=[0.05 0.07 0.09 0.11 0.13 0.15 0.17 0.19 0.21 0.23];
%   Lmap=[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.2 1.4];

hf=figure('Position',[100 65 900 500]);    
for ei=1:nexp
% plot_dot(to_wide(ei),to_height(ei),10^DiffE_10(ei),cmap,Lmap,'o',12)   
plot_dot(to_wide(ei),to_height(ei),DiffE_10(ei),cmap,Lmap,'o',12)   
end    
    L1=((1:length(Lmap))*(diff(caxis)/(length(Lmap)+1)))+min(caxis());
    hc=colorbar('YTick',L1(1:end),'YTickLabel',Lmap(1:end),'fontsize',13,'LineWidth',1.2);
    colormap(cmap);
    title(hc,'J kg^-^1','fontsize',13);  
set(gca,'ylim',[400 2300])
%
% h=[0 500 500 500 750 750 750 1000 1000 1000 ]
% DiffE_10_resh=reshape(DiffE_10(2:end),3,4);
% DiffE_10_resh(4,1)=DiffE_10(1);
% figure
% imagesc(DiffE_10_resh',[0.005 0.03])
% colorbar
