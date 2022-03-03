

% close all
clear;   ccc=':';
%---setting
expri='TWIN025B';  s_date='22';  hr=23;  minu=20; 
%---
xp=25; yp=110;  %start grid
len=75;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
      % fignam=[expri,'_cros-theta_'];
%---
    load('colormap/colormap_br2.mat');   
    cmap=colormap_br2([3 5 7 9 11 13 15 17 19],:);       
    cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%---
g=9.81; Rd=287.04; cpd=1005;  epsilon=0.622; % epsilon=Rd/Rv=Mv/Md

zlim=2500; ytick=1000:1000:zlim; 

%
for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    u.stag = ncread(infile,'U');
    v.stag = ncread(infile,'V');
    w.stag = ncread(infile,'W');
    theta = ncread(infile,'T');  theta=theta+300;
    p = ncread(infile,'P'); pb = ncread(infile,'PB'); P=p+pb;
    %---
    temp  = theta.*(1e5./P).^(-Rd/cpd); %temperature (K)   
    qv = ncread(infile,'QVAPOR');  
    
    Tv=temp.*(1+qv/epsilon)./(1+qv);
    dencity=P./Tv/Rd;
    %---
        qr = double(ncread(infile,'QRAIN'));   
    qc = double(ncread(infile,'QCLOUD'));
    qg = double(ncread(infile,'QGRAUP'));  
    qs = double(ncread(infile,'QSNOW'));
    qi = double(ncread(infile,'QICE'));    
%---
    %  hyd=qr+qc+qg+qs+qi;
%     hyd=qc+qi;
    hyd2d=sum(qr+qc+qg+qs+qi,3);
    [xx,yy]=find(hyd2d == max(hyd2d(:)));   
    yp=yy;


    %---
    hgt = ncread(infile,'HGT');
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;  
    zg=PH/g;     zg0=PH0/g;
    %----   
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
    w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
    
    [nx, ny, nz]=size(u.unstag);
  
    adv1(1,:,:)= -(w.unstag(2,:,:)-w.unstag(nx,:,:))/(2*dx).* u.unstag(1,:,:);
    adv1(nx,:,:)= -(w.unstag(1,:,:)-w.unstag(end-1,:,:))/(2*dx).* u.unstag(end,:,:); 
    adv1(2:nx-1,:,:)= -(w.unstag(3:end,:,:)-w.unstag(1:end-2,:,:))/(2*dx).* u.unstag(2:end-1,:,:);
    
    adv2(:,1,:)= -(w.unstag(:,2,:)-w.unstag(:,ny,:))/(2*dy).* v.unstag(:,1,:);
    adv2(:,ny,:)= -(w.unstag(:,1,:)-w.unstag(:,end-1,:))/(2*dy).* v.unstag(:,end,:); 
    adv2(:,2:ny-1,:)= -(w.unstag(:,3:end,:)-w.unstag(:,1:end-2,:))/(2*dy).* v.unstag(:,2:end-1,:);
    
    adv3= -(w.stag(:,:,2:end)-w.stag(:,:,1:end-1))./(zg0(:,:,2:end)-zg0(:,:,1:end-1)).* w.unstag(:,:,:);
    
    pgrad = -(p(:,:,2:end)-p(:,:,1:end-1)) ./ (zg(:,:,2:end)-zg(:,:,1:end-1)) ./ dencity(:,:,1:end-1);
    
    zg_1D=squeeze(zg0(150,150,:));    nzgi=length(zg_1D)*2-1; 
    zgi0(1:2:nzgi,1)= zg_1D;    zgi0(2:2:nzgi,1)= ( zg_1D(1:end-1) + zg_1D(2:end) )/2;   
    zgi=zgi0(zgi0<zlim);
    
        
    infile2=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,num2str(mi+1,'%2.2d'),ccc,'00'];
    w.stag2 = ncread(infile2,'W');
    w.unstag2=(w.stag2(:,:,1:end-1)+w.stag2(:,:,2:end)).*0.5;

    
    [y, x]=meshgrid(1:ny,1:nx);
