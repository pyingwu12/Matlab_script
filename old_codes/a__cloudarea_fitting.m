close all
clear

exptext='h1000'; 
expri1={'TWIN001Pr001qv062223';...
%        'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
%       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
        'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
%         'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221';
        };
         
expri2={'TWIN001B';...
%        'TWIN017B';'TWIN013B';'TWIN022B';
%         'TWIN025B';'TWIN019B';'TWIN024B';
       'TWIN021B';'TWIN003B';'TWIN020B';       
%         'TWIN023B';'TWIN016B';'TWIN018B';
        };   
expnam={'FLAT';
%        'v05h05';'v10h05';'v20h05';
%     'v05h07';'v10h07';'v20h07';
       'v05h10';'v10h10';'v20h10';
%         'v05h20';'v10h20';'v20h20'
        };
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  

col=[0.3 0.3 0.3; 
%     0.3,0.745,0.933; 0  0.447  0.741;  0 0.3 0.55; 
%  0.85,0.1,0.9; 0.494,0.184,0.556; 0.4 0.01 0.35;  
   0.49 0.8 0.22; 0.466,0.674,0.188; 0.3 0.45 0.01;  
%     0.929,0.694,0.125; 0.85,0.325,0.098;  0.65,0.125,0.008;
    ];

hrs={25:26;
%    23:24; 23:24; 24:25;
%    23:24; 23:24; 23:24;
   23:24; 23:24; 23:24;
%     23:24; 23:24; 22:23
    };

%---setting 
% stday=22;   hrs=[22 23 24 25 26 27];  minu=[20 50];   ym='201806';
 stday=22;   %hrs=[21 22 23 24 25];  
 minu=[00 10 20 30 40 50];   ym='201806';
%
cloudhyd=0.005; %threshold of definition of cloud area (Kg/Kg)
areasize=10; %threshold of finding cloud area
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='moist DTE to size of cloud area';   fignam=['moDTE-cloud-fittingline_',exptext,'_'];
%
nexp=size(expri1,1);

%---
hf=figure('Position',[100 65 900 450]);

for ei=1:nexp
  j=1; scale_all=[]; dte_all=[];
  for ti=hrs{ei}
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for mi=minu
      s_min=num2str(mi,'%2.2d');     
      %
      %length(scale_all)
      if length(scale_all)>20; break; end
      cloud=cal_cloudarea_1time(indir,expri1{ei},expri2{ei},ym,s_date,s_hr,s_min,areasize,cloudhyd);    
      if ~isempty(cloud)           
        n=length(cloud.scale);
        scale_all(j:j+n-1)=cloud.scale;
        dte_all(j:j+n-1)=cloud.maxdte;
        j=j+n;              
      end % if ~isempty(cloud)         
    end %min  
    disp([s_hr,s_min,' done'])
  end %hr
  fo = fit(log10(scale_all)',log10(double(dte_all))','poly1');
  x12=[log10(min(scale_all)) log10(max(scale_all))];
  y12=fo.p1.*x12+fo.p2;
  plot(10.^x12,10.^y12,'linewidth',2,'color',col(ei,:),'linestyle',lexp{ei}); hold on
  %
  disp([expri1{ei},' done'])
end % exp

legend(expnam,'Interpreter','none','fontsize',18,'Location','bestoutside');

set(gca,'fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','Yscale','log')
set(gca,'XLim',[6 5e1],'YLim',[1e-3 1e2])
%set(gca,'XLim',[6 1.7e2],'YLim',[1e-2 2e2])
xlabel('Size (km)'); ylabel('Maximum moist DTE');
title(titnam,'fontsize',18)
%
outfile=[outdir,'/',fignam,'20'];
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
