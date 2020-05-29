close all
clear; ccc=':';
%---setting
expri='test80';  dom='01'; grids=1; %grid_spacing(km)
year='2018'; mon='06'; date='22';
hr=12; minu=[0]; infilenam='wrfout';  


indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];
outdir=['/mnt/e/figures/expri191009/',expri,'/'];
titnam='Total-qv';   fignam=[expri,'_TPW-qv_d',dom,'_',];

load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[65.5 66 66.5 67 67.5 68 69 70 71 72];
%---

for ti=hr
  for mi=minu    
   %---set filename---
   s_hr=num2str(ti,'%2.2d');   s_min=num2str(mi,'%2.2d');
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,s_min,ccc,'00'];
   %------read netcdf data--------
   qv = ncread(infile,'QVAPOR');qv=double(qv);
   p = ncread(infile,'P');p=double(p);
   pb = ncread(infile,'PB');pb=double(pb);  
   hgt = ncread(infile,'HGT');
   %---
   [nz]=size(qv,3);
   P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
   tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
   TPW=squeeze(sum(tpw,3)./9.81);

   %---plot---
   plotvar=TPW';   %plotvar(plotvar<=0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
   fi=find(L>pmin); 
   %---    
   hf=figure('position',[100 45 800 600]);
   [c, hp]=contourf(plotvar,L2,'linestyle','none');
   set(gca,'fontsize',16,'LineWidth',1.2)
   set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
   xlabel('(km)'); ylabel('(km)');
   %
   if (max(max(hgt))~=0)
      hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.6); 
   end
   %
   tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
   title(tit,'fontsize',18)
   %   
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
   hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1);
   colormap(cmap)

   drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
   end
   %---    
   outfile=[outdir,fignam,mon,date,'_',s_hr,s_min];
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
end

