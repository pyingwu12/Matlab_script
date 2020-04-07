close all
clear;   ccc=':';
%---setting
expri='test43';
%year='2018'; mon='08'; date='19';
year='2018'; mon='06'; date='21';
hr=21:23; minu=00; infilenam='wrfout';  dom='01'; 

%---
%indir=['E:/wrfout/expri191009/',expri];
%outdir='E:/figures/expri191009/';
indir=['/HDD003/pwin/Experiments/expri_test/',expri];
outdir='/mnt/e/figures/expri191009/';
titnam='Skin Temperature';   fignam=[expri,'_tsk-prof_'];

load('colormap/colormap_zh.mat')
cmap=colormap_zh; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0 2 6 10 15 20 25 30 35 40 45 50 55 60 65 70];
%---
Rcp=287.43/1005; 
g=9.81;
zgi=[10,50,100:100:20000];    ytick=1000:2000:zgi(end); 



for ti=hr   
 for mi=minu    
   %ti=hr; mi=minu;
   %---set filename---
   s_hr=num2str(ti,'%2.2d');  % start time string
   s_min=num2str(mi,'%2.2d');
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,s_min,ccc,'00'];
   tsk = ncread(infile,'TSK');      
 
   %---plot---
   plotvar=tsk';   %plotvar(plotvar<=0)=NaN;
   hf=figure('position',[-1100 200 900 600]);
   contourf(plotvar,20,'linestyle','none')
   colorbar('fontsize',13,'LineWidth',1.2)
   set(gca,'fontsize',16,'LineWidth',1.2)

   tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
   title(tit,'fontsize',18)
%---    
   outfile=[outdir,'/',fignam,mon,date,'_',s_hr,s_min];
   %print(hf,'-dpng',[outfile,'.png']) 
   
    %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    %system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %system(['rm ',[outfile,'.pdf']]);  
   
 end
end