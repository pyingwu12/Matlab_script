clear;  ccc=':';
% close all
%---setting      
% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
% exptext='diffTOPO';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255; 

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% cexp=[87 198 229; 242 155 0;   44 125 190;  232 66 44;   95 85 147; 168 63 63]/255; 

% exptext='042check';
% expri1={'TWIN042Pr001qv062221';'TWIN042Pr001qv062221mem2';'TWIN042Pr001qv062221mem3';'TWIN042Pr001qv062221mem4';'TWIN042Pr001qv062221mem5'};   
% expri2={'TWIN042B';'TWIN042B';'TWIN042B'; 'TWIN042B';'TWIN042B'}; 
% expnam={'m1';'m2';'m3';'m4';'m5'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;
  
% exptext='FLATOPOdiffpert';
% expri1={'TWIN201Pr01qv062221';'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221';'TWIN201Pr001qv062223';'TWIN201Pr001qv062301'
%         'TWIN003Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221';'TWIN003Pr001qv062223';'TWIN003Pr001qv062301' };   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B';'TWIN201B'
%         'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B'}; 
% expnam={'FLAT_P10';'FLAT';'FLAT_P01';'FLAT_08LT';'FLAT_10LT'
%         'TOPO_P10';'TOPO';'TOPO_P01';'TOPO_08LT';'TOPO_10LT'};
% cexp=[62 158 209;   87 198 229;  154 211 237;     158 169 98;  189 223 110;
%       230 101 99;     242 155 0;   240 220 20;      240 143 152; 246 209 223  ]/255;
  
% expri1={'TWIN201Pr001qv062221';'TWIN201Pr001qv062221mem2';'TWIN201Pr001qv062221mem3';'TWIN201Pr001qv062221mem4';'TWIN201Pr001qv062221mem5';
%         'TWIN003Pr001qv062221';'TWIN003Pr001qv062221mem2';'TWIN003Pr001qv062221mem3';'TWIN003Pr001qv062221mem4';'TWIN003Pr001qv062221mem5';
%         'TWIN013Pr001qv062221';'TWIN013Pr001qv062221mem2';'TWIN013Pr001qv062221mem3';'TWIN013Pr001qv062221mem4';'TWIN013Pr001qv062221mem5';
%         'TWIN021Pr001qv062221';'TWIN021Pr001qv062221mem2';'TWIN021Pr001qv062221mem3';'TWIN021Pr001qv062221mem4';'TWIN021Pr001qv062221mem5'; 
%         'TWIN020Pr001qv062221';'TWIN020Pr001qv062221mem2';'TWIN020Pr001qv062221mem3';'TWIN020Pr001qv062221mem4';'TWIN020Pr001qv062221mem5'};   
% expri2={'TWIN201B';'TWIN201B';'TWIN201B'; 'TWIN201B';'TWIN201B';
%     'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';'TWIN003B';
%     'TWIN013B';'TWIN013B';'TWIN013B';'TWIN013B';'TWIN013B';
%     'TWIN021B';'TWIN021B';'TWIN021B';'TWIN021B';'TWIN021B';
%     'TWIN020B';'TWIN020B';'TWIN020B';'TWIN020B';'TWIN020B'}; 
% exptext='TOPOmem5';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;

expri1={%'TWIN030Pr001qv062221';'TWIN030Pr001qv062221mem2';'TWIN030Pr001qv062221mem3';'TWIN030Pr001qv062221mem4';'TWIN030Pr001qv062221mem5';
        %'TWIN031Pr001qv062221';'TWIN031Pr001qv062221mem2';'TWIN031Pr001qv062221mem3';'TWIN031Pr001qv062221mem4';'TWIN031Pr001qv062221mem5'; 
        'TWIN042Pr001qv062221'%;'TWIN042Pr001qv062221mem2';'TWIN042Pr001qv062221mem3';'TWIN042Pr001qv062221mem4';'TWIN042Pr001qv062221mem5'; 
        %'TWIN043Pr001qv062221';'TWIN043Pr001qv062221mem2';'TWIN043Pr001qv062221mem3';'TWIN043Pr001qv062221mem4';'TWIN043Pr001qv062221mem5'
        };   
expri2={%'TWIN030B';'TWIN030B';'TWIN030B';'TWIN030B';'TWIN030B';
    %'TWIN031B';'TWIN031B';'TWIN031B';'TWIN031B';'TWIN031B';
    'TWIN042B'%;'TWIN042B';'TWIN042B';'TWIN042B';'TWIN042B';
    %'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B';'TWIN043B'
    }; 
exptext='042test';
expnam={'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
cexp=[ 44 125 190;  232 66 44;   95 85 147; 168 63 63]/255; 


saveid=0; % save figure (1) or not (0)

plotid='SCC';
plotarea=0;
%---setting
sthrs=22:33;   minu=0:10:50;  acch=1;
% sthrs=22:33;   minu=[0 20 40];  acch=1;
thres=1;  tint=1;
year='2018'; mon='06'; stday=22;  
dom='01';  infilenam='wrfout';
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
% indir='E:expri_twin'; outdir='E:figures/expri_twin';
titnam='Hourly rainfall';   fignam=['accum1h_',plotid,'_',exptext,'_'];

%---set area
x1=1:150; y1=51:200;    x2=151:300; y2=51:200;  
% x1=1:150; y1=76:175;    x2=151:300; y2=201:300;  
%x1=1:150; y1=51:200;    x2=151:300; y2=[1:50, 201:300];  
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'all';'Mou';'Pla'};
linestyl={'--',':'};   markersty={'none','none'};  
%
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
nexp=size(expri1,1);
 nminu=length(minu); 
