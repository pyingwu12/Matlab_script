% 
clear; ccc=':';
% close all
%---
plotx=120; ploty=80;  % if plotx=ploty=0, plot domain mean
%
expri='TWIN017B'; s_date='22';  s_hr='23'; s_min='30';
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  

indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];
outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
fignam=[expri,'_skewTlogp_'];

Rcp=287.43/1005; 
%-------
infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];

qv = ncread(infile,'QVAPOR');  
theda = ncread(infile,'T');  theda=theda+300;
p = ncread(infile,'P');     pb = ncread(infile,'PB');  P=(p+pb)/100;
temp  = theda.*(1e3./P).^(-Rcp); %temperature (K)   

u.stag = ncread(infile,'U');  v.stag = ncread(infile,'V');  
u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;


if plotx==0 && ploty==0
  t_prof = squeeze(mean(mean(temp,1),2));
  p_prof = squeeze(mean(mean(P,1),2)); %pressure (hpa)
  qv_prof = squeeze(mean(mean(qv,1),2));
  u.prof = squeeze(mean(mean(u.unstag,1),2));
  v.prof = squeeze(mean(mean(v.unstag,1),2));
else
  t_prof = squeeze(temp(plotx,ploty,:));
  p_prof = squeeze(P(plotx,ploty,:)); %pressure (hpa)
  qv_prof = squeeze(qv(plotx,ploty,:));
  u.prof = squeeze(u.unstag(plotx,ploty,:));
  v.prof = squeeze(v.unstag(plotx,ploty,:));
end

TT = t_prof - 273; 
ev = qv_prof./(0.622+qv_prof) .* p_prof;  %partial pressure of water vapor
Td = -5417./(log(ev./6.11)-19.83) - 273;
P1=p_prof;  P2=p_prof; P3=p_prof;
WS = (u.prof.^2 + v.prof.^2).^0.5; 
WD = 270-acos(u.prof./WS)*180/pi;

%---plot skewT-logP---
hf=plot_skewtlogp_fun(P1,TT,P2,Td,P3,WS,WD);
tit=[expri,'  ',mon,s_date,' ',s_hr,s_min,'UTC  x=',num2str(plotx),', y=',num2str(ploty)];  
title(tit,'position',[22.5 -3.3],'fontsize',16)

 outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_x',num2str(plotx),'y',num2str(ploty)];
%  print(hf,'-dpng',[outfile,'.png'])    
%  system(['convert -trim ',outfile,'.png ',outfile,'.png']);

