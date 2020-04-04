close all
clear; ccc=':';
%---setting
expri='test24';
%year='2018'; mon='08'; date='19';
%year='2018'; mon='06'; date='22';
year='2007'; mon='06'; date='01';
hr=15; minu=[0]; infilenam='wrfout';  dom='01'; 

%indir=['E:/wrfout/expri191009/',expri];
%outdir='E:/figures/expri191009/';
indir=['/HDD003/pwin/Experiments/expri_test/',expri];
outdir='/mnt/e/figures/expri191009/';
titnam='Total-qv';   fignam=[expri,'_TPW-qv_'];

load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[65.5 66 66.5 67 67.5 68 69 70 71 72];
%---

for ti=hr
  for mi=minu    
   %---set filename---
   s_hr=num2str(ti,'%2.2d');  
   s_min=num2str(mi,'%2.2d');
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,s_min,ccc,'00'];
   %------read netcdf data--------
   qv = ncread(infile,'QVAPOR');qv=double(qv);
   p = ncread(infile,'P');p=double(p);
   pb = ncread(infile,'PB');pb=double(pb);
   t = ncread(infile,'T');t=double(t);
   %---
   [nz]=size(qv,3);
   P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
   tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
   TPW=squeeze(sum(tpw,3)./9.81);


   %---plot---
   plotvar=TPW';   %plotvar(plotvar<=0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
   hf=figure('position',[-900 200 800 600]);
   [c, hp]=contourf(plotvar,L2,'linestyle','none');
   set(gca,'fontsize',16,'LineWidth',1.2)
   
   
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
   hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
   colormap(cmap)

   drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx,:)');
   end
%---
   tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
   title(tit,'fontsize',18)
    
   outfile=[outdir,fignam,mon,date,'_',s_hr,s_min];
   print(hf,'-dpng',[outfile,'.png']) 
  end
end

