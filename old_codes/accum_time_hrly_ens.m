close all
clear;  ccc=':';
%---setting
expri='ens08';   stday=21;  sth=15;  lenh=24;  member=1:10;  tint=2;  bdy=0;
typst='mean'; %mean/max/min
%---
year='2018'; mon='06';  s_min='00';  
dirmem='pert'; infilenam='wrfout';  dom='01';  
%---
indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri]; 
outdir=['/mnt/e/figures/ens200323/',expri];
%---
titnam='Hourly rainfall time series';   fignam=[expri,'_accum-hrly_'];

%---
plotvar=size(lenh,length(member)); ss_hr=cell(length(tint:tint:lenh),1); nti=0;
nmi=0;
for mi=member
  nmi=nmi+1;
  nti=0; nen=num2str(mi,'%.2d');
  for ti=1:lenh
    rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2); 
    if mod(ti,tint)==0 && nmi==1
      nti=nti+1;
      ss_hr{nti}=num2str(mod(sth+ti-1+9,24),'%2.2d');
    end  
    for j=1:2
      hr=(j-1)*1+ti+sth-1;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
      rc{j} = ncread(infile,'RAINC');
      rsh{j} = ncread(infile,'RAINSH');
      rnc{j} = ncread(infile,'RAINNC');
    end %j=1:2  
    rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
    switch(typst)
    case('mean')
      plotvar(ti,mi)=mean(mean(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('sum')
      plotvar(ti,mi)=sum(sum(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
      plotvar(ti,mi)=max(max(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    end %switch
  end %ti
end
%%
%---plot
hf=figure('position',[100 45 1000 600]);
plot(1.5:lenh+0.5,plotvar,'linewidth',2,'color',[0.7 0.7 0.7])
hold on
plot(1.5:lenh+0.5,mean(plotvar,2),'linewidth',2,'color',[0.7 0.3 0.3])
%
set(gca,'XLim',[1 lenh+1],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Time (JST)');  ylabel('Rainfall (mm)')
%---
tit={[expri,'  (domain ',typst,')'];titnam};     
title(tit,'fontsize',18)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_min,'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
