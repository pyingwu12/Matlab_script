

% close all
clear;   ccc=':';
%---setting

expri='TWIN003';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 

day=22;  hr=23;  minu=20;

%---
xp=26; yp=102;  %start grid
len=100;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir='/mnt/e/figures/expri_twin/JAS_R1';
titnam='Hydrometeors';   fignam=[expri1,'_cros-hyd-twin_'];
%---
load('colormap/colormap_qr3.mat'); 
cmap=colormap_qr3(1:2:end,:);     cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0.01 0.05 0.1 0.2 0.3 ];
%---
g=9.81;
zlim=5000; ytick=500:500:zlim; 

for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');

    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = ncread(infile1,'QRAIN');  qr=double(qr);   
     qs = ncread(infile1,'QSNOW');  qs=double(qs);    
     qg = ncread(infile1,'QGRAUP'); qg=double(qg);
     qi = ncread(infile1,'QICE');   qi=double(qi);
     qc = ncread(infile1,'QCLOUD'); qc=double(qc);
     hyd1=(qr+qs+qg+qi+qc)*1e3; 

    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     hyd2 = (qr+qs+qg+qi+qc)*1e3; 
    
    %---
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');
    hgt = ncread(infile2,'HGT');
    %----       
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;     

    [nx, ny, ~]=size(ph);
    [y, x]=meshgrid(1:ny,1:nx);
 
%---decide cross section---       
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);       
      Zaxis(:,i)=squeeze(zg(indx,indy,:));  
      hyd1_prof(:,i)=squeeze(hyd1(indx,indy,:));     
      hyd2_prof(:,i)=squeeze(hyd2(indx,indy,:));     
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
    plotvar=hyd2_prof;
    plotvar(Zaxis>zlim)=NaN;
        pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end

    % 
%     plotvar(plotvar<=0)=NaN;
    hf=figure('position',[100 200 900 600]);
    [c, hp]=contourf(xi,Zaxis,plotvar,L2,'linestyle','none'); hold on
%     
%     hc=colorbar; 
%     caxis([301 318]); title(hc,'K')

    contour(xi,Zaxis,hyd1_prof,[0.01 0.1],'r','LineWidth',1.8)

    
    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end   
%     
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'xlim',[xp*1e3 xaxis(end)*1e3],'ylim',[0 zlim-500])
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
    colormap(cmap); title(hc,'g/kg','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end  

%     %    
    outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_z',num2str(zlim)];
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
  end
end