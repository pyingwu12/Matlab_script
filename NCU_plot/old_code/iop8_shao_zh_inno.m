%-----------------------------------
% Plot Zh improvement after DA
%-----------------------------------

clear

expri='2HR'; 
%hm=['16:00';'16:15';'16:30';'16:45';'17:00';'17:15';'17:30';'17:45';'18:00'];
hm=['10:00';'10:15';'10:30';'10:45';'11:00';'11:15';'11:30';'11:45';'12:00'];  
%hm=['10:00';'10:15'];  

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='14';    % time setting
obsdir='/SAS004/pwin/data/obs_IOP8';
indir=['/work/pwin/data/IOP8_wrf2obs_',expri];  outdir=['/work/pwin/plot_cal/IOP8_shao/',expri,'/'];
%---set---
vari='Zh';   filenam=[expri,'_zh-inno-t_'];  
num=size(hm,1);
%
mem=40;  obserr=5;

for ti=1:num;
  time=hm(ti,:);
%---read obs data---
  infile=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile);   zh.obs =A(:,9);   

  for tyi=1:2     
    if tyi==1; type='fcst'; elseif tyi==2; type='anal'; end
    ni=2*(ti-1)+tyi;     
%----read ensemble data--------  
    for mi=1:mem
      if mi<=9; nen=['0',num2str(mi)]; else nen=num2str(mi); end
      infile=[indir,'/',type,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00_',nen];  
      B=importdata(infile);   zh_ens(:,mi) =B(:,9);     
    end
    zh_ens(zh_ens==-9999 )=NaN;
    %---ensemble mean---
    zh.mean=mean(zh_ens,2);    
    %---innovation---    
    inno.all=zh.obs-zh.mean;    inno.all=inno.all(zh.obs~=-9999 & isnan(zh.mean)~=1);
    inno.mean(ni)=mean(inno.all);  
    inno.rmsi(ni)=( mean( (inno.all-inno.mean(ti)).^2 ) )^0.5;
    %---ensemble spread---
    zh.perb=zeros(length(zh.mean),1);
    for i=1:mem
     zh.perb= zh.perb + ( (zh_ens(:,i)-zh.mean).^2 )./mem ;      
    end  
    zh.perb=zh.perb(isnan(zh.mean)~=1);
    sprd.en(ni) = sqrt (mean(zh.perb));   
    %    
  end  % fcst / anal  
  clear zh_ens
end %time
% 
sprd.idel=( abs(inno.rmsi.^2 - obserr^2) ).^0.5; 

x(1:2:num*2-1)=1:num;  x(2:2:num*2)=1:num;
%---plot
figure('position',[100 500 700 500])
plot(x,inno.mean,'color',[0 0 0],'LineWidth',2.5); hold on
plot(x,inno.rmsi,'color',[0 0 1],'LineWidth',2.5); 
plot(x,sprd.en,'color',[1 0 0],'LineWidth',2.5); 
plot(x,sprd.idel,'color',[0 0 0],'LineWidth',2.5,'LineStyle','-.'); 
%
set(gca,'XLim',[0 num+1],'YLim',[-13 23],'XTick',1:num,'XTickLabel',hm,'fontsize',14,'LineWidth',1)
xlabel('Time');   ylabel('dBZ');
legh=legend('mean innovation','RMS innovation','enemble spread','ideal ensemble spread');
set(legh,'fontsize',12)
% 
 tit=[expri,'  ',vari];
 title(tit,'fontsize',15)
 outfile=[outdir,filenam,'.png'];
 print('-dpng',outfile,'-r400')     
   
