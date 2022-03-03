% close all 
clear; ccc=':';
%---setting
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];   expri2=[expri,'B'];  
stday=22;  sth=22;  lenh=24;  tint=2; 
%
year='2018';  mon='06';  s_min='00';
infilenam='wrfout';  dom='01';    
%
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri]; outdir='/mnt/e/figures/expri191009';
indir='/mnt/HDD008/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%
titnam='moist DTE';   fignam=[expri1(8:end),'_moDTEarea_'];
%
cp=1004.9;
Tr=270;
Lv=(2.4418+2.43)/2 * 10^6 ;

%---
plotvar=size(lenh,1); ss_hr=cell(length(tint:tint:lenh),1); nti=0;
for ti=1:lenh    
  hr=sth+ti-1;
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
  if mod(ti,tint)==0 
   nti=nti+1;
   ss_hr{nti}=num2str(mod(hr+9,24),'%2.2d');
  end
  %------read netcdf data--------
  infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');
    u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    t.f1=ncread(infile1,'T')+300; 
    qv = double( ncread(infile1,'QVAPOR') ); 
    s.f1 = qv./(qv+1); % specific humidity
  infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');
    u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    t.f2=ncread(infile2,'T')+300; 
    qv = double( ncread(infile2,'QVAPOR') ); 
    s.f2 = qv./(qv+1); % specific humidity
  %---
    u.diff=u.f1-u.f2; 
    v.diff=v.f1-v.f2;
    t.diff=t.f1-t.f2;
    s.diff=s.f1-s.f2;
    
  modte=1/2*(u.diff.^2+v.diff.^2) + cp/Tr*t.diff.^2 + Lv*s.diff.^2; 
%   plotvar(ti,1)= mean(mean(mean(modte))); 
  plotvar(ti,1)= mean(mean(mean( 1/2*(u.diff.^2+v.diff.^2) )));
  plotvar(ti,2)= mean(mean(mean( cp/Tr*t.diff.^2 )));
  plotvar(ti,3)= mean(mean(mean( Lv*s.diff.^2 )));
  
end
%%
%---plot
hf=figure('position',[200 200 1000 600]);
area(plotvar,'linestyle','none')
hold on
plot(plotvar(:,1),'linewidth',1.5,'color',[0 0 0])
plot(plotvar(:,1)+plotvar(:,2),'linewidth',1.5,'color',[0 0 0])
plot(sum(plotvar,2),'linewidth',1.5,'color',[0 0 0])
% plot(plotvar,'linewidth',2.5)
legend('KE','Thermal heat','Laten heat','box','off')
%
set(gca,'XLim',[1 lenh],'XTick',tint:tint:lenh,'XTickLabel',ss_hr,'fontsize',16,'linewidth',1.2)
xlabel('Time (JST)');  ylabel('J Kg^-^1')
%---
tit=[expri1,'  ',titnam,'  (domain mean)'];     
title(tit,'fontsize',18)
%--
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