%---decide cross section---       
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);       
      Yzg(:,i)=squeeze(zg(indx,indy,:));  
      adv1_prof(:,i)=squeeze(adv1(indx,indy,:));    
      adv2_prof(:,i)=squeeze(adv2(indx,indy,:));    
      adv3_prof(:,i)=squeeze(adv3(indx,indy,:));   
      pgrad_prof(:,i)=squeeze(pgrad(indx,indy,:));  
      dencity_prof(:,i)=squeeze(dencity(indx,indy,:));  
      X=squeeze(zg(indx,indy,:));   Y=squeeze(theta(indx,indy,:));     theta_prof(:,i)=interp1(X,Y,zgi,'linear');
      
      w1_prof(:,i)=interp1(squeeze(zg0(indx,indy,:)),squeeze(w.stag(indx,indy,:)),zgi,'linear');   
      w2_prof(:,i)=interp1(squeeze(zg0(indx,indy,:)),squeeze(w.stag2(indx,indy,:)),zgi,'linear');   

      
      hgtprof(i)=hgt(indx,indy);
    end   
    theta_hm=mean(theta_prof,2,'omitnan');
    theta_ano=theta_prof-repmat(theta_hm,1,size(theta_prof,2));      
       dwdt= (w2_prof-w1_prof)/60;

    
    %---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';    xaxis=linex;  
    else;               xtitle='Y (km)';    xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end    
    %---

    xi=repmat(xaxis*1e3,nz,1);    
    hf=figure('position',[50 55 1300 680]);
     
    for k = 1:6
     ax(k) = subplot(2,3,k);
    end
     colormap(cmap); 
     
    subplot(ax(1)); 
        L1=[-10 -6 -3 -1 1 3 6 10];

    titnam='u adv';
    plotvar=adv1_prof*1e4;    plotvar(Yzg>zlim)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L1(1); L1_2=[pmin,L1]; else; L1_2=[L1(1) L1]; end
    [~, hp1]=contourf(xi,Yzg,plotvar,L1_2,'linestyle','none'); 
    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end        
    set(gca,'fontsize',12,'LineWidth',1.2)
    set(gca,'xlim',[xp*1e3 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)
%     xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
%     text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])
%     xlabel(xtitle); ylabel('Height (km)')
    title(titnam,'fontsize',11)      
    %---colorbar---
    fi=find(L1>pmin,1);
    L=((1:length(L1))*(diff(caxis)/(length(L1)+1)))+min(caxis());
    hc=colorbar('YTick',L,'YTickLabel',L1,'fontsize',12,'LineWidth',1.2);
    title(hc,'10^-^4 m/s^2','fontsize',12);  
        drawnow;
    hFills = hp1.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end          
    %---
    
    subplot(ax(2));   
        L2=[-10 -6 -3 -1 1 3 6 10];

    titnam='v adv';
    plotvar=adv2_prof*1e4;    plotvar(Yzg>zlim)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L2(1); L2_2=[pmin,L2]; else; L2_2=[L2(1) L2]; end
    [~, hp2]=contourf(xi,Yzg,plotvar,L2_2,'linestyle','none'); 
    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end        
    set(gca,'fontsize',12,'LineWidth',1.2)
    set(gca,'xlim',[xp*1e3 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)
%     xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
%     text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])
%     xlabel(xtitle); ylabel('Height (km)')
    title(titnam,'fontsize',11)      
    %---colorbar---
    fi=find(L2>pmin,1);
    L=((1:length(L2))*(diff(caxis)/(length(L2)+1)))+min(caxis());
    hc=colorbar('YTick',L,'YTickLabel',L2,'fontsize',12,'LineWidth',1.2);
    title(hc,'10^-^4 m/s^2','fontsize',10);  
        drawnow;
    hFills = hp2.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end          
    %---
    
    
    subplot(ax(3));  
        L3=[-4 -3 -2 -1 1 2 3 4];

    titnam='w adv';
    plotvar=adv3_prof*1e4;    plotvar(Yzg>zlim)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L3(1); L3_2=[pmin,L3]; else; L3_2=[L3(1) L3]; end
    [~, hp3]=contourf(xi,Yzg,plotvar,L3_2,'linestyle','none'); 
    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end        
    set(gca,'fontsize',12,'LineWidth',1.2)
    set(gca,'xlim',[xp*1e3 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)
%     xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
%     text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])
%     xlabel(xtitle); ylabel('Height (km)')
    title(titnam,'fontsize',11)      
    %---colorbar---
    fi=find(L3>pmin,1);
    L=((1:length(L3))*(diff(caxis)/(length(L3)+1)))+min(caxis());
    hc=colorbar('YTick',L,'YTickLabel',L3,'fontsize',12,'LineWidth',1.2);
    title(hc,'10^-^4 m/s^2','fontsize',10);  
    drawnow;
    hFills = hp3.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end          
    %---

    
    subplot(ax(4));   
    L4=[0.07 0.08 0.09 0.1 0.12 0.13 0.14 0.15];
                     
        cmap=summer(9);       
    cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;

    titnam='p grad';
    plotvar=pgrad_prof;    plotvar(Yzg(1:end-1,:)>zlim)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L4(1); L4_2=[pmin,L4]; else; L4_2=[L4(1) L4]; end
    [~, hp4]=contourf(xi(1:end-1,:),Yzg(1:end-1,:),plotvar,L4_2,'linestyle','none'); 
    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end        
    set(gca,'fontsize',12,'LineWidth',1.2)
    set(gca,'xlim',[xp*1e3 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)
%     xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
%     text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])
%     xlabel(xtitle); ylabel('Height (km)')
    title(titnam,'fontsize',11)      
    %---colorbar---
    fi=find(L4>pmin,1);
    L=((1:length(L4))*(diff(caxis)/(length(L4)+1)))+min(caxis());
    hc=colorbar('YTick',L,'YTickLabel',L4,'fontsize',12,'LineWidth',1.2);
     colormap(ax(4),summer(9));   
