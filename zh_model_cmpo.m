close all
clear;   ccc=':';
%---setting
expri='test91';  dom='01';  grids=1;%grid_spacing(km)
year='2018'; mon='06'; s_date='21'; 
hr=16:23; minu=[00 30]; infilenam='wrfout';  
scheme='WSM6';

%indir=['E:/wrfout/expri191009/',expri];
%outdir='E:/figures/expri191009/';
indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];
outdir=['/mnt/e/figures/expri191009/',expri,'/'];
titnam='Zh composite';   fignam=[expri,'_zh-model_d',dom,'_'];

load('colormap/colormap_zh.mat')
cmap=colormap_zh; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 3 6 10 15 20 25 30 35 40 45 50 55 60 65 70];
%L=[2 6 10 15 20 25 30 35 40 45 50 55 60 65 70 75];
%---

for ti=hr   
  for mi=minu    
   %ti=hr; mi=minu;
   %---set filename---
   s_hr=num2str(ti,'%2.2d');  % start time string
   s_min=num2str(mi,'%2.2d');
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
   hgt = ncread(infile,'HGT');  
   zh_max=cal_zh_cmpo(infile,scheme);         
  
   %---plot----------
   plotvar=zh_max';   %plotvar(plotvar<=0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
   fi=find(L>pmin);
    %
   hf=figure('position',[100 45 800 600]);  
   [c, hp]=contourf(plotvar,L2,'linestyle','none');
   set(gca,'fontsize',16,'LineWidth',1.2)
   set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
   xlabel('(km)'); ylabel('(km)');
   
   if (max(max(hgt))~=0)
    hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--'); 
   end

   tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
   title(tit,'fontsize',18)
%---
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis);
   h=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
   colormap(cmap)
   title(h,'dBZ','fontsize',13)
   
   drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
   end   
%---    
   outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min];
   print(hf,'-dpng',[outfile,'.png'])    
    %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %system(['rm ',[outfile,'.pdf']]);  
   
  end
end