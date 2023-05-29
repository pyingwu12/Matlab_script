%------------------------------------------
% plot horizontal distribution of variables
%------------------------------------------
% close all
clear;   ccc=':';
saveid=0; % save figure (1) or not (0)
%---
expri='TWIN003B'; 
day=22;  hr=21;  minu=30;  
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
% titnam='Latent heat flux at surface';   fignam=[expri,'_Lhfx_',];
titnam='Upward Heat flux at surface';   fignam=[expri,'_hfx_',];
tit_unit='Wm^-^2';
%---

%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile,'HGT');
    %
%     qc = double(ncread(infile,'QCLOUD'));   
%     lhfx = ncread(infile,'LH'); 
    hfx = ncread(infile,'HFX'); 
%
    %---plot---  
    plotvar=hfx';
    %
    hf=figure('position',[100 75 800 700]); 
    contourf(plotvar,10,'linestyle','none');    
    %---
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.45 0.45 0.45],'linestyle','--','linewidth',2.5); 
    end
    %---
    set(gca,'fontsize',18,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
      if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',18,'Interpreter','none')
    
    %---colorbar---
    hc=colorbar('fontsize',14,'LineWidth',1.2);
    title(hc,tit_unit,'fontsize',14);  drawnow;
    caxis([min(plotvar(:)) max(plotvar(:)) ])
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
      print(hf,'-dpng',[outfile,'.png']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
    end
  end %tmi
end
