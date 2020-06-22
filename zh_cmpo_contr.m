% plot Zh composite equal to <zhcr> of ensemble members and mean
close all
clear
%---setting
expri='ens08';  member=1:10;   zhcr=30;
year='2018'; mon='06'; date='21';  hr=15:16;  minu=00; 
dirmem='pert'; infilenam='wrfout';  dom='01';  
scheme='WSM6'; %scheme='Gaddard';

indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
titnam='Zh composite';   fignam=[expri,'_zh-contr',num2str(zhcr),'_'];

for ti=hr  
  s_hr=num2str(ti,'%.2d');
  for tmi=minu  
    s_min=num2str(tmi,'%.2d');        
    %figure('position',[100 10 780 630]);    
    figure('position',[-1200 100 780 640]);  
    for mi=member
      %---set filename---
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',s_min,':00'];      
      zh_max=cal_zh_cmpo(infile,scheme);  
      %---plot---
      plotvar=zh_max';   %plotvar(plotvar<=0)=NaN;
      contour(plotvar,[zhcr zhcr],'color',[0.6 0.6 0.6],'linewidth',1.8); hold on 
      %disp(['member ',nen,' done'])
%---    
    end  % member
    %---read mean file and plot
      infile=[indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',s_min,':00'];
      hgt = ncread(infile,'HGT');
      zh_max=cal_zh_cmpo(infile,scheme);
      %---
      plotvar=zh_max';
      contour(plotvar,[zhcr zhcr],'color',[0.9 0.05 0.1],'linewidth',2.4); 
      if (max(max(hgt))~=0)
      hold on; contour(hgt',[100 500 900],'color',[0.2 0.65 0.3],'linestyle','--','LineWidth',1.8); 
      end
    %----    
    set(gca,'fontsize',16,'LineWidth',1.2)
      jhr=ti+9;  jhr=jhr-24*fix(jhr/24);  s_jhr=num2str(jhr,'%.2d');
      tit=[expri,'  ',titnam,'  ',s_jhr,s_min,' JST'];     
      title(tit,'fontsize',17)
    outfile=[outdir,'/',fignam,mon,date,'_',s_hr,s_min];
    print('-dpng',[outfile,'.png']) 
    
    %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %system(['rm ',[outfile,'.pdf']]);  
    
  end % tmi=minu  
end % ti=hr
