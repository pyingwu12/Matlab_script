% close all 
clear; ccc=':';
%---setting
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];   expri2=[expri,'B'];  
stday=22;  sth=21;  lenh=12;  tint=1; 
%
year='2018';  mon='06';  s_min='00';
infilenam='wrfout';  dom='01';    
%
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri]; outdir='/mnt/e/figures/expri191009';
indir='/mnt/HDD008/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%
titnam='moist DTE';   fignam=[expri1(8:end),'_moDTEarea_'];
%
cp=1004.9;
Tr=287;

mon_cenx=75; mon_ceny=100;
load('colormap/colormap_ncl.mat')
% col=colormap_ncl(20:6:end,:);
col=colormap_ncl(30:20:end,:);

%---
plotvar=size(lenh,1); ss_hr=cell(length(tint:tint:lenh),1); nti=0;
for ti=1:lenh 
  hr=sth+ti-1;
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
  if mod(ti,tint)==0 
   nti=nti+1;
   ss_hr{nti}=num2str(mod(hr+9,24),'%2.2d');
  end
  %------read netcdf data--------
  infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];

  dte=cal_DTE(infile1,infile2);
  dterep=repmat(dte,3,3,1);
  
%   narea=0; 
%   for plotrange=25:25:150      
%     narea=narea+1;
%     stgridx=300+mon_cenx-plotrange;    edgridx=300+mon_cenx+plotrange;
%     stgridy=300+mon_ceny-plotrange;    edgridy=300+mon_ceny+plotrange;  
%     meandte(ti,narea)=mean(mean(mean( dterep(stgridx:edgridx,stgridy:edgridy ,:) )));
%   end  
  
%   narea=0;  
%   plotrange=100;   interv=50;
%   for stx=1:interv:251
%     stgridx=300+stx;    edgridx=300+stx+plotrange;  
%     
%     for sty=1:interv:251
%       narea=narea+1;    
%       stgridy=300+sty;    
%       edgridy=300+sty+plotrange;  
%       meandte(ti,narea)=mean(mean(mean( dterep(stgridx:edgridx,stgridy:edgridy ,:) )));
%     end
%   end 
  
% 
meandte(ti,1) = mean(mean(mean( dterep( 1:150 , 51:150 ,:) )));
meandte(ti,2) = mean(mean(mean( dterep( 151:300 , 251:350 ,:) )));
% meandte(ti,3) = mean(mean(mean( dterep( 151:250 , 201:300 ,:) )));
% meandte(ti,4) = mean(mean(mean( dterep( 101:200 , 151:250 ,:) )));
% meandte(ti,5) = mean(mean(mean( dterep( 201:300 , 101:200 ,:) )));


end
%%
%---plot
hf=figure('position',[200 200 1000 600]);
plot(meandte,'linewidth',2)
% n=0;
% for i=[2 35 36]
%     n=n+1;
%   plot(meandte(:,i),'linewidth',2,'color',col(n,:)); hold on  
% end
% legend('2','35','36','box','off','location','bestout')
%
set(gca,'YScale','log'); 
set(gca,'XLim',[1 lenh],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Time (JST)');  ylabel('J Kg^-^1')
%---
tit=[expri1,'  ',titnam,'  (area mean)'];     
title(tit,'fontsize',18)
%--
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr'];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
