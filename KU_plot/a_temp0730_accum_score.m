clear;  ccc=':';
close all
%---setting      

exptext='temp0730';   
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';...
    'TWIN013Pr001qv062221';'TWIN017Pr001qv062221';'TWIN017Pr0025THM062221'};   
expri2={'TWIN001B';'TWIN003B';'TWIN013B';'TWIN017B';'TWIN017B'};   
expnam={'FLAT';'TOPO';'LOW_TOPO';'SMALL_TOPO_qv';'SMALL_TOPO_THM'};
explin={'-';'-';'-';'-';'--'};
cexp=[0.3 0.3 0.3; 0.85,0.325,0.098;  0.466,0.674,0.188; 0.3,0.745,0.933; 0.3,0.745,0.933 ];


plotarea=0;
%---setting
% sthrs=0:10;  acch=3;  thres=1;
sthrs=0;  acch=1:10;  thres=1;  
year='2018'; mon='06'; stday=23; minu='00';
dom='01';  infilenam='wrfout'; 
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='Rainfall score';   fignam=['accum_score_',exptext,'_'];

%---set area
%
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
nexp=size(expri1,1);
ntime=length(sthrs)*length(acch);
%---
scc=zeros(nexp,ntime); %rmse=zeros(nexp,ntime); ETS=zeros(nexp,ntime); bias=zeros(nexp,ntime); 
for ei=1:nexp
%     [scc(i,:), rmse(i,:), ETS(i,:), bias(i,:)]=cal_accum_score(indir,expri1{i},expri2{i},ymdm,sthrs,acch,dom,xarea,yarea,thres,ccc);
  nti=0;       
  for ti=sthrs
    for ai=acch
      nti=nti+1;  rall1=cell(1,2); rall2=cell(1,2); 
      for j=1:2
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile1 = [indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
      rall1{j} = ncread(infile1,'RAINC');
      rall1{j} = rall1{j} + ncread(infile1,'RAINSH');
      rall1{j} = rall1{j} + ncread(infile1,'RAINNC');
      %---
      infile2 = [indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
      rall2{j} = ncread(infile2,'RAINC');
      rall2{j} = rall2{j} + ncread(infile2,'RAINSH');
      rall2{j} = rall2{j} + ncread(infile2,'RAINNC');   
      end %j=1:2
      rain1=double(rall1{2}-rall1{1});
      rain2=double(rall2{2}-rall2{1});
      %--------------------
      [nx, ny]=size(rain1);
      [scc(ei,nti), ~, ~, ~]=cal_score(reshape(rain1,nx*ny,1),reshape(rain2,nx*ny,1),thres);   
  
    end %ai
  end %ti      
  disp([expri1{ei},' done'])
end %exp
%%
%---set x tick---
nti=0; ss_hr=cell(ntime,1);
for ti=sthrs
  for ai=acch
    nti=nti+1;
    if length(sthrs)<length(acch)     
      ss_hr{nti}=[num2str(ai),'h'];
    elseif length(sthrs)>length(acch)
      ss_hr{nti}=num2str(mod(ti+9,24),'%2.2d');
    end
  end 
end

%---set title and filename text
if length(sthrs)<length(acch)     
  titext=['accumulated from ',num2str(mod(sthrs+9,24),'%2.2d'),' LT'];
  fitext=['from',num2str(sthrs,'%2.2d'),'_',num2str(length(acch)),'acch'];
  xtit='Accumulated period';
elseif length(sthrs)>length(acch)
  titext=['every ',num2str(ai),'h'];
  fitext=[num2str(length(sthrs)),'steps_',num2str(acch),'h'];
  xtit='Local time';
end
%%
%---plot
hf=figure('position',[100 45 1000 600]);

for ei=1:nexp
  plot(scc(ei,:),'LineWidth',3,'color',cexp(ei,:),'linestyle',explin{ei}); hold on
end
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','sw','FontName','Consolas');
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'location','ne','FontName','Consolas');
%
set(gca,'Xlim',[0 ntime+1],'XTick',1:ntime,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel(xtit);  ylabel('SCC')
tit=[titnam,' SCC (',titext,')'];   
title(tit,'fontsize',19)
%
s_sth=num2str(sthrs(1),'%2.2d'); s_edh=num2str(mod(sthrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',fitext];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
