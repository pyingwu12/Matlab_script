%---
% plot time series of hourly rainfall
%----
close all
clear;  ccc=':';
saveid=1; % save figure (1) or not (0)
%---setting
expri='TWIN018B';  stday=21;   sth=15;  lenh=71;  tint=5;  bdy=0;
minu=0:10:50;  
typst='max';  %mean/sum/max
%---
year='2018'; mon='06';   infilenam='wrfout';  dom='01';  
%---
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];  outdir=['/mnt/e/figures/expri_test/',expri];
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='Hourly rainfall time series';   fignam=[expri,'_accum-1h_Ts_'];

nminu=length(minu);  ntime=lenh*nminu;

%---
plotvar=size(lenh,1); ss_hr=cell(length(tint:tint:lenh),1); nti=0; ntii=0;
for ti=1:lenh
  if mod(ti,tint)==0 
    ntii=ntii+1;    ss_hr{ntii}=num2str(mod(sth+ti-1+9,24),'%2.2d');
  end  
  for tmi=minu
    nti=nti+1;    rc=cell(1,2); rsh=cell(1,2);  rnc=cell(1,2);   exi=0;
    s_min=num2str(tmi,'%2.2d');
    for j=1:2
      hr=(j-1)*1+ti+sth-1;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
      %------read netcdf data--------
      infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      if exist(indir,'dir') && ~exist(infile,'file')       
        exi=1;  break;
      else   
      rc{j} = ncread(infile,'RAINC');
      rsh{j} = ncread(infile,'RAINSH');
      rnc{j} = ncread(infile,'RAINNC');
      end
    end %j=1:2
    if exi~=0
      plotvar(nti)=NaN; 
    else           

    rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
    switch(typst)
    case('mean')
      plotvar(nti)=mean(mean(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('sum')
      plotvar(nti)=sum(sum(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    case('max')
      plotvar(nti)=max(max(rain(bdy+1:end-bdy,bdy+1:end-bdy)));
    end  
    
    end
  end
end
%
%---plot
hf=figure('position',[200 45 1000 600]);
plot(1.5:ntime+0.5,plotvar,'LineWidth',2.5); 
%
set(gca,'XLim',[1 ntime+1],'XTick',(tint-1)*nminu+1 : tint*nminu : ntime ,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Local time');  ylabel('Rainfall (mm)')
%---
tit={[expri,'  (domain ',typst,')'];titnam};     
title(tit,'fontsize',18)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_',typst];

if saveid~=0
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
