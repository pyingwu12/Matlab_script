clear;  ccc=':';
% close all

saveid=0; % save figure (1) or not (0)

%---setting      

expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
exptext='diffTOPO';
expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255; 

%---
plotid='FSS';
thres=0.1;  nnx=50; nny=nnx;
%---
sthrs=22:33; minu=[0 20 40];  acch=1; tint=1;
%---
year='2018'; mon='06'; stday=22;  
dom='01';  infilenam='wrfout';
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='Hourly rainfall';   fignam=['accum_',plotid,'_',exptext,'_'];

%
nexp=size(expri1,1);
nminu=length(minu); 
ntime=length(sthrs)*nminu;
%---
ntii=0;  fss=zeros(nexp,ntime);
%
for ei=1:nexp
  nti=0;  
%   if ~exist([indir,'/',expri1{ei}],'dir')
%      continue
%   end
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
%        if exist([indir,'/',expri1{ei}],'dir') && ~exist(infile1,'file') 
%         fss(ei,nti)=NaN;
%         continue
%        end
       rall1{j} = ncread(infile1,'RAINC');
       rall1{j} = rall1{j} + ncread(infile1,'RAINSH');
       rall1{j} = rall1{j} + ncread(infile1,'RAINNC');
       %---
       infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
       rall2{j} = ncread(infile2,'RAINC');
       rall2{j} = rall2{j} + ncread(infile2,'RAINSH');
       rall2{j} = rall2{j} + ncread(infile2,'RAINNC');   
      end %j=1:2      
%       if isnan(fss(ei,nti))
%           continue
%       end
      rain1=double(rall1{2}-rall1{1});  rain1(rain1+1==1)=0;
      rain2=double(rall2{2}-rall2{1});  rain2(rain2+1==1)=0;     
      %--------------------
      fss(ei,nti)=cal_FSS(rain1,rain2,nnx,nny,thres);
    end
  end %ti      
  disp([expri1{ei},' done'])
end %exp
fss(fss==0)=NaN;
%%
%---plot
linestyl={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};
%
hf=figure('position',[100 55 900 600]);
for ei=1:nexp
% for ei=[0*5+(1:5) 2*5+(1:5) 1*5+(1:5) 4*5+(1:5) 3*5+(1:5)]
    
%   colei=ceil(ei/5);
%   h(colei)=plot(rain_score(ei,:),'LineWidth',2,'color',cexp(colei,:)); hold on

  h(ei)=plot(fss(ei,:),'LineWidth',5,'color',cexp(ei,:),'linestyle',linestyl{ei}); hold on

%   if plotarea~=0
%     for ari=1:narea
%       plot(rain_score_area(ei,:,ari),'LineWidth',2.2,'color',cexp(ei,:),'linestyle',linestyl{ari},...
%             'marker',markersty{ari},'MarkerSize',5,'MarkerFaceColor',cexp(ei,:));
%     end
%   end
end
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','ne','FontName','Consolas');
%
% legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'location','sw','FontName','Consolas');
%
% set(gca,'Xlim',[0 ntime+1],'XTick',1:ntime,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
%%
set(gca,'Xlim',[-1.5 ntime-1.5],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',20)

xlabel('Start time of hourly rainfall (LT)');  ylabel(plotid)
tit=[titnam,'  ',plotid,'  (n=',num2str(nnx),')'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',num2str(length(sthrs)),'hr_',num2str(nminu),'min_acch',num2str(acch)];
if saveid~=0
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
