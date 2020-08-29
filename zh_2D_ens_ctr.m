% plot Zh composite equal to <zhcr> of ensemble members and mean
close all
clear
%---setting
expri='ens09';  s_date='22';  hr=0;  minu=00;  member=1:10;   zhcr=30;
%---
year='2018'; mon='06'; 
dirmem='pert'; infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
scheme='WSM6'; %scheme='Gaddard';

indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
titnam='Zh composite';   fignam=[expri,'_zh',num2str(zhcr),'_'];

for ti=hr  
  s_hr=num2str(ti,'%.2d');
  for tmi=minu  
    s_min=num2str(tmi,'%.2d');    
    %---
    hf=figure('position',[100 45 760 680]);      
    for mi=member
      %---set filename---
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];      
      zh_max=cal_zh_cmpo(infile,scheme);  
      %---plot members---
      plotvar=zh_max';   
      contour(plotvar,[zhcr zhcr],'color',[0.6 0.6 0.6],'linewidth',1.8); hold on 
      %disp(['member ',nen,' done'])
    end  % member    
    %
    %---read mean file---
    infile=[indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
    hgt = ncread(infile,'HGT');
    zh_max=cal_zh_cmpo(infile,scheme);
    %---plot mean---
    plotvar=zh_max';     
    contour(plotvar,[zhcr zhcr],'color',[0.9 0.05 0.1],'linewidth',2.4); 
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.2 0.65 0.3],'linestyle','--','LineWidth',1.8); 
    end
    %----    
    set(gca,'fontsize',16,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');    
    %
    %s_jhr=num2str(mod(ti+9,24),'%.2d');
    tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
    title(tit,'fontsize',18)
    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print('-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    
  end % tmi=minu  
end % ti=hr
