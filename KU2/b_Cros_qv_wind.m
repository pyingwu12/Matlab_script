

close all
clear;   ccc=':';
%---setting
expri='TWIN031B';   day=22;  hr=21;  minu=00;  
%---
xp=1; yp=150;  %start grid
len=150;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Qv';   fignam=[expri,'_cros-qv_'];
%---
load('colormap/colormap_qr3.mat'); 
cmap=colormap_qr3(1:end-1,:);     cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[12 13 14 15 16 17 18 19 20];
%--
g=9.81;
zlim=4000; ytick=500:500:zlim; 

for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qv = ncread(infile,'QVAPOR');
    u.stag = ncread(infile,'U');
    w.stag = ncread(infile,'W');

    %---
    hgt = ncread(infile,'HGT');
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    %---
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;     

    [nx, ny, ~]=size(ph);
    [y, x]=meshgrid(1:ny,1:nx);
 
    
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;

    
    
%---decide cross section---       
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);       
      Zaxis(:,i)=squeeze(zg(indx,indy,:));  
      
      qv_prof(:,i)=squeeze(qv(indx,indy,:));
      w.prof(:,i)=squeeze(w.unstag(indx,indy,:));
      u.prof(:,i)=squeeze(u.unstag(indx,indy,:));
      
      hgtprof(i)=hgt(indx,indy);
    end    

%---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';    xaxis=linex;  
    else;               xtitle='Y (km)';    xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end
%%
%---theta_prof
    xi=repmat(xaxis*1e3,size(Zaxis,1),1);
    plotvar=qv_prof*1e3;
    plotvar(Zaxis>zlim)=NaN;
    %
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    % 
    hf=figure('position',[100 200 1200 800]);
    [c, hp]=contourf(xi,Zaxis,plotvar,L2,'linestyle','none'); 
%     
    hc=colorbar; 
%     caxis([301 318]); title(hc,'K')

    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end   
%     
    %---wind vector----
    intu=4000;  intw=1;        
    Zaxis2=Zaxis(1:intw:end,1:intu/1000:end);
    xi2=repmat(1:intu:xaxis(end)*1e3, size(Zaxis2,1),1);
    
    w.plot= w.prof(1:intw:end,1:intu/1000:end);  
    u.plot= u.prof(1:intw:end,1:intu/1000:end);
    h1 = quiver(xi2,Zaxis2,u.plot,w.plot,0,'k','MaxHeadSize',0.002) ; % the '0' turns off auto-scaling
    hU = get(h1,'UData');   hV = get(h1,'VData') ;
    qscale=800;
    set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1);   

    
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'xlim',[0 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)

    xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
    text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])

    xlabel(xtitle); ylabel('Height (km)')
    s_hrj=num2str(mod(ti+9,24),'%.2d');
    tit=[expri,'  ',titnam,'  ',s_hrj,s_min,' LT'];     
    title(tit,'fontsize',18)  
    
        
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap); title(hc,'K','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end          

%     %    
%     outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_z',num2str(zlim)];
%     print(hf,'-dpng',[outfile,'.png']) 
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
  end
end
