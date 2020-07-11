%close all 
clear; 
ccc=':';
%---setting
expri='test91';  typst='mean'; %mean/max/min
year='2018'; mon='06';  date=21;  minu='00';
sth=15;  lenh=48;  pridh=sth:sth+lenh-1;  tint=3;
infilenam='wrfout';  dom='01';    

%indir=['E:/wrfout/expri191009/',expri];
%outdir='E:/figures/expri191009/';
indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];
outdir=['/mnt/e/figures/expri191009/',expri,'/'];
titnam='Q2';   fignam=[expri,'_Q2-curve_'];

%---
nti=0;  plotvar=size(length(pridh),1); 
for ti=pridh
   nti=nti+1;
   hr=ti;
   hrday=fix(hr/24);  hr=hr-24*hrday;
   s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
   %------read netcdf data--------
   infile = [indir,'/wrfout_d01_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
   q2 = ncread(infile,'Q2'); q2=q2*1e3;
   switch(typst)
    case('mean')
     plotvar(nti)=mean(mean(q2));
    case('max')
     plotvar(nti)=max(max(q2));
    case('min')
     plotvar(nti)=min(min(q2));
   end   
end

%---set x tick---
nti=0; 
for ti=sth:tint:sth+lenh
  jti=ti+9;  
  hrday=fix(jti/24);  hr=jti-24*hrday;
  nti=nti+1;  ss_hr{nti}=num2str(hr,'%2.2d');
end


%---plot
hf=figure('position',[200 200 1000 600]);
plot(pridh,plotvar,'linewidth',2)
%
set(gca,'XLim',[sth pridh(end)],'XTick',sth:tint:sth+lenh,'XTickLabel',ss_hr,...
    'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',18);  ylabel('QVAPOR (g/Kg)','fontsize',18)
%---
tit=[expri,'  ',titnam,'  (',upper(typst),')  ',ss_hr{1},minu,'-',ss_hr{end},minu,'JST'];     
title(tit,'fontsize',19)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,mon,num2str(date),'_',s_sth,minu,'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
