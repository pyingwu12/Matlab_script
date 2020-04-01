close all
clear
%---setting
expri='test35';
%year='2007'; mon='06'; date='01';
year='2018'; mon='06'; date='22';
hr=3; minu=[30 0]; infilenam='wrfout';  dom='01';  

indir=['/HDD003/pwin/Experiments/expri_test/',expri];
outdir=['/HDD001/Figures/expri_test/',expri];
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
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',s_min,':00'];
   %------read netcdf data--------
   qr = ncread(infile,'QRAIN'); qr=double(qr);
   qc = ncread(infile,'QCLOUD');qc=double(qc);
   qv = ncread(infile,'QVAPOR');qv=double(qv);
   qi = ncread(infile,'QICE');qi=double(qi);
   qs = ncread(infile,'QSNOW');qs=double(qs);
   qg = ncread(infile,'QSNOW');qg=double(qg);
   p = ncread(infile,'P');p=double(p);
   pb = ncread(infile,'PB');pb=double(pb);
   t = ncread(infile,'T');t=double(t);
   %---
   [nx,ny,nz]=size(qv);  zh=zeros(nx,ny,nz);
   temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
   den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);
   
   %---Gaddard scheme---
   fin=find(temp < 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   fin=find(temp >= 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.21e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   %--- 
   zh_max=max(zh,[],3);   
 
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
   
  end
end