close all
clear
%---setting
expri='ens09';  s_date='22';  hr=0;  minu=0;  member=9;
%---
year='2018'; mon='06'; 
dirmem='pert';  infilenam='wrfout';  dom='01';  grids=1;
%---
indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
%---
titnam='Total-qv';   fignam=[expri,'_TPWqv_'];
%
load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[65.5 66 66.5 67 67.5 68 69 70 71 72];
%---
%
for ti=hr   
  s_hr=num2str(ti,'%.2d');  % start time string
  for tmi=minu   
    s_min=num2str(tmi,'%.2d');
    for mi=member        
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
      %------read netcdf data--------
      qv = ncread(infile,'QVAPOR');qv=double(qv);
      p = ncread(infile,'P');p=double(p);     pb = ncread(infile,'PB');pb=double(pb);
      t = ncread(infile,'T');t=double(t);
      hgt = ncread(infile,'HGT');     
      %---
      [nz]=size(qv,3);
      P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
      tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
      TPW=squeeze(sum(tpw,3)./9.81);
      %
      %---plot---
      plotvar=TPW';   %plotvar(plotvar<=0)=NaN;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
       %
      hf=figure('position',[100 200 800 680]);
      [c, hp]=contourf(plotvar,L2,'linestyle','none');
      if (max(max(hgt))~=0)
       hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
      end
      %
      set(gca,'fontsize',16,'LineWidth',1.2) 
      set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
      xlabel('(km)'); ylabel('(km)');
      tit={[expri,' mem',nen];[titnam,'  ',s_hr,s_min,' UTC']};     
      title(tit,'fontsize',18)
      %
      %---colorbar---
      fi=find(L>pmin);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
      colormap(cmap); title(hc,'Kg/m^2','fontsize',13);  drawnow;
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
      end  
      %---
      
      outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_m',nen];
      print(hf,'-dpng',[outfile,'.png'])       
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);      
    end
  end
end
