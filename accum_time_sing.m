close all
clear;  ccc=':';
%---setting
expri='TWIN004B';  stday=22;  sthrs=0:2:36;  acch=3;  bdy=0;  tint=2;
typst='mean';  %mean/sum/max
%---
year='2018'; mon='06';  s_min='00';  
infilenam='wrfout';  dom='01';  
%---
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];  outdir=['/mnt/e/figures/expri_test/',expri,'/'];
%  indir=['/mnt/HDD003/pwin/Experiments/expri_single/',expri]; outdir=['/mnt/e/figures/expri_single/',expri,'/'];
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7),'/'];
%---
titnam=[num2str(acch),'-h Accumulated Rainfall time series'];   fignam=[expri,'_accum_'];

%---
% ss_hr=cell(length(sthrs:tint:sthrs+lenh),1);
nti=0;  nnti=0; acci=size(length(sthrs),1); 
for ti=sthrs
   nti=nti+1;
   if mod(nti-1,tint)==0
       nnti=nnti+1;
       ss_hr{nnti}=num2str(mod(ti+9,24),'%2.2d');
   end
   rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2); 
   exi=0;
   for j=1:2
      hr=(j-1)*acch+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
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
%---plot
hf=figure('position',[100 50 985 590]);
plot(acci,'LineWidth',2.5); hold on
%
set(gca,'XLim',[1 length(sthrs)],'XTick',1:tint:length(sthrs),'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
%set(gca,'YLim',[0 0.6])
xlabel('Time (JST)');  ylabel('Rainfall (mm)')
%---
tit={[expri,'  (domain ',upper(typst),')'];titnam};     
title(tit,'fontsize',18)

s_sth=num2str(sthrs(1),'%2.2d');
outfile=[outdir,fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',num2str(acch),'h_',num2str(length(sthrs)),'step_',typst];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
