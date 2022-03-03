clear
%hm=['11:00';'11:15';'11:30';'11:45';'12:00'];  
expri='vrzhall3'; 
hm=['16:00';'16:15';'16:30';'16:45';'17:00';'17:15';'17:30';'17:45';'18:00'];

%---setting---
varinam='Zh';   filenam=[expri,'_zh-inno-t_'];  
num=size(hm,1);
indir=['/work/pwin/data/morakot_wrf2obs_',expri];
%outdir=['/SAS011/pwin/201work/plot_cal/IOP8/',expri,'/'];
outdir='/SAS011/pwin/201work/plot_cal/morakot/shaosetting/';

%
dom='02';  year='2009'; mon='08'; date='08';  mem=40;  obserr=5;

for ti=1:num;
  time=hm(ti,:);
%---read obs data---
  infile=['/SAS004/pwin/data/obs_morakot/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile);   zh.obs =A(:,9);   
  for tyi=1:2   % fcst / anal  
    if tyi==1; type='fcst'; elseif tyi==2; type='anal'; end
    ni=2*(ti-1)+tyi;     
%----read ensemble data--------  
%     for mi=1:mem
%       if mi<=9; nen=['0',num2str(mi)]; else nen=num2str(mi); end
%       infile=[indir,'/',type,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00_',nen];  
%       B=importdata(infile);   zh_ens(:,mi) =B(:,9);     
%     end
%     zh_ens(zh_ens==-9999 )=NaN;
    %---ensemble mean---
    infile=[indir,'/',type,'mean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00']; 
    B=importdata(infile);   zh.mean=B(:,9);  zh.mean(zh.mean==-9999 | zh.mean<=0)=NaN;
    %zh.mean=mean(zh_ens,2);    
    %---innovation---    
    inno.all=zh.obs-zh.mean;    inno.all=inno.all(zh.obs~=-9999 & isnan(zh.mean)~=1);
    inno.mean(ni)=mean(inno.all);  
    inno.rmsi(ni)=( mean( (inno.all-inno.mean(ti)).^2 ) )^0.5;
    %---ensemble spread---
%     zh.perb=zeros(length(zh.mean),1);
%     for i=1:mem
%      zh.perb= zh.perb + ( (zh_ens(:,i)-zh.mean).^2 )./mem ;      
%     end  
%     zh.perb=zh.perb(isnan(zh.mean)~=1);
%     sprd.en(ni) = sqrt (mean(zh.perb));   
    %    
  end  % fcst / anal  
%   clear zh_ens
end %time
% 
% sprd.idel=( abs(inno.rmsi.^2 - obserr^2) ).^0.5; 

x(1:2:num*2-1)=1:num;  x(2:2:num*2)=1:num;

%---plot
figure('position',[100 100 700 500])
plot(x,inno.mean,'color',[0 0 0],'LineWidth',2.5); hold on
plot(x,inno.rmsi,'color',[0 0 1],'LineWidth',2.5); 
% plot(x,sprd.en,'color',[1 0 0],'LineWidth',2.5); 
% plot(x,sprd.idel,'color',[0 0 0],'LineWidth',2.5,'LineStyle','-.'); 
%
set(gca,'XLim',[0 num+1],'YLim',[-5 15],'XTick',1:num,'XTickLabel',hm,'fontsize',14,'LineWidth',1)
xlabel('Time');   ylabel('dBZ');
%legh=legend('mean innovation','RMS innovation','enemble spread','ideal ensemble spread');
legh=legend('mean innovation','RMS innovation');
set(legh,'fontsize',12)
% 
 tit=[expri,'  ',varinam];
 title(tit,'fontsize',15)
 outfile=[outdir,filenam];
  set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
  system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
  system(['rm ',[outfile,'.pdf']]);  
   
