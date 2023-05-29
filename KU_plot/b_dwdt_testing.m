

% close all
clear;   ccc=':';
%---setting
expri='TWIN024';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='22';  hr=23;  minu=[31]; 

%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri2]; outdir=['/mnt/e/figures/expri_twin/',expri2(1:7)];
      % fignam=[expri,'_cros-theta_'];
%---
    load('colormap/colormap_br2.mat');   
    cmap=colormap_br2([3 5 7 9 11 13 15 17 19],:);       
    cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%---
g=9.81; Rd=287.04; cpd=1005;  epsilon=0.622; % epsilon=Rd/Rv=Mv/Md

zlim=4000; ytick=1000:1000:zlim; 

%
for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     dx=ncreadatt(infile,'/','DX') ;    dy=ncreadatt(infile,'/','DY') ; 
     hgt = ncread(infile,'HGT');
     ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    u.stag = ncread(infile,'U');
    v.stag = ncread(infile,'V');
    w.stag = ncread(infile,'W');
    theta = ncread(infile,'T');  theta=theta+300;
    p = ncread(infile,'P'); pb = ncread(infile,'PB'); P=p+pb;
    qv = ncread(infile,'QVAPOR');        
    %---  
    qr = double(ncread(infile,'QRAIN'));   
    qc = double(ncread(infile,'QCLOUD'));
    qg = double(ncread(infile,'QGRAUP'));  
    qs = double(ncread(infile,'QSNOW'));
    qi = double(ncread(infile,'QICE'));     
%     hyd=qr+qc+qg+qs+qi;
    hyd=qc+qi;
    hyd2d=sum(qr+qc+qg+qs+qi,3);
%     hyd(hyd+1<=1)=nan;

infile1=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qr = double(ncread(infile1,'QRAIN'));   
    qc = double(ncread(infile1,'QCLOUD'));
    qg = double(ncread(infile1,'QGRAUP'));  
    qs = double(ncread(infile1,'QSNOW'));
    qi = double(ncread(infile1,'QICE'));     
%     hyd1=qr+qc+qg+qs+qi;
    hyd1=qc+qi;
         ph1 = ncread(infile1,'PH'); phb1 = ncread(infile1,'PHB');
    PH0=double(phb1+ph1);    PH1=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;  
    zg1=PH1/g;   


    %---
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;  
    zg=PH/g;     zg0=PH0/g;
    %----   
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
    w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
    
    [nx, ny, nz]=size(u.unstag);
    
    temp  = theta.*(1e5./P).^(-Rd/cpd); %temperature (K)   
    Tv=temp.*(1+qv/epsilon)./(1+qv);
    dencity=P./Tv/Rd;
  
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
%     zgi=zgi0(zgi0<zlim);
    zgi=zgi0;
    
    [xx,yy]=find(hyd2d == max(hyd2d(:)));   
    yp=yy;

    
    for i=1:nx
      for j=1:ny     
        den_iso(i,j,:)=interp1(squeeze(zg(i,j,:)),squeeze(dencity(i,j,:)),zgi,'linear'); 
      end
    end  
    rho_bar=mean(mean(den_iso,1,'omitnan'),2,'omitnan');
    rho_p=den_iso-repmat(rho_bar,nx,ny,1);
    rho_p_g=rho_p*g;
    
    zgi3(1,1,:)=zgi;
    
    rho_p_g_z= (rho_p_g(:,:,2:end)-rho_p_g(:,:,1:end-1)) ./ repmat((zgi3(2:end)- zgi3(1:end-1)),nx,ny,1 );
    
    p_b=ones(nx,ny,length(zgi)); 
    
%     F = dy^2/(2*(dx^2+dy^2))*(p_b(3:end,2:end-1)+p_b(1:end-2,2:end-1)) + dx^2/(2*(dx^2+dy^2))*(p_b(:,3:end)+p_b(:,1:end-2))  
   
    
    
%    for i=1:nx
%       den_prof(:,i)=interp1(squeeze(zg(i,100,:)),squeeze(dencity(i,100,:)),zgi,'linear');           
%    end
    
    
  
    
    %---
    xi=repmat(1:nx,nz,1);    
%     [xi2, zi2]=meshgrid(1:nx,zgi);
%%     
%     hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi2,zi2,squeeze(B(:,100,:))',20,'linestyle','none'); colorbar; caxis([-0.04 0.04])
% %     
%     hf=figure('position',[45 60 800 680]);
%    [~, hp]=contourf(squeeze(B(:,:,13))',20,'linestyle','none'); colorbar; caxis([-0.04 0.04])
    
%    
%    hf=figure('position',[45 60 800 680]);
%    [~, hp]=contourf(squeeze(adv1(1:150,25:175,22))'*1e4,20,'linestyle','none'); colorbar; caxis([-10 10])
% 
%    hf=figure('position',[45 60 800 680]);
%    [~, hp]=contourf(squeeze(adv2(1:150,25:175,22))'*1e4,20,'linestyle','none'); colorbar; caxis([-10 10])
%    
%       hf=figure('position',[45 60 800 680]);
%    [~, hp]=contourf(squeeze(pgrad(1:150,25:175,22))'*1e4,20,'linestyle','none'); colorbar; caxis([-10 10])

%    
% diffhyd=(hyd1-hyd)*1e3;
% % diffhyd(diffhyd==0)=NaN;
%     hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi,squeeze(zg(:,yp,:))',squeeze(diffhyd(:,yp,:))',20,'linestyle','none'); colorbar; caxis([-0.4 0.4])  
%     hold on
%     contour(xi,squeeze(zg(:,yp,:))',squeeze(hyd(:,yp,:))'*1e3,[0.01 0.01],'w','linewidth',2.5)
%     contour(xi,squeeze(zg1(:,yp,:))',squeeze(hyd1(:,yp,:))'*1e3,[0.01 0.01],'r','linewidth',2.5,'linestyle','--')
%     set(gca,'xlim',[10 150],'Ylim',[0 2000])

  end
end
