close all
clear;   ccc=':';
%---setting
expri='TWIN001';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
s_date='23'; hr=4; minu=00;  h_int=100;
%---
xp=1;  yp=100;  %start grid
len=299;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%----
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD008/pwin/Experiments/expri_twin'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='Cloud particles';   fignam=[expri2,'_Qhyd_'];
%---
load('colormap/colormap_qr3.mat')
cmap=colormap_qr3; %cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.05 0.1 0.5 1 2 4 6 8 10 12];
%---
g=9.81;
zgi=50:h_int:15000;    ytick=1000:2000:zgi(end); 
%
for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    %---infile 1 (perturbed state)---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qr = ncread(infile1,'QRAIN');  %qr=double(qr);   
    qs = ncread(infile1,'QSNOW');  %qs=double(qs);    
    qg = ncread(infile1,'QGRAUP'); %qg=double(qg);
    qi = ncread(infile1,'QGRAUP'); %qi=double(qi);
    qc = ncread(infile1,'QGRAUP'); %qc=double(qc);
    hyd1 = (qr+qs+qg+qi+qc) * 1e3 ;
    %   
    %--- 
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qr = ncread(infile2,'QRAIN');  %qr=double(qr);   
    qs = ncread(infile2,'QSNOW');  %qs=double(qs);    
    qg = ncread(infile2,'QGRAUP'); %qg=double(qg);
    qi = ncread(infile2,'QGRAUP'); %qi=double(qi);
    qc = ncread(infile2,'QGRAUP'); %qc=double(qc);
    hyd2 = (qr+qs+qg+qi+qc) * 1e3 ; 
    %
    hgt = ncread(infile2,'HGT');  
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');        
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   
    zg=double(PH)/g;     
    %
    [nx, ny, ~]=size(qr);
    [y, x]=meshgrid(1:ny,1:nx);  
%---interpoltion--- 
    i=0;  xB=0; yB=0;
    while xB<x(xp,yp)+len && yB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  xB=linex(i);     
      liney(i)=y(indx,indy);  yB=liney(i);       
      X=squeeze(zg(indx,indy,:));         
      hydprof1(:,i)=interp1(X,squeeze(hyd1(indx,indy,:)),zgi,'linear');  
      hydprof2(:,i)=interp1(X,squeeze(hyd2(indx,indy,:)),zgi,'linear');        
      hgtprof(i)=hgt(indx,indy);            
    end       
    
    

    %
%---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';   xaxis=linex;    
    else;               xtitle='Y (km)';   xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end    
    %---plot--- 
    [xi, zi]=meshgrid(xaxis,zgi); 
    plotvar=hydprof1;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 200 900 600]);
    [c, hp]=contourf(xi,zi,hydprof2,L2,'linestyle','none');  hold on    
    contour(xi,zi,hydprof1,[0.05 0.05],'color',[0.1 0.02 0.1],'LineWidth',1.5,'Linestyle','--')
    if (max(max(hgtprof))~=0)
     plot(hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end
    %
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Ytick',ytick,'Yticklabel',ytick./1000)
    xlabel(xtitle); ylabel('km')
    tit=[expri2,'  ',titnam,'  ',s_hr,s_min,' UTC'];     
    title(tit,'fontsize',18)  
    
    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1(1:end),'YTickLabel',L(1:end),'fontsize',13,'LineWidth',1.2);
    colormap(cmap); title(hc,'g/Kg','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---
    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,...
        '_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_h',num2str(h_int)];
%     print(hf,'-dpng',[outfile,'.png'])    
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %}
  end
end