close all
clear
%---setting
expri='ens03';  member=1:10;  typst='mean';  %mean/sum/max
year='2018'; mon='06'; date=21; minu='00';
sth=21;   lenh=23;   pridh=sth:sth+lenh-1;
dirmem='pert'; infilenam='wrfout';  dom='01';  


indir=['/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/HDD001/Figures/ens200323/',expri,'/'];
titnam='Hourly Rainfall';   fignam=[expri,'_hourlyrain-en_'];

%---
acci=size(length(pridh),length(member)); 
for mi=member
nti=0;  nen=num2str(mi,'%.2d');
for ti=pridh
   nti=nti+1;
   for j=1:2
      hr=(j-1)+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile = [indir,'/wrfout_d01_',year,'-',mon,'-',s_date,'_',s_hr,'%3A',minu,'%3A00'];
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
      rc{j} = ncread(infile,'RAINC');
      rsh{j} = ncread(infile,'RAINSH');
      rnc{j} = ncread(infile,'RAINNC');
   end %j=1:2
   rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
   switch(typst)
    case('mean')
     acci(nti,mi)=mean(mean(rain));
    case('sum')
     acci(nti,mi)=sum(sum(rain));
    case('max')
     acci(nti,mi)=max(max(rain));
   end   
end %ti
end
%
%---set x tick---
nti=0;
for ti=sth:sth+lenh
  jti=ti+9;  
  hrday=fix(jti/24);  hr=jti-24*hrday;
  nti=nti+1;  ss_hr{nti}=num2str(hr,'%2.2d');
end

%---plot
hf=figure('position',[-1100 200 900 600]);
%plot(pridh+0.5,acci,'linewidth',2,'color',[0.55 0.55 0.55])
plot(pridh+0.5,acci,'linewidth',2)
%
set(gca,'XLim',[sth sth+lenh],'XTick',sth:sth+lenh,'XTickLabel',ss_hr,...
    'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',16);  ylabel('Rainfall (mm)','fontsize',16)
%---
tit=[expri,'  ',titnam,'  (',upper(typst),')  ',ss_hr{1},minu,'-',ss_hr{end},minu,'UTC'];     
title(tit,'fontsize',19)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,mon,num2str(date),'_',s_sth,minu,'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 


