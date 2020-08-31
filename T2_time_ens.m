close all
clear; ccc=':';
%---setting
expri='ens09';   stday=21;  sth=16;  lenh=24;  member=1:10;  tint=2;  bdy=0;
typst='mean'; %mean/max/min
%---
year='2018';  mon='06'; s_min='00';
dirmem='pert'; infilenam='wrfout';  dom='01';  
%
indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri]; 
outdir=['/mnt/e/figures/ens200323/',expri,'/'];
%
titnam='2-m Temp.';    fignam=[expri,'_T2-t_'];
%
%---
plotvar=zeros(lenh,length(member)); ss_hr=cell(length(tint:tint:lenh),1); nti=0;
for ti=1:lenh
  hr=sth+ti-1;
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
  if mod(ti,tint)==0 
   nti=nti+1;
   ss_hr{nti}=num2str(mod(hr+9,24),'%2.2d');
  end  
  for mi=member    
    nen=num2str(mi,'%.2d');
    %------read netcdf data--------
    infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
    t2 = ncread(infile,'T2');
    switch(typst)
    case('mean')
      plotvar(ti,mi)=mean(mean(t2));
    case('max')
      plotvar(ti,mi)=max(max(t2));
    case('min')
     plotvar(ti,mi)=min(min(t2));
    end  
    
  end %member
end %ti

%%
%---plot
hf=figure('position',[200 200 1000 600]);
plot(plotvar,'linewidth',2.5,'color',[0.7 0.7 0.7])
hold on
plot(mean(plotvar,2),'linewidth',2.5,'color',[0.7 0.3 0.3])
%
set(gca,'XLim',[1 lenh],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Time (JST)');  ylabel('2-m Temperature (K)')
%---
tit=[expri,'  ',titnam,'  (domain ',typst,')'];     
title(tit,'fontsize',18)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);