
% close all
clear;   ccc=':';
saveid=0; % save figure (1) or not (0)

%---setting
expri='TWIN031B';  day=22;  hr=21;  minu=[0 10 20 30 40];  
%---
maxid=0; %0: define by <xp>, <yp>; 1: max of hyd; 2: max of w
xp=1; yp=161;  %start grid
len=150;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='Theta anomaly';   fignam=[expri,'_cros-theta-anomaly_'];
%---
LFC_indir='/mnt/HDDA/Python_script/LFC_data';
%---
    load('colormap/colormap_br3.mat'); 
    cmap=colormap_br3([3:12,14],:);
    cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
    L=[-2 -1.5 -1 -0.5 -0.1   0.1 0.5 1 1.5 2];
%----
g=9.81;
zlim=15000; ytick=1000:2000:zlim; 
% zlim=5000; ytick=500:500:zlim; 

for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    clear zgi u v w theta_prof  hyd_prof

    LFC_infile=[LFC_indir,'/',expri,'_',mon,s_date,'_',s_hr,s_min,'_LFC.npy'];
    LFC=readNPY(LFC_infile);
%     LCL_infile=[LFC_indir,'/',expri,'_',mon,s_date,'_',s_hr,s_min,'_LCL.npy'];
%     LCL=readNPY(LCL_infile);
%       
    %---wrf file---
    
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
        dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    %---
     qr = double(ncread(infile,'QRAIN'));   
     qc = double(ncread(infile,'QCLOUD'));
     qg = double(ncread(infile,'QGRAUP'));  
     qs = double(ncread(infile,'QSNOW'));
     qi = double(ncread(infile,'QICE'));    
     hyd=qr+qc+qg+qs+qi;          
    %---
    u.stag = ncread(infile,'U');
    v.stag = ncread(infile,'V');
    w.stag = ncread(infile,'W');
    theta = ncread(infile,'T');  theta=theta+300;
    %---
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    hgt = ncread(infile,'HGT');
    %----   
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
%     v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
    w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
    
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g; 
    zg0=PH0/g;
    
    zg_1D=squeeze(zg0(150,150,:));     
    nz=length(zg_1D); nzgi=nz*2-1;  zgi0=zeros(nzgi,1);
    zgi0(1:2:nzgi,1)= zg_1D;  zgi0(2:2:nzgi,1)= ( zg_1D(1:end-1) + zg_1D(2:end) )/2;   
    zgi=zgi0(zgi0<zlim);

    [nx,ny,nz]=size(theta);
    if maxid==1      
      A=sum(hyd,3);     [xx,yy]=find(A == max(A(:)));   
      if slopx>=slopy; yp=yy; else;  xp=xx; end
    elseif maxid==2
      A=w.unstag;     [xx,yy,zz]= ind2sub([nx,ny,nz],find(A == max(A(:))));   
      if slopx>=slopy; yp=yy; else;  xp=xx; end
    end 
    
%     [nx, ny, ~]=size(ph);
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
      Y=squeeze(w.unstag(indx,indy,:));     w.prof(:,i)=interp1(X,Y,zgi,'linear');
      Y=squeeze(theta(indx,indy,:));     theta_prof(:,i)=interp1(X,Y,zgi,'linear');
      Y=squeeze(hyd(indx,indy,:));    hyd_prof(:,i)=interp1(X,Y,zgi,'linear');
      hgtprof(i)=hgt(indx,indy);
      LFCprof(i)=LFC(indy,indx)+hgt(indx,indy);
%       LCLprof(i)=LCL(indy,indx)+hgt(indx,indy);
    end    
    
    theta_hm=mean(theta_prof,2,'omitnan');
    theta_ano=theta_prof-repmat(theta_hm,1,size(theta_prof,2));    


%---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';    xaxis=linex;  
    else;               xtitle='Y (km)';    xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end
    
    %---plot---   
    [xi, zi]=meshgrid(xaxis*1e3,zgi);
    pmin=double(min(min(theta_ano)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 200 900 600]);
    [~, hp]=contourf(xi,zi,theta_ano,L2,'linestyle','none');
    hold on
        
    %---theta---
    [c,hdis]= contour(xi,zi,theta_prof,298:4:360,'color',[0.6 0.6 0.6],'linewidth',2.2); 
    clabel(c,hdis,hdis.TextList,'fontsize',14,'color',[0.6 0.6 0.6],'LabelSpacing',500)   
    
    LFC_h=LFC+hgt';
%     LCL_h=LCL+hgt';
% 
%     plot(xaxis(end)*1e3-10,LFCprof(end),'sk','markersize',10,'markerfacecolor','k')
%     plot(xaxis(end)*1e3-10,LCLprof(end),'^k','markersize',10,'markerfacecolor','k')
% 
    plot(xaxis*1e3,LFCprof,'color',[0.05 0.5 0.1],'LineWidth',2.5,'linestyle','--')
%     plot(xaxis*1e3,LCLprof,'color',[0.3 0.8 0.1],'LineWidth',2.5,'linestyle','--')        
%     contour(xi2,zi2,theda_lapse,[0 0],'color',[0.9 0.5 1],'linewidth',2.5,'linestyle','--'); 

    %---updraft---
%     [c,hdis]= contour(xi,zi,w.prof,[0.1  2],'color',[0.95 0.1 0.05],'linewidth',2); 
%     clabel(c,hdis,hdis.TextList,'fontsize',10,'color',[0.95 0.1 0.05],'LabelSpacing',500) 

    %---hydrometeor---
    [c,hdis]= contour(xi,zi,hyd_prof*1e3,[0.1 0.1],'color',[0.05 0.1 0.95],'linewidth',2); 
    clabel(c,hdis,hdis.TextList,'fontsize',10,'color',[0.05 0.1 0.95],'LabelSpacing',500) 

    %
    if (max(max(hgtprof))~=0)
     plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.5)
    end   
            %---wind vector----
    intu=4000;  intw=1;        
    [xi2, zi2]=meshgrid(1:intu:xaxis(end)*1e3,zgi(1:intw:end));
    w.plot= w.prof(1:intw:end,1:intu/1000:end);  
    u.plot=u.prof(1:intw:end,1:intu/1000:end);
    h1 = quiver(xi2,zi2,u.plot,w.plot,1,'k','MaxHeadSize',0.002) ; % the '0' turns off auto-scaling
   
    set(gca,'fontsize',16,'LineWidth',1.2,'box','on')
    set(gca,'Xticklabel',get(gca,'Xtick')*grids/dx,'Ytick',ytick,'Yticklabel',ytick./1000)

    xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
    text(xlim(2)-30,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])

    xlabel(xtitle); ylabel('Height (km)')
    s_hrj=num2str(mod(ti+9,24),'%.2d');
    tit=[expri,'  ',titnam,'  ',mon,s_date,'  ',s_hrj,s_min,' LT'];     
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
    %---
    outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_z',num2str(zlim)];
    if saveid~=0
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
% }
 
  end
end
