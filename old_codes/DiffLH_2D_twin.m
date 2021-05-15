%------------------------------------------
% calculate Lantent heat difference of two experiments 
% defined as DLH = Lv * s'^2
%------------------------------------------
% close all
clear;  ccc=':';
%---
expri='TWIN001';  expri1=[expri,'Pr001qv062221noMP'];  expri2=[expri,'B062221noMP']; 
s_date='23';  hr=21;  minu=[0];    zhid=0;
%
year='2018'; mon='06';  
dirmem='pert'; infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin/';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='Different latent heat (ver-w-a)';  fignam=[expri1(8:end),'_DiffLH_',];
if zhid~=0; fignam=[fignam,'zh_']; end
%
load('colormap/colormap_dte.mat')
cmap=colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.0001 0.0005 0.001 0.005 0.01 0.03 0.05 0.07 0.1 0.2];
%  L=[0.005 0.01 0.05 0.1 0.5 1 2 3 4 5];
%  L=[0.5 2 4 6 8 10 15 20 25 30];
%
%
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile2,'HGT');
    
    w = ncread(infile2,'W');
    
    %
    if zhid~=0; zh_max=cal_zh_cmpo(infile1,'WSM6'); end   
    MDiffLH = cal_DiffLH_2D(infile1,infile2);
    %
    %---plot---
    plotvar=MDiffLH';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 45 800 680]);  
    [c, hp]=contourf(plotvar,L2,'linestyle','none');    
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    if zhid~=0
     hold on; contour(zh_max',[30 30],'color',[0.1 0.1 0.1],'linewidth',1.2); 
    end
    hold on; contour((w(:,:,15))',[0.1 0.1],'color',[0.9 0.02 0.1],'linewidth',1.5)
    
    %
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    %s_hrj=num2str(mod(ti+9,24),'%2.2d'); 
    tit={[expri1,'  ',s_hr,s_min,' UTC'],titnam};     
    title(tit,'fontsize',18)
      
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap);     drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
%     print(hf,'-dpng',[outfile,'.png']) 
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
  end %tmi
end
