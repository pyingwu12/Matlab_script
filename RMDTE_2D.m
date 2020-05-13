close all
clear;  ccc=':';
%---
expri='ens05';  member=1:20;
year='2018'; mon='06';  s_date='22'; hr=0:12; minu=00;
dom='01';  dirmem='pert'; infilenam='wrfout';  
%
indir=['/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir='/mnt/e/figures/ens200323/';
titnam='RMDTE';   fignam=[expri,'_RMDTE_'];
%

colormap_dte=[
    0.8467    0.9900    1.0000
    0.6990    0.9735    0.9900
    0.5225    0.8676    0.9800
    0.3461    0.7578    0.9343
    0.2284    0.7186    0.7186
    0.3382    0.8559    0.5422
    0.6990    0.9539    0.3069
    0.9735    0.9735    0.3735
    0.9804    0.8865    0.3447
    0.9847    0.8167    0.2873
    1.0000    0.5941    0.1931];

%load('colormap/colormap_pbl.mat')
cmap=colormap_dte; %cmap(1,:)=[1 1 1];
cmap(cmap>1)=1;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 2.3];
%
cp=1004.9;
Tr=270;

for ti=hr 
   s_hr=num2str(ti,'%2.2d'); 
   for tmi=minu
     s_min=num2str(tmi,'%.2d');
     %---ensemble mean
     infile=[indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     u.stag = ncread(infile,'U');%u.stag=double(u.stag);
     v.stag = ncread(infile,'V');%v.stag=double(v.stag);
     u.mean=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
     v.mean=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
     t.mean=ncread(infile,'T')+300; %t.mean=double(t.mean)+300;
     hgt=ncread(infile,'HGT');
     %--members
     [nx, ny, ~]=size(u.mean);
     MDTE=zeros(nx,ny);
     for mi=member
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %------read netcdf data--------
      u.stag = ncread(infile,'U'); %u.stag=double(u.stag);
      v.stag = ncread(infile,'V'); %v.stag=double(v.stag);
      t.mem =ncread(infile,'T')+300; %t.mem=double(t.mem)+300;
      p = ncread(infile,'P');%p=double(p);
      pb = ncread(infile,'PB');%pb=double(pb);
      u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
      v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
      %---perturbation---
      u.pert=u.unstag - u.mean;
      v.pert=v.unstag - v.mean;
      t.pert=t.mem - t.mean;   
      P=(pb+p);     dP=P(:,:,2:end)-P(:,:,1:end-1);
      dPall=P(:,:,end)-P(:,:,1);
      dPm=dP./repmat(dPall,1,1,size(dP,3));
      %
      DTE=1/2*(u.pert.^2+v.pert.^2+cp/Tr*t.pert.^2);
      MDTE=MDTE+sum(dPm.*DTE(:,:,1:end-1),3)./length(member);  
      RMDTE=MDTE.^0.5;
     end
     
     %---plot---
      plotvar=RMDTE';   %plotvar(plotvar<=0)=NaN;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
      fi=find(L>pmin);
       %
      hf=figure('position',[10 20 830 600]);
    
      [c, hp]=contourf(plotvar,L2,'linestyle','none');       
      set(gca,'fontsize',16,'LineWidth',1.2)
      
      if (max(max(hgt))~=0)
        hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
      end
      tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
      title(tit,'fontsize',17)
% %---
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      h=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.1);
      colormap(cmap)
   
      drawnow;
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
         hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
      end   
%---    
      outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min];
      print(hf,'-dpng',[outfile,'.png']) 
      system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
     
   end %tmi
end