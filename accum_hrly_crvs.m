close all
clear;  ccc=':';

expri={'test61';'test64';'test55';'test50'};   exptext='ndown';  
expnam={'noFB_20';'FB_20';'FB_04';'CTRL'};
dom={'01';'01';'01';'01'};
lexp={'-';'-';'-';'-'};  
cexp=[0  0.447  0.741; 0.85,0.325,0.098; 0.466,0.674,0.188; 0.3 0.3 0.3];

% expri={'test38';'test40';'test44';'test48'};   exptext='notopo48';  
% dom={'01';'01';'01';'01'};
% expnam={'CTRL';'03st';'per01';'per01_03st'};
% lexp={'-';'-';'-';'-'};  
% cexp=[0  0.447  0.741; 0.3 0.745 0.93; 0.85,0.325,0.098; 0.929,0.694,0.125]; 

% expri={'test38';'test43';'test45'};   exptext='topo';  
% dom={'01';'01';'01'};
% expnam={'flat';'L-topo';'S-topo'};
% lexp={'-';'-';'-';'-'};  
% cexp=[0  0.447  0.741; 0.466,0.674,0.188; 0.22,0.42,0.08]; 

% expri={'test51';'test51';'test56';'test56';'test50'};   exptext='Nesting';  
% expnam={'FBd01';'FBd02';'noFBd01';'noFBd02';'CTRL'};
% dom={'01';'02';'01';'02';'01'};
% lexp={'-';'-';'-';'-';'-'};  
% cexp=[0,0.447,0.741; 0.3,0.745,0.933; 0.85,0.325,0.098; 0.929,0.694,0.125; 0.3 0.35 0.3]; 

% expri={'test54';'test55';'test58';'test53';'test57';'test59';'test61';'test62'};   exptext='ndown';  
% expnam={'test47_4';'test51_4';'test47&51_4';'test47_20';'test56_20';'test56_topo';'test56_18s';'test60'};
% dom={'01';'01';'01';'01';'01';'01';'01';'01'};
% lexp={'-';'-';'-';'-';'-';'-';'-';'-'};  
% cexp=[0 0.45 0.75; 0.46 0.67 0.18; 0.3 0.745 0.745; 0.3 0.745 0.933;...
%     0.85 0.33 0.098; 0.93 0.69 0.125; 0.6 0.1 0.2; 0.55,0.184,0.61]; 

%dark blue: 0,0.447,0.741
%light blue: 0.3,0.745,0.933
%yellow: 0.929,0.694,0.125
%orange: 0.85,0.325,0.098
%purple: 0.494,0.184,0.556
%green: 0.466,0.674,0.188
%dark red: [0.6350 0.0780 0.1840]

%---setting
typst='mean';%mean/sum/max
time='2018062100';
sth=18;  lenh=24;  tint=2;
nexp=size(expri,1);   
%
outdir='/mnt/e/figures/expri191009/';
titnam='Hourly Rainfall';   fignam=['hourlyrain_',exptext,'_'];

acci=zeros(nexp,lenh);
for i=1:nexp
    %if i==5; time='2018081800'; else; time='2018062100'; end
   acci(i,:)=cal_hrly_accum(expri{i},time,sth,lenh,dom{i},typst,ccc);
   disp([expri{i},' done'])
end


%%
%---set x tick---
xi=(1:lenh);
nti=0;
for ti=sth:tint:sth+lenh
  jti=ti+9;  
  hrday=fix(jti/24);  hr=jti-24*hrday;
  nti=nti+1;  ss_hr{nti}=num2str(hr,'%2.2d');
end

%%
%---plot
hf=figure('position',[100 10 1000 600]);
for i=1:nexp
plot(xi+0.5,acci(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.2); hold on
end
%
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',16);
%
set(gca,'XLim',[1 lenh+1],'XTick',xi(1:tint:end),'XTickLabel',ss_hr,...
    'fontsize',15,'linewidth',1.3)
xlabel('Time (JST)','fontsize',18);  ylabel('Rainfall (mm)','fontsize',18)
%---

tit=[titnam,'  (',upper(typst),')  '];     
title(tit,'fontsize',19)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,fignam,time(5:6),time(7:8),'_',s_sth,time(9:10),'_',s_lenh,'hr_',typst];

 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