%     title(hc,'10^-^4 m/s^2','fontsize',10); 
    drawnow;
    hFills = hp4.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end          
    %---
%
    subplot(ax(5));   
    L5=[-0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04];
%                      
    cmap=colormap_br2([3 5 7 9 11 13 15 17 19],:);       
    cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;

    [xi2, zi2]=meshgrid(xaxis*1e3,zgi);

    titnam='B';
    plotvar=theta_ano./repmat(theta_hm,1,size(theta_prof,2))*g;   
    pmin=double(min(min(plotvar)));   if pmin<L5(1); L5_2=[pmin,L5]; else; L5_2=[L5(1) L5]; end
    [~, hp5]=contourf(xi2,zi2,plotvar,L5_2,'linestyle','none'); 
    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end        
    set(gca,'fontsize',12,'LineWidth',1.2)
    set(gca,'xlim',[xp*1e3 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)
%     xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
%     text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])
%     xlabel(xtitle); ylabel('Height (km)')
    title(titnam,'fontsize',11)      
    %---colorbar---
    fi=find(L5>pmin,1);
    L=((1:length(L5))*(diff(caxis)/(length(L5)+1)))+min(caxis());
    hc=colorbar('YTick',L,'YTickLabel',L5,'fontsize',12,'LineWidth',1.2); 
%     title(hc,'10^-^4 m/s^2','fontsize',10); 
    drawnow;
    hFills = hp5.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end          
    %---
    
  
    subplot(ax(6));   
    L6=[-20 -15 -10 -5 5 10 15 20];
%                      
%     cmap=colormap_br2([3 5 7 9 11 13 15 17 19],:);       
%     cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;

%     [xi2, zi2]=meshgrid(xaxis*1e3,zgi);

    titnam='dwdt';
    plotvar=dwdt*1e4;   
    pmin=double(min(min(plotvar)));   if pmin<L6(1); L6_2=[pmin,L6]; else; L6_2=[L6(1) L6]; end
    [~, hp6]=contourf(xi2,zi2,plotvar,L6_2,'linestyle','none'); 
    %---terrain---
    if (max(max(hgtprof))~=0)
     hold on; plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.8)
    end        
    set(ax(6),'fontsize',12,'LineWidth',1.2)
    set(ax(6),'xlim',[xp*1e3 xaxis(end)*1e3],'ylim',[0 zlim-500])
    set(ax(6),'Xticklabel',get(gca,'Xtick')*grids*1e-3,'Ytick',ytick,'Yticklabel',ytick*1e-3)
%     xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
%     text(xlim(2)-30000,ylim(1)-350,['xp=',num2str(xp),', yp=',num2str(yp)])
%     xlabel(xtitle); ylabel('Height (km)')
    title(titnam,'fontsize',11)      
    %---colorbar---
    fi=find(L6>pmin,1);
    L=((1:length(L6))*(diff(caxis)/(length(L6)+1)))+min(caxis());
    hc=colorbar('YTick',L,'YTickLabel',L6,'fontsize',12,'LineWidth',1.2); 
    title(hc,'10^-^4 m/s^2','fontsize',10); 
    drawnow;
    hFills = hp6.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end          
    %---

%}
    
    s_hrj=num2str(mod(ti+9,24),'%.2d');
    sgtitle([expri,'  ',s_hrj,s_min,' LT'],'fontsize',20) 
  end
end
