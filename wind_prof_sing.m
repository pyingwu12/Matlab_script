% close all
clear;   ccc=':';
%---setting
expri='TWIN025B';  s_date='22'; hr=23;  minu=00; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
xp=1; yp=100;  %start grid
len=150;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='Wind';   fignam=[expri,'_wind_'];
%---
load('colormap/colormap_parula20.mat'); cmap=colormap_parula20; 
cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-1.1 -0.9 -0.7 -0.5 -0.4 -0.3 -0.2 -0.1  -0.05  0  -0.05 0.1 0.2 0.3 0.4 0.5 0.7 0.9 1.1]*0.1;
L=[-1.1 -0.9 -0.7 -0.5 -0.4 -0.3 -0.2 -0.1  -0.05  0  -0.05 0.1 0.2 0.3 0.4 0.5 0.7 0.9 1.1]*0.2;

%---
g=9.81;
zgi=[10,50,100:100:20000];    ytick=1000:2000:zgi(end); 


for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u.stag = ncread(infile,'U');
    v.stag = ncread(infile,'V');
    w.stag = ncread(infile,'W');
    %---
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    hgt = ncread(infile,'HGT');
    %----   
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
    w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g; 

    [nx, ny, nz]=size(u.unstag);
    [y, x]=meshgrid(1:ny,1:nx);
 
%---interpoltion---       
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);       
      X=squeeze(zg(indx,indy,:));  
      Y=squeeze(u.unstag(indx,indy,:));     u.prof(:,i)=interp1(X,Y,zgi,'linear');  
      Y=squeeze(v.unstag(indx,indy,:));     v.prof(:,i)=interp1(X,Y,zgi,'linear');     
      Y=squeeze(w.unstag(indx,indy,:));     w.prof(:,i)=interp1(X,Y,zgi,'linear');
      hgtprof(i)=hgt(indx,indy);
    end      
   
%---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';    xaxis=linex;  
    else;               xtitle='Y (km)';    xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end
       %%
    %---plot---   
    plotvar=w.prof;
    [xi, zi]=meshgrid(xaxis,zgi);
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 200 900 600]);
    [c, hp]=contourf(xi,zi,plotvar,L2,'linestyle','none'); 
    %
    if (max(max(hgtprof))~=0)
     hold on;      plot(hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end   
    
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Ytick',ytick,'Yticklabel',ytick./1000)
    xlabel(xtitle); ylabel('Height (km)')
    tit=[expri,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
    title(tit,'fontsize',18)  
    
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1(1:2:end),'YTickLabel',L(1:2:end),'fontsize',13,'LineWidth',1.2);
    colormap(cmap); title(hc,'m/s','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---
     outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope)];
%    print(hf,'-dpng',[outfile,'.png']) 
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   
  end
end
