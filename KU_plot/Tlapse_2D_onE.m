% close all
clear; ccc=':';
saveid=0; % save figure (1) or not (0)
%---setting
expri='TWIN020B'; day=22;  hr=23:26;  minu=00;     height=500;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri]; outdir=['/mnt/e/figures/expri191009/',expri];
%---
titnam='Lapse rate';   fignam=[expri,'_Tlapse_'];
%
load('colormap/colormap_qr3.mat'); cmap=colormap_qr3;
cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[5.3 5.5 5.7 5.9 6.1 6.3 6.5 6.7 6.9 7.1];
L=[5.7 5.9 6.1 6.3 6.5 6.7 6.9 7.1 7.3 7.5];
%---

Rcp=287.43/1005; 
g=9.81;


for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');   t=t+300;   
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    p = ncread(infile,'P');   pb = ncread(infile,'PB');
    hgt = ncread(infile,'HGT');
    
    %----   
    P=p+pb;
    T=t.*(1e5./P).^(-Rcp); %temperature
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;
    
    [nx, ny, ~]=size(T);
    for i=1:nx
      for j=1:ny
        X=squeeze(zg(i,j,:));
        Y=squeeze(T(i,j,:));   variso(i,j)=interp1(X,Y,height,'linear');
      end
    end  
    
    Tdiff=T(:,:,1)-variso;
    zgdiff=height-zg(:,:,1);
    Tlaspe=Tdiff./zgdiff*1e3;
    
 %%
    %---plot---
    plotvar=Tlaspe';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 45 800 680]);  
    [c, hp]=contourf(plotvar,20,'linestyle','none');
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end    
    hold on; contour(plotvar,[9.8 9.8],'color','k','linewidth',1.8)
    %
    set(gca,'fontsize',18,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={expri,[titnam,' below ',num2str(height),'m   ',s_hr,s_min,' UTC']}; 
    title(tit,'fontsize',18)

    %---colorbar---
    hc=colorbar;  caxis([min(min(plotvar)) max(max(plotvar))])
    title(hc,'K/km','fontsize',13);  
%     fi=find(L>pmin,1);
%     L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
%     hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
%     colormap(cmap); title(hc,'K/km','fontsize',14);  drawnow;
%     hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%     for idx = 1 : numel(hFills)
%       hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
%     end
    %---
%    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_h',num2str(height)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
   
figure; contourf(squeeze(t(59,:,1:12))');colorbar

  end
end
