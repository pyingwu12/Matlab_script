

close all
clear;   ccc='-';
saveid=1; % save figure (1) or not (0)

%---setting
% expri='TWIN013B';   day=22;  hr=23;  minu=40;    qscale=800; xp=26; yp=102;
% expri='TWIN020B';   day=22;  hr=23;  minu=10;    qscale=800; xp=26; yp=102;
% expri='TWIN021B';   day=22;  hr=23;  minu=20;    qscale=800; xp=26; yp=100;
expri='TWIN003B';   day=22;  hr=23;  minu=10;    qscale=800;  xp=26; yp=102;

% expri='TWIN017B';   day=22;  hr=23;  minu=[20 ];    qscale=800;  xp=26; yp=102;

% expri='TWIN031B';   day=22;  hr=23;  minu=30;    qscale=400; xp=1; yp=156;
% expri='TWIN043B';   day=22;  hr=23;  minu=[00];    qscale=400;
% expri='TWIN040B';   day=22;  hr=23;  minu=[40];   qscale=300;

%---
maxid=0; %0: define by <xp>, <yp>; 1: max of hyd; 2: max of w
  %start grid
len=100;   %length of the line (grid)

% xp=1; yp=152;  %start grid
% len=100;   %length of the line (grid)

slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
% indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/JAS_R2'];
indir=['D:expri_twin/',expri]; 
outdir='JAS_R2';
titnam='\theta anomaly';   fignam=[expri,'_cros-theta-anomaly_'];
%---
% LFC_indir='/mnt/HDDA/Python_script/LFC_data';
LFC_indir='LFC_data/';
%---
load('colormap/colormap_br3.mat'); 
cmap=colormap_br3([8 9 10 11 12],:);   
cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[0 0.5 1 1.5];
%----
g=9.81;
zlim=3200; ytick=500:500:zlim; 
% zlim=7000; ytick=1000:1000:zlim; 

for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    clear zgi u v w theta_prof  hyd_prof
    %---wrf file---    
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
    hgt = ncread(infile,'HGT');
    %---
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');  
    PH0=double(phb+ph);   zg0=double(PH0)/g;
    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;    
    %-
    nzgi=length(zg0(150,150,2:end))*2-1; 
    zgi=zeros(nzgi,1);
    zgi(1:2:nzgi,1)= zg0(150,150,2:end); 
    zgi(2:2:nzgi,1)= ( zg0(150,150,2:end-1) + zg0(150,150,3:end) )/2;   
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
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
%     v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
    w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
    %---
    theta = ncread(infile,'T');  theta=theta+300;
    %---
    LFC_infile=[LFC_indir,'/',expri,'_',mon,s_date,'_',s_hr,s_min,'_LFC.npy'];
    LFC=readNPY(LFC_infile);
    %---   
    [nx,ny,nz]=size(theta);
    if maxid==1      
      A=sum(hyd,3);     [xx,yy]=find(A == max(A(:)));   
      if slopx>=slopy; yp=yy; else;  xp=xx; end
    elseif maxid==2
      A=w.unstag;     [xx,yy,zz]= ind2sub([nx,ny,nz],find(A == max(A(:))));   
      if slopx>=slopy; yp=yy; else;  xp=xx; end
    end     
    

%---interpoltion---
    for i=1:nx
      for j=1:ny          
        X=squeeze(zg(i,j,:));       
        Y=squeeze(theta(i,j,:));   theta_iso(i,j,:)=interp1(X,Y,zgi,'linear');
      end
    end      
    theta_mean=mean(theta_iso,[1 2],'omitnan');
    theta_ano=theta_iso-repmat(theta_mean,nx,ny);            


    [y, x]=meshgrid(1:ny,1:nx);       
    i=0;  lonB=0; latB=0;
    while lonB<x(xp,yp)+len && latB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  lonB=linex(i);     
      liney(i)=y(indx,indy);  latB=liney(i);  
      %---interpolation to isohypsic surface for theta
      X=squeeze(zg(indx,indy,:));       
%       Y=squeeze(theta(indx,indy,:));     theta_iso(:,i)=interp1(X,Y,zgi,'linear');
      %---other variables
      Zaxis(:,i)=squeeze(zg(indx,indy,:));  
      w.prof(:,i)=squeeze(w.unstag(indx,indy,:));
      u.prof(:,i)=squeeze(u.unstag(indx,indy,:));
%       v.prof(:,i)=squeeze(v.unstag(indx,indy,:));
      hyd_prof(:,i)=squeeze(hyd(indx,indy,:));
      theta_prof(:,i)=squeeze(theta(indx,indy,:));    
      
      theta_nao_prof(:,i)=squeeze(theta_ano(indx,indy,:));
      

      hgtprof(i)=hgt(indx,indy);
      LFCprof(i)=LFC(indy,indx)+hgt(indx,indy);      
    end    

    theta_lapse=(theta_prof(1:end-1,:)-theta_prof(2:end,:)) ./ (Zaxis(1:end-1,:)-Zaxis(2:end,:)); 


%---plot setting---   
    if slopx>=slopy;    xtitle='X (km)';    xaxis=linex;  
    else;               xtitle='Y (km)';    xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end
    
    %---axis   
    xi=repmat(xaxis*1e3,size(Zaxis,1),1);    
    %for lapse rate
    Zaxis2 = (Zaxis(1:end-1,:)+Zaxis(2:end,:))/2;
    xi2=repmat(xaxis*1e3,size(Zaxis2,1),1);
    %for theta anamoly (iso)
    [xi_iso, zi_iso]=meshgrid(xaxis*1e3,zgi);
    %for wind vector
