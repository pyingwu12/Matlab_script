%------------------------------------------
% calculate root mean different total engergy 
%------------------------------------------
close all
clear;  ccc=':';
%---
expri='ens09';  s_date='22'; hr=2; minu=00;  member=1:10;
year='2018'; mon='06';  
dirmem='pert'; infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri]; outdir=['/mnt/e/figures/ens200323/',expri];
titnam='RMDTE';   fignam=[expri,'_RMDTE_'];
%
load('colormap/colormap_dte.mat')
cmap=colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
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
    u.stag = ncread(infile,'U');   v.stag = ncread(infile,'V');
    u.mean=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.mean=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    t.mean=ncread(infile,'T')+300; %t.mean=double(t.mean)+300;
    hgt=ncread(infile,'HGT');
    %---members
    [nx, ny, ~]=size(u.mean);
    MDTE=zeros(nx,ny);
    for mi=member
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %------read netcdf data--------
      u.stag = ncread(infile,'U');  v.stag = ncread(infile,'V');
      u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
      v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
      t.mem =ncread(infile,'T')+300; 
      p =ncread(infile,'P');  pb = ncread(infile,'PB');
      %---perturbation---
      u.pert = u.unstag - u.mean;
      v.pert = v.unstag - v.mean;
      t.pert = t.mem - t.mean;   
      P = (pb+p);    dP = P(:,:,2:end)-P(:,:,1:end-1);
      dPall = P(:,:,end)-P(:,:,1);
      dPm = dP./repmat(dPall,1,1,size(dP,3));
      %
      DTE = 1/2*(u.pert.^2 + v.pert.^2 + cp/Tr*t.pert.^2);
      MDTE = MDTE + sum(dPm.*DTE(:,:,1:end-1),3) ./length(member);  % ensemble mean and vertical weighting average
      RMDTE = MDTE.^0.5;
    end     
    %---plot---
    plotvar=RMDTE';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
    hf=figure('position',[100 45 800 680]);  
    [c, hp]=contourf(plotvar,L2,'linestyle','none');    
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    %s_hrj=num2str(mod(ti+9,24),'%2.2d'); 
    tit={expri,[titnam,'  ',s_hr,s_min,' UTC']};     
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
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
  end %tmi
end
