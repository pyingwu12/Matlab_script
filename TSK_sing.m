close all
clear;   ccc=':';
%---setting
expri='test43';
%year='2018'; mon='08'; date='19';
year='2018'; mon='06'; date='22';
hr=0; minu=0; infilenam='wrfout';  dom='01'; 

%---
%indir=['E:/wrfout/expri191009/',expri];
%outdir='E:/figures/expri191009/';
indir=['/HDD003/pwin/Experiments/expri_test/',expri];
outdir='/mnt/e/figures/expri191009/';
titnam='Skin Temperature';   fignam=[expri,'_tsk-prof_'];

load('colormap/colormap_parula.mat')
cmap=colormap_parula; 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%L=273+[20 21 23 25 27 29 31 33 35 37];
L=273+[19 21 23 25 27 29 31 33 34 35];
%---


for ti=hr   
 for mi=minu    
   %ti=hr; mi=minu;
   %---set filename---
   s_hr=num2str(ti,'%2.2d');  % start time string
   s_min=num2str(mi,'%2.2d');
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,s_min,ccc,'00'];
   tsk = ncread(infile,'TSK');      
 
   %---plot---
   plotvar=tsk';  
   pmin=double(min(min(plotvar))) 
   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
   fi=find(L>pmin);
   %
   hf=figure('position',[-1100 200 900 600]);
   [c, hp]=contourf(plotvar,L2,'linestyle','none');
   %colorbar('fontsize',13,'LineWidth',1.2)
   %caxis([290 305])
   set(gca,'fontsize',16,'LineWidth',1.2)

   tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
   title(tit,'fontsize',18)  
   
   %---
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
   h=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
   colormap(cmap)
   title(h,'K','fontsize',13)
   
   drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
   end   
%---    
   outfile=[outdir,'/',fignam,mon,date,'_',s_hr,s_min];
   print(hf,'-dpng',[outfile,'.png']) 
   
    %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %system(['rm ',[outfile,'.pdf']]);  
   
 end
end