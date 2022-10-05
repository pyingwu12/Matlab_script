clear;  ccc=':';
% close all

saveid=1; % save figure (1) or not (0)

%---setting      

expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
exptext='diffTOPO';
expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255; 

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% cexp=[87 198 229; 242 155 0;       24 126 218; 242 80 50;      75 70 154;  155 55 55]/255; %R3

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B'}; 
% exptext='H500';
% expnam={'FLAT';'TOPO';'H500'};
% cexp=[87 198 229; 242 155 0; 146 200 101]/255; 

%---
plotid='FSS';
acch=1;  thres=1;  scales=[1 10 40];
% nnx=1; nny=nnx;
%---
sthrs=22:33; minu=[0 20 40];  tint=1;
% sthrs=22:30; minu=[0 30];  tint=1;
%---
year='2018'; mon='06'; stday=22;  
dom='01';  infilenam='wrfout';
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam=[num2str(acch),'-h rainfall'];   fignam=['accum_',plotid,'_',exptext,'_'];

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
      for nxi=1:length(scales)
        nnx=scales(nxi); nny=nnx;
        [fss(ei,nti,nxi),fss_use(ei,nti,nxi)]=cal_FSS(rain1,rain2,nnx,nny,thres);
      end
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
  h(ei)=plot(fss(ei,:,1),'LineWidth',4,'color',cexp(ei,:),'linestyle','-'); hold on
end
for ei=1:nexp    
  plot(fss(ei,:,2),'LineWidth',3.5,'color',cexp(ei,:),'linestyle','-.'); 
end
for ei=1:nexp    
  plot(fss(ei,:,3),'LineWidth',2,'color',cexp(ei,:),'linestyle','-'); 
end
% for ei=1:nexp    
%   plot(fss(ei,:,4),'LineWidth',2,'color',cexp(ei,:),'linestyle','--'); 
% end

for ei=1:nexp    
  plot(fss_use(ei,:,1),'LineWidth',0.5,'color',cexp(ei,:),'linestyle',':'); 
end

legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'location','sw','FontName','Consolas');

set(gca,'Xlim',[-1.5 ntime-1.5],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',20)
% 
xlabel(['Start time of ',num2str(acch),'-h rainfall (LT)']);  ylabel(plotid)
tit=[titnam,'  ',plotid,'  (n=',num2str(scales),', thres=',num2str(thres),')'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',num2str(length(sthrs)),'hr_',num2str(nminu),'min_acch',num2str(acch),...
            '_', num2str(length(scales)),'scales',num2str(scales(end)),'_th',num2str(thres)];
if saveid~=0
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
