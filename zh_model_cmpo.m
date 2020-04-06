close all
clear;   ccc='%3A';
%---setting
expri='test38';
%year='2018'; mon='08'; date='19';
year='2018'; mon='06'; date='22';
%year='2007'; mon='06'; date='01';
hr=9:20; minu=[0]; infilenam='wrfout';  dom='01'; 
scheme='WSM6';


indir=['E:/wrfout/expri191009/',expri];
outdir='E:/figures/expri191009/';
%indir=['/HDD003/pwin/Experiments/expri_test/',expri];
%outdir='/mnt/e/figures/expri191009/';
titnam='Zh composite';   fignam=[expri,'_zh-model_'];

load('colormap/colormap_zh.mat')
cmap=colormap_zh; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0 2 6 10 15 20 25 30 35 40 45 50 55 60 65 70];
%---

for ti=hr   
  for mi=minu    
   %ti=hr; mi=minu;
   %---set filename---
   s_hr=num2str(ti,'%2.2d');  % start time string
   s_min=num2str(mi,'%2.2d');
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,s_min,ccc,'00'];
   zh_max=cal_zh_cmpo(infile,scheme);  
 
   %---plot---
   plotvar=zh_max';   %plotvar(plotvar<=0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
   hf=figure('position',[-900 200 800 600]);
   [c, hp]=contourf(plotvar,L2,'linestyle','none');
   set(gca,'fontsize',16,'LineWidth',1.2)

   tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
   title(tit,'fontsize',18)
%---
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
   h=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
   colormap(cmap)
   
   drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx,:)');
   end   
%---    
   outfile=[outdir,'/',fignam,mon,date,'_',s_hr,s_min];
   print(hf,'-dpng',[outfile,'.png']) 
   
    %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %system(['rm ',[outfile,'.pdf']]);  
   
  end
end