clear
hm=['11:00';'11:15';'11:30';'11:45';'12:00'];  
expri='EC'; 

%---setting---
vari='Vr';   filenam=[expri,'_vr-inno-t_'];  
num=size(hm,1);
indir=['/work/pwin/data/IOP8_wrf2obs_',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
%
dom='02';  year='2008'; mon='06'; date='14';  mem=40;  obserr=3;

for ti=1:num;
  time=hm(ti,:);
%---read obs data---
  %infile1=['/SAS004/pwin/data/obs_/obs_d03_2009-08-08_',time,':00'];
  infile=['/SAS004/pwin/data/obs_IOP8/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile);   vr.obs =A(:,8);   

  for tyi=1:2     
    if tyi==1; type='fcst'; elseif tyi==2; type='anal'; end
    ni=2*(ti-1)+tyi;     
%----read ensemble data--------  
    for mi=1:mem
      if mi<=9; nen=['0',num2str(mi)]; else nen=num2str(mi); end
      infile=[indir,'/',type,'_d',dom,'_',year,'-',mon,'-',date,'_',time,':00_',nen];  
      B=importdata(infile);   vr_ens(:,mi) =B(:,8);     
    end
    vr_ens(vr_ens==-9999)=NaN;
    %---ensemble mean---
    vr.mean=mean(vr_ens,2);    
    %---innovation---    
    inno.all=vr.obs-vr.mean;    inno.all=inno.all(vr.obs~=-9999 & isnan(vr.mean)~=1);
    inno.mean(ni)=mean(inno.all);  
    inno.rmsi(ni)=( mean( (inno.all-inno.mean(ti)).^2 ) )^0.5;
    %---ensemble spread---
    vr.perb=zeros(length(vr.mean),1);
    for i=1:mem
     vr.perb= vr.perb + ( (vr_ens(:,i)-vr.mean).^2 )./mem ;      
    end  
    vr.perb=vr.perb(isnan(vr.mean)~=1);
    sprd.en(ni) = sqrt (mean(vr.perb));   
    %    
  end  % fcst / anal  
  clear vr_ens
end %time
% 
sprd.idel=( abs(inno.rmsi.^2 - obserr^2) ).^0.5; 

x(1:2:num*2-1)=1:num;  x(2:2:num*2)=1:num;
%---plot
figure('position',[100 100 700 500])
plot(x,inno.mean,'color',[0 0 0],'LineWidth',2.5); hold on
plot(x,inno.rmsi,'color',[0 0 1],'LineWidth',2.5); 
plot(x,sprd.en,'color',[1 0 0],'LineWidth',2.5); 
plot(x,sprd.idel,'color',[0 0 0],'LineWidth',2.5,'LineStyle','-.'); 
%
set(gca,'XLim',[0 num+1],'YLim',[-2 5],'XTick',1:num,'XTickLabel',hm,'fontsize',14,'LineWidth',1)
xlabel('Time');   ylabel('m/s');
legh=legend('mean innovation','RMS innovation','enemble spread','ideal ensemble spread');
set(legh,'fontsize',12)
% 
 tit=[expri,'  ',vari];
 title(tit,'fontsize',15)
 outfile=[outdir,filenam,'.png'];
 print('-dpng',outfile,'-r400')     
   
