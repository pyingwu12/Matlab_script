close all
clear
%---setting
%!!!!!!!!!!!!!!!!!
bdy=0;   %!!!!!!!!
expri='ens07';  member=1:10;  typst='mean';  %mean/sum/max
year='2018'; mon='06'; date=21; minu='00';
sth=15;   lenh=48;   pridh=sth:sth+lenh-1; tint=3;
dirmem='pert'; infilenam='wrfout';  dom='01';  


indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
%outdir=['/HDD001/Figures/ens200323/',expri];
outdir='/mnt/e/figures/ens200323';
titnam='Hourly Rainfall';   fignam=[expri,'_hlyrain-en_'];

%---
%acci=zeros(length(pridh),length(member)+1); 
acci=zeros(length(pridh),length(member));
nmi=0;
for mi=member
%for mi=[0 member]
nmi=nmi+1;
nti=0; nen=num2str(mi,'%.2d');
for ti=pridh
   nti=nti+1;
   for j=1:2
      hr=(j-1)+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      %if mi==0
      % infile=[indir,'/mean','/wrfmean_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
      %else
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
      %end
      rc{j} = ncread(infile,'RAINC');
      rsh{j} = ncread(infile,'RAINSH');
      rnc{j} = ncread(infile,'RAINNC');
   end %j=1:2
   rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
   rain(rain+1<1)=0;
   switch(typst)
    case('mean')
     %acci(nti,nmi)=mean(mean(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
     acci(nti,nmi)=mean(mean(rain));
    case('sum')
     acci(nti,nmi)=sum(sum(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
     acci(nti,nmi)=max(max(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
   end   
end %ti
end

%
%---set x tick---
nti=0; 
for ti=sth:tint:sth+lenh
  jti=ti+9;  nti=nti+1; 
  ss_hr{nti}=num2str(mod(jti,24),'%2.2d');
end
%%
%---plot
hf=figure('position',[100 10 1000 600]);
plot(pridh+0.5,acci,'linewidth',2,'color',[0.7 0.7 0.7])
hold on
plot(pridh+0.5,mean(acci,2),'linewidth',2,'color',[0.7 0.3 0.3])
%
set(gca,'XLim',[sth sth+lenh],'XTick',sth:tint:sth+lenh,'XTickLabel',ss_hr,...
    'fontsize',15,'linewidth',1.3)
set(gca,'YLim',[0 1.4])
xlabel('Time (JST)','fontsize',16);  ylabel('Rainfall (mm)','fontsize',16)
%---
tit=[expri,'  ',titnam,'  (',upper(typst),')  ',ss_hr{1},minu,'-',ss_hr{end},minu,' JST'];     
title(tit,'fontsize',19)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(date),'_',s_sth,minu,'_',s_lenh,'hr_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

