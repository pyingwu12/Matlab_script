close all
clear;   ccc=':';
%---setting
expri='TWIN003B';  s_date='22'; hr=22:23; minu=00; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
xp=1; yp=100;  %start grid
len=249;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%---
% indir=['/HDD003/pwin/Experiments/expri_test/',expri]; outdir='/mnt/e/figures/expri191009';
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='Temperature';   fignam=[expri,'_Tprof_'];
%---
%
load('colormap/colormap_parula.mat')
cmap=colormap_parula; cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[286 288 290 292 294 296 298 300 302 304];
%---
Rcp=287.43/1005; 
g=9.81;
zgi=[10:10:1500,1550:50:2000,2100:100:5000];    ytick=500:500:zgi(end); 

for ti=hr
  for mi=minu   
    %---set filename---
    s_hr=num2str(ti,'%2.2d');   s_min=num2str(mi,'%2.2d');
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
   
    [nx, ny, nz]=size(t);
    [y, x]=meshgrid(1:ny,1:nx);
 
%---interpoltion---    
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);       
      X=squeeze(zg(indx,indy,:));   Y=squeeze(T(indx,indy,:));   
      plotvar(:,i)=interp1(X,Y,zgi,'linear');
      hgtprof(i)=hgt(indx,indy);
    end       
   
    %---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';  [xi, zi]=meshgrid(linex,zgi);  xaxis=linex;
    else;               xtitle='Y (km)';   [xi, zi]=meshgrid(liney,zgi);  xaxis=liney; 
    end
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end
    %---plot---       
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 200 900 600]);
    [c, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none');
    
    if (max(max(hgtprof))~=0)
     hold on;      plot(hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end
    
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Ytick',ytick,'Yticklabel',ytick./1000)
    xlabel(xtitle); ylabel('km')
    tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
    title(tit,'fontsize',18)  
    
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap); title(hc,'K','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---
    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope)];
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    
  end
end
