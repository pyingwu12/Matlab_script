close all
clear;   ccc=':';
saveid=1; % save figure (1) or not (0)

lev=1;
%---setting
expri='TWIN031B';  day=21;  hr=15;  minu=00;    
int=10;  qscale=2.2;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)

indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/JAS_R2'];
titnam='10-m wind';   fignam=[expri,'_wind10m_'];

load('colormap/colormap_wind2.mat')
cmap=colormap_wind2;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5];
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu    
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    u10 = ncread(infile,'U10');   v10 = ncread(infile,'V10');     
    hgt = ncread(infile,'HGT');   
    [nx, ny, ~]=size(u10);   
    plotvar=(u10.^2+v10.^2).^0.5;

    u.stag = double(ncread(infile,'U'));
    v.stag = double(ncread(infile,'V'));
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;

    
    %---
    uplot=u10(1:int:end,1:int:end);   vplot=v10(1:int:end,1:int:end);
    [xi, yi]=meshgrid(1:int:nx, 1:int:ny);
   %%
    %---plot---
    titnam='10-m wind';   fignam=[expri,'_wind10m_'];
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[45 60 800 680]);
    [~, hp]=contourf(plotvar',L2,'linestyle','none');   hold on 
    %
    h1 = quiver(xi,yi,uplot',vplot',0,'color',[0.3 0.3 0.3]) ; % the '0' turns off auto-scaling
    hU = get(h1,'UData');   hV = get(h1,'VData') ;
    set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.55);
    %  
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.1 0.1 0.1],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',18,'LineWidth',1.2)     
%     set(gca,'Xlim',[1 150],'Ylim',[1 150])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  
    tit=[expri,'  ',titnam,'  ',s_hrj,s_min,' LT'];     
    title(tit,'fontsize',18)
    
    %---colorbar---
%     caxis([L(1) L(end)])
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); 
    title(hc,'m/s','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end    
    %---    
 
    outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min];
    if saveid~=0
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
   %}

%% model level
lev=1;
titnam=['wind (lev',num2str(lev),')'];   fignam=[expri,'_wind-lev',num2str(lev),'_'];
    uplot=u.unstag(1:int:end,1:int:end,lev);   vplot=v.unstag(1:int:end,1:int:end,lev);
        spd=double((u.unstag(:,:,lev).^2+v.unstag(:,:,lev).^2).^0.5);
    %---plot---
    pmin=double(min(min(spd)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[45 60 800 680]);
    [~, hp]=contourf(spd',L2,'linestyle','none');   hold on 
    %
    h1 = quiver(xi,yi,uplot',vplot',0,'color',[0.3 0.3 0.3]) ; % the '0' turns off auto-scaling
    hU = get(h1,'UData');   hV = get(h1,'VData') ;
    set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.55);
    %  
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.1 0.1 0.1],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',18,'LineWidth',1.2)     
%     set(gca,'Xlim',[1 150],'Ylim',[1 150])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  
    tit=[expri,'  ',titnam,'  ',s_hrj,s_min,' LT'];     
    title(tit,'fontsize',18)
    
    %---colorbar---
%     caxis([L(1) L(end)])
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); 
    title(hc,'m/s','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end    
    %---    
 
    outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min];
    if saveid~=0
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
   %}

  end %min
end
