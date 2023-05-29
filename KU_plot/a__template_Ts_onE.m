close all;  clear;   ccc=':';

%---setting
expri='';  
stday=22;   sth=21;   lenh=16;  minu=[00 20 40];   tint=2;
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='';   fignam=[expri,''];

nminu=length(minu);  ntime=lenh*nminu;
%---
nti=0; ntii=0;
plotvar=zeros(1,ntime);  ss_hr=cell(length(tint:tint:lenh),1);
for ti=1:lenh 
  hr=sth+ti-1;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  if mod(ti,tint)==0 
    ntii=ntii+1;    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
  end   
  for tmi=minu 
    nti=nti+1;     s_min=num2str(tmi,'%2.2d');       
    %--- filename---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    xxx = ncread(infile,'');  
    plotvar(nti)=mean(mean(xxx));    
  end
  if mod(ti,5)==0; disp([s_hr,' done']); end
end
 %%  
%---plot---       
hf=figure('position',[200 45 1000 600]);
plot(plotvar,'LineWidth',2.5); 
%
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr,'Linewidth',1.2,'fontsize',16)
xlabel('Local time'); ylabel('')  
%---
tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
