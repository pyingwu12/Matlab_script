%close all
clear;  ccc=':';
%---setting
%!!!!!!!!!!!!!!!!!
bdy=0;   %!!!!!!!!
expri='test56';  typst='max';  %mean/sum/max
year='2018'; mon='06'; date=21; minu='00';
sth=15;   lenh=48;   pridh=sth:sth+lenh-1;  tint=3;
infilenam='wrfout';  dom='01';  

indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];
outdir=['/mnt/e/figures/expri191009/',expri,'/'];
titnam='Hourly Rainfall';   fignam=[expri,'_hrlyrain_d',dom,'_'];

%---
nti=0;  acci=size(length(pridh),1); 
for ti=pridh
   nti=nti+1;
   rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2); 
   exi=0;
   for j=1:2
      hr=(j-1)+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
      rc{j} = ncread(infile,'RAINC');
      rsh{j} = ncread(infile,'RAINSH');
      rnc{j} = ncread(infile,'RAINNC');
   end %j=1:2
   rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
   switch(typst)
    case('mean')
     acci(nti)=mean(mean(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('sum')
     acci(nti)=sum(sum(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
     acci(nti)=max(max(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
   end  
end

%
%---set x tick---
xi=(1:lenh); 

ss_hr=cell(length(sth:tint:sth+lenh),1);
nti=0;  
for ti=sth:tint:sth+lenh
  jti=ti+9;  
  hrday=fix(jti/24);  hr=jti-24*hrday;
  nti=nti+1;  ss_hr{nti}=num2str(hr,'%2.2d');
end

%
%---plot
hf=figure('position',[100 45 985 590]);
plot(xi+0.5,acci,'LineWidth',2.2); hold on
%
set(gca,'XLim',[1 lenh+1],'XTick',xi(1:tint:end),'XTickLabel',ss_hr,...
    'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',18);  ylabel('Rainfall (mm)','fontsize',18)
%---
tit=[expri,'  ',titnam,'  (',upper(typst),')  '];     
title(tit,'fontsize',19)
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,mon,num2str(date),'_',s_sth,minu,'_',s_lenh,'hr_',typst];
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