%     in3tu=4000;  intw=1;
    intu=3000;  intw=1;
    zi_vec=Zaxis(1:intw:end, 1:intu/1000:end);
    xi_vec=repmat( (xaxis(1):intu/1000:xaxis(end))*1e3, size(zi_vec,1),1);

    %%
    %---plot---    
    pmin=double(min(min(theta_nao_prof)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    hf=figure('position',[100 200 1200 800]);
    [~, hp]=contourf(xi_iso,zi_iso,theta_nao_prof,L2,'linestyle','none');    hold on
 
     %---theta---
    [c,hdis]= contour(xi,Zaxis,theta_prof,298:2:360,'color',[0.55 0.55 0.55],'linewidth',2.2); 
    clabel(c,hdis,hdis.TextList,'fontsize',18,'color',[0.55 0.55 0.55],'LabelSpacing',600)   

%---w contour -- for JAS_R2
contour(xi,Zaxis,w.prof,[0.5 0.5],'color',[0.8 0.1 0.4],'linewidth',3.5,'linestyle','-.'); 
%---

    %---theta lapse rate
   [c,hdis]=  contour(xi2,Zaxis2,theta_lapse,[0 0],'color',[0.2 0.6 0.1],'linewidth',3,'linestyle','-'); 
%    clabel(c,hdis,hdis.TextList,'fontsize',18,'color',[0.1 0.6 0],'LabelSpacing',650)

    %---LFC
    plot(xaxis*1e3,LFCprof,'color',[0.5 0.28 0.85],'linewidth',3,'LineStyle','-')

    %---hydrometeor---
    [c,hdis]= contour(xi,Zaxis,hyd_prof*1e3,[0.1 0.1],'color',[0.05 0.1 0.9],'linewidth',4); 
%     clabel(c,hdis,hdis.TextList,'fontsize',15,'color',[0.05 0.3 0.8],'LabelSpacing',500) 

        %---wind vector----
    w.vec= w.prof(1:intw:end,1:intu/1000:end);  
    u.vec= u.prof(1:intw:end,1:intu/1000:end);    
    h1 = quiver(xi_vec,zi_vec,u.vec,w.vec,0,'color',[0.28 0 0],'MaxHeadSize',0.002) ; % the '0' turns off auto-scaling
    hU1 = get(h1,'UData');   hV1 = get(h1,'VData') ;

     windlegend=5;    
    h2 = quiver((xp+xp+len-5)/2*1000,350,windlegend,0,0,'color',[0.9 0 0],'MaxHeadSize',0.2) ; % the '0' turns off auto-scaling
    hU2 = get(h2,'UData');   hV2 = get(h2,'VData') ;
% %     text((xp+xp+len-5)/2*1000,200,[num2str(windlegend),' m s^-^1'],'color',[0.9 0 0],'fontsize',16)
     windlegend=0.5;    
    h3 = quiver((xp+xp+len-5)/2*1000,500,0,windlegend,0,'color',[0.9 0 0],'MaxHeadSize',0.2) ; % the '0' turns off auto-scaling
    hU3 = get(h3,'UData');   hV3 = get(h3,'VData') ;
% %     text((xp+xp+len-5)/2*1000,200,[num2str(windlegend),' m s^-^1'],'color',[0.9 0 0],'fontsize',16)
%----for U25--- 
%    windlegend=10;    
%    h2 = quiver(50*1000,400,windlegend,0,0,'color',[0.9 0 0],'MaxHeadSize',0.2) ; % the '0' turns off auto-scaling
%    hU2 = get(h2,'UData');   hV2 = get(h2,'VData') ;
%    text(50*1000,250,[num2str(windlegend),' m s^-^1'],'color',[0.9 0 0],'fontsize',16)   

    set(h1,'UData',qscale*hU1,'VData',qscale*hV1*0.45,'LineWidth',1.3);  
    set(h2,'UData',qscale*hU2,'VData',qscale*hV2*0.45,'LineWidth',1.3);  
    set(h3,'UData',qscale*hU3,'VData',qscale*hV3*0.45,'LineWidth',1.3);  
    
     %---terrain
    if (max(max(hgtprof))~=0)
     plot(xaxis*1e3,hgtprof,'color',[0.2 0.2 0.2],'LineWidth',1.5)
    end  
    
    set(gca,'fontsize',20,'LineWidth',1.2,'box','on')
    set(gca,'Ylim',[1 zlim],'Xlim',[xp xp+len]*1e3)
%       set(gca,'Ylim',[1 zlim],'Xlim',[20 120]*1e3)
    set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'Xtick',(10:10:140)*1000,'Xticklabel',10:10:140)

    %%
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',18,'LineWidth',1.2);
    colormap(cmap); title(hc,'K','fontsize',16);  %drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end     
    %%
    xlim=get(gca,'Xlim');  ylim=get(gca,'Ylim');
    text(xlim(2)-10000,ylim(1)-ylim(2)/12,['xp=',num2str(xp),', yp=',num2str(yp)])

    xlabel(xtitle); ylabel('Height (km)')
    s_hrj=num2str(mod(ti+9,24),'%.2d');
    tit=[expri,'  ',titnam,'  ',mon,s_date,'  ',s_hrj,s_min,' LT'];     
    title(tit,'fontsize',25)        
    %%
    %---    
    outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope),'_z',num2str(zlim)];
    if saveid~=0
    print(hf,'-dpng',[outfile,'.png']) 
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
%}
 
  end
end