close all 
clear; ccc=':';
%---setting
expri='TWIN001B'; stday=21;  sth=16;  lenh=24;  tint=2;  bdy=0;
typst='mean'; %mean/max/min
%
year='2018';  mon='06';  s_min='00';
infilenam='wrfout';  dom='01';    
%
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri]; outdir='/mnt/e/figures/expri191009';
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%
titnam='2-m Temp.';   fignam=[expri,'_T2-t_'];

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
  infile = [indir,'/',infilenam,'_d01_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  t2 = ncread(infile,'T2');
  switch(typst)
  case('mean')
    plotvar(ti)=mean(mean(t2(bdy+1:end-bdy,bdy+1:end-bdy)));
  case('max')
    plotvar(ti)=max(max(t2(bdy+1:end-bdy,bdy+1:end-bdy)));
  case('min')
    plotvar(ti)=min(min(t2(bdy+1:end-bdy,bdy+1:end-bdy)));
  end   
end

%---plot
hf=figure('position',[200 200 1000 600]);
plot(plotvar,'linewidth',2.5)
%
set(gca,'XLim',[1 lenh],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Time (JST)');  ylabel('2-m Temperature (K)')
%---
tit=[expri,'  ',titnam,'  (domain ',typst,')'];     
title(tit,'fontsize',18)
%--
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
