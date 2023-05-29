% close all; 
%clear; ccc=':';

expri={'TWIN001';...
       'TWIN017';'TWIN013';'TWIN022';
       'TWIN025';'TWIN019';'TWIN024';
       'TWIN021';'TWIN003';'TWIN020';
       'TWIN023';'TWIN016';'TWIN018'
        };
    
cexp=[ 50 50 50;
       75 190 237 ; 0  114  189;  5 55 160 ; 
       245 153 202; 200 50 170; 140 30 135 
       235 175 32 ;  220 85 25;  160 20 45;  
       143 204 128;  97 153  48; 35 120 35 ]/255;
   
expnam={'FLAT';
        'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'TOPO';'V20H10';
        'V05H20';'V10H20';'V20H20'};


%%
%---setting 
stday=22;   hrs=[22 23 24 25 26];  minu=[00 10 20 30 40 50];  
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';

nexp=size(expri,1); 

%---
for ei=1:nexp  
  nti=0;  
  for ti=hrs 
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for mi=minu
      nti=nti+1;      s_min=num2str(mi,'%2.2d');     
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
     qr = ncread(infile2,'QRAIN');  qr=double(qr);   
     qs = ncread(infile2,'QSNOW');  qs=double(qs);    
     qg = ncread(infile2,'QGRAUP'); qg=double(qg);
     qi = ncread(infile2,'QICE');   qi=double(qi);
     qc = ncread(infile2,'QCLOUD'); qc=double(qc);
     hyd2D=sum(qr+qs+qg+qi+qc,3);
     cldg_num(ei,nti)=length(find(hyd2D+1>1.005));    
    end % mi
    disp([s_hr,s_min,' done'])
  end %ti
  disp([expri{ei},' done'])
end %ei
save('cldg_num_all.mat','cldg_num')
%%
%---set x tick---
nti=0; tint=1;
 for ti=hrs(tint:tint:end)
  nti=nti+1;  
  ss_hr{nti}=[num2str(mod(ti+9,24),'%2.2d'),'00'];
end
%%
close all
hf=figure('position',[100 45 1000 600]);
for i=1:nexp
plot(cldg_num(i,:),'color',cexp(i,:),'LineWidth',2); hold on
end
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'location','bestoutside','FontName','Consolas');
%
set(gca,'XTick',tint:length(minu):size(cldg_num,2),'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
set(gca,'Yscale','log')
xlabel('Local time');  ylabel('number of cloud grids')
tit='Number of cloud grids time series';   
title(tit,'fontsize',18)
%
outfile='/mnt/e/figures/expri_twin/cld_grid_num_time';
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
