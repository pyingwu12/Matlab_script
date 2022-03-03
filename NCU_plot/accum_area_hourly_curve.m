clear
% !!!! notice: remember to check the setting in function <a_accum_area_mean.m>

outdir='/SAS011/pwin/201work/plot_cal/largens/';
year='2008';  mon='06';  date=15;   s_datexp='16'; 

%exp={'obs';'e01';'e02';'e04';'e07';'e08';'e09';'e11';'e10'};   exptext='_all';  
%lexp={'-';'-';'--';'-';'--';'-';'--';'-';'--'};  
%cexp=[0.1 0.1 0.1; 0.75 0.1 0.2; 1 0.6 0.2; 0.1 0.6 0.1; 0.3 0.85 0.4; 0.1 0.2 0.8; 0.3 0.7 0.9; 0.5 0.5 0.6; 0.7 0.7 0.8]; 
%exp={'obs';'shao';'sz'};   exptext='_dom';  lexp={'-';'-';'-'};
%cexp=[0.2 0.2 0.2; 0 0 1; 1 0 0];
exp={'obs'};   exptext='_obs';  lexp={'-'};
cexp=[0.2 0.2 0.2];
nexp=size(exp,1);   
%---------------------
sth=20:37;    araid=5;  
%sth=12:23;   araid=3;
%sth=2:13;   araid=5;   %nt=length(sth);  
%
mrain=zeros(nexp,length(sth));
for i=1:nexp
   mrain(i,:)=accum_area_mean(year,mon,date,s_datexp,sth,exp{i},araid);
end

%---set x tick---
nti=0;
for ti=[sth sth(end)+1];
  hrday=fix(ti/24);  hr=ti-24*hrday;  
  nti=nti+1;  s_hr{nti}=num2str(hr,'%2.2d');   
end
%---plot--------------- 
figure('position',[100 100 880 490]) 
for i=1:nexp
plot(sth+0.5,mrain(i,:),'color',cexp(i,:),'Linestyle',lexp{i},'LineWidth',2.8); hold on
end
legh=legend(exp,'Location','BestOutside');  %set(legh,'LineStyle','--'); %set(legh,'EdgeColor','w')
%
%set(gca,'YLim',[2 18])  %set(gca,'YLim',[4 13]) %set(gca,'YLim',[0 30])
set(gca,'XLim',[sth(1) sth(end)+1],'XTick',[sth sth(end)+1],'XTickLabel',s_hr,'fontsize',13,'LineWidth',1)
xlabel('Time (UTC)','fontsize',14);   ylabel('Mean precipitation (mm)','fontsize',14);
%
title([year,mon,num2str(date,'%.2d'),'  ',s_hr{1},'z-',s_hr{end},...
       'z  Hourly mean precipitation','  (area',num2str(araid),')'],'fontsize',15)
outfile=[outdir,'hourlyrain_',s_hr{1},s_hr{end},exptext,'_area',num2str(araid)];
%
set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
system(['rm ',[outfile,'.pdf']]);