ntime=length(sthrs)*nminu;
%---
ntii=0;
SCC=zeros(nexp,ntime); RMSE=zeros(nexp,ntime); %ETS=zeros(nexp,ntime); bias=zeros(nexp,ntime); 
%%
for ei=1:nexp
  nti=0;  
  if ~exist([indir,'/',expri1{ei}],'dir')
     continue
  end
  for ti=sthrs
    if mod(ti-sthrs(1),tint)==0 && ei==1
       ntii=ntii+1;    ss_hr{ntii}=num2str(mod(ti+9,24),'%2.2d');
    end 
    for tmi=minu
      nti=nti+1;  rall1=cell(1,2); rall2=cell(1,2); 
      s_min=num2str(tmi,'%2.2d');  
      for j=1:2
       hr=(j-1)*acch+ti;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
       %------read netcdf data--------
       infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
       if nti==12; disp(infile1); end
       if exist([indir,'/',expri1{ei}],'dir') && ~exist(infile1,'file') 
        SCC(ei,nti)=NaN;
        RMSE(ei,nti)=NaN;
        continue
       end
       rall1{j} = ncread(infile1,'RAINC');
       rall1{j} = rall1{j} + ncread(infile1,'RAINSH');
       rall1{j} = rall1{j} + ncread(infile1,'RAINNC');
       %---
       infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
       rall2{j} = ncread(infile2,'RAINC');
       rall2{j} = rall2{j} + ncread(infile2,'RAINSH');
       rall2{j} = rall2{j} + ncread(infile2,'RAINNC');   
      end %j=1:2      
      if isnan(SCC(ei,nti))
          continue
      end
      rain1=double(rall1{2}-rall1{1});  rain1(rain1+1==1)=0;
      rain2=double(rall2{2}-rall2{1});  rain2(rain2+1==1)=0;     
      %--------------------
      [nx, ny]=size(rain1);
      [SCC(ei,nti), RMSE(ei,nti), ~, ~]=cal_score(reshape(rain1,nx*ny,1),reshape(rain2,nx*ny,1),thres);  
      if plotarea~=0  % area mean 
        for ari=1:narea
            [SCC_area(ei,nti,ari), RMSE_area(ei,nti,ari), ~, ~]=...
                cal_score(reshape(rain1( xarea(ari,:),yarea(ari,:) ),size(xarea,2)*size(yarea,2),1),reshape(rain2( xarea(ari,:),yarea(ari,:) ),size(xarea,2)*size(yarea,2),1),thres);
        end
      end %if plotarea     
 
    end
  end %ti      
  disp([expri1{ei},' done'])
end %exp
%%
eval(['rain_score=',plotid,';'])
rain_score(rain_score==0)=NaN;
      
if plotarea~=0  % area mean 
  eval(['rain_score_area=',plotid,'_area;'])
  rain_score_area(rain_score_area==0)=NaN;
end
%%
%---set legend
% ni=0;  lgnd=cell(nexp*(narea+1),1);
% for ei=1:nexp    
%   for ari=0:narea
%     ni=ni+1;
%     lgnd{ni}=[expnam{ei},'_',arenam{ari+1}];
%   end
% end

%---set title and filename text
  fitext=[num2str(length(sthrs)),'steps_',num2str(acch),'h'];
%%
%---plot

% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';'TOPO';'NS5_TOPO';'U00_TOPO'};
% linestyl={'-';'-';'-';'-';':';':'};
% linestyl={'-';'-';'-';':';':';'-';'-';'-';':';':'};
linestyl={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};


hf=figure('position',[100 55 900 600]);
% for ei=[1 3 5 2 4 6]
for ei=1:nexp
% for ei=[0*5+(1:5) 2*5+(1:5) 1*5+(1:5) 4*5+(1:5) 3*5+(1:5)]
    
%   colei=ceil(ei/5);
%   h(colei)=plot(rain_score(ei,:),'LineWidth',3,'color',cexp(colei,:)); hold on

  h(ei)=plot(rain_score(ei,:),'LineWidth',5,'color',cexp(ei,:),'linestyle',linestyl{ei}); hold on

%   if plotarea~=0
%     for ari=1:narea
%       plot(rain_score_area(ei,:,ari),'LineWidth',2.2,'color',cexp(ei,:),'linestyle',linestyl{ari},...
%             'marker',markersty{ari},'MarkerSize',5,'MarkerFaceColor',cexp(ei,:));
%     end
%   end
end
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','ne','FontName','Consolas');
%
legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',18,'location','sw','FontName','Consolas');
%
% set(gca,'Xlim',[0 ntime+1],'XTick',1:ntime,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
set(gca,'Xlim',[-1.5 ntime-1.5],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime+1,'XTickLabel',7:19,'Linewidth',1.2,'fontsize',20)

xlabel('Start time of hourly rainfall (LT)');  ylabel(plotid)
tit=[titnam,'  ',plotid];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',num2str(length(sthrs)),'hr_',num2str(nminu),'min_acch',num2str(acch)];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
if saveid~=0
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
