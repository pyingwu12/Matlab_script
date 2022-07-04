clear;  ccc=':';
% close all

saveid=0; % save figure (1) or not (0)

%---setting      
expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
exptext='diffTOPO';
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
expnam={'ORI_H00V00';'ORI_H10V10';'ORI_H05V10';'ORI_H10V05';'ORI_H10V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;


% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
% exptext='U00NS5';
% % expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% expnam={'ORI_H00V00';'ORI_H10V10';'NS5_H00V00';'NS5_H10V10';'U00_H00V00';'U00_H10V10'};
% cexp=[87 198 229; 242 155 0;   24 126 218;  242 80 50;    75 70 154; 155 55 55 ]/255;




%---setting
thres=1;  nnx=1; nny=nnx;
%---
intm=20;
stday=22;  sthr=22;  accm=00:intm:720;  
year='2018'; mon='06';  dom='01';  infilenam='wrfout'; 
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
% indir='D:expri_twin';   %outdir='D:figures\expri_twin';
% outdir='G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin';
titnam='Rainfall FSS';   fignam=['accum_fss_',exptext,'_'];

nexp=size(expri1,1);
ntime=length(accm)-1;
%---
fss=zeros(nexp,ntime); %rmse=zeros(nexp,ntime); ETS=zeros(nexp,ntime); bias=zeros(nexp,ntime); 
for ei=1:nexp
    %%
  nti=0;     

  s_date=num2str(stday,'%2.2d');   s_hr=num2str(sthr,'%2.2d'); s_min= num2str(accm(1),'%2.2d');
  
  infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    rall1{1} = ncread(infile1,'RAINC');
    rall1{1} = rall1{1} + ncread(infile1,'RAINSH');
    rall1{1} = rall1{1} + ncread(infile1,'RAINNC');
  infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    rall2{1} = ncread(infile2,'RAINC');
    rall2{1} = rall2{1} + ncread(infile2,'RAINSH');
    rall2{1} = rall2{1} + ncread(infile2,'RAINNC');  
  
  for ai=accm(2:end)
      nti=nti+1;
     
      s_min=num2str(mod(ai,60),'%2.2d');
      s_hr=num2str(mod(sthr+fix(ai/60),24),'%2.2d');
      s_date=num2str(stday+fix( (sthr+fix(ai/60)) /24),'%2.2d'); 
      
      %------read netcdf data--------
      infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];      
      rall1{2} = ncread(infile1,'RAINC');
      rall1{2} = rall1{2} + ncread(infile1,'RAINSH');
      rall1{2} = rall1{2} + ncread(infile1,'RAINNC');
      %---
      infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      rall2{2} = ncread(infile2,'RAINC');
      rall2{2} = rall2{2} + ncread(infile2,'RAINSH');
      rall2{2} = rall2{2} + ncread(infile2,'RAINNC');   
      
      rain1=double(rall1{2}-rall1{1});
      rain2=double(rall2{2}-rall2{1});
      %--------------------
      [nx, ny]=size(rain1);
%       [scc(ei,nti), ~, ~, ~]=cal_score(reshape(rain1,nx*ny,1),reshape(rain2,nx*ny,1),thres);  
thres2=thres/60*ai;
       fss(ei,nti)=FSS(rain1,rain2,nnx,nny,thres2);
% disp([s_date,s_hr,s_min,' done'])

  end %ai  
  %%
  disp([expri1{ei},' done'])
end %exp
% fss(fss==0)=NaN;

%%
%---set title and filename text
  titext=['accumulated from ',num2str(mod(sthr+9,24),'%2.2d'),' LT'];
%---plot
lexp={'-';'-';'-';'-';'-';'-';'-';'-';'-';'-'};  

hf=figure('position',[100 55 900 600]);
for ei=1:nexp
 h(ei)=plot(fss(ei,:),'LineWidth',5,'color',cexp(ei,:),'linestyle',lexp{ei}); hold on
end
% legh=legend(h,expnam,'Box','off','Interpreter','none','fontsize',26,'location','sw','FontName','Liberation Mono');

set(gca,'Xlim',[0.5 ntime+0.5],'XTick',60/intm:60/intm:ntime,'XTickLabel',1:fix(ntime/(60/intm)),'fontsize',20,'linewidth',1.2)
set(gca,'Ylim',[0.2 1],'YTick',0:0.2:1)
xlabel('Accumulated period (h)');  ylabel('FSS')
tit=[titnam,' (',titext,')'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthr(1),'%2.2d'); s_edh=num2str(mod(sthr(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),num2str(sthr,'%2.2d'),...
    num2str(accm(1),'%.2d'),'_',num2str(accm(end)),'m','_thr',num2str(thres),'_n',num2str(nnx)];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}