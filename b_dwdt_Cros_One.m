
% close all
clear;   ccc=':';
%---setting
expri='TWIN024';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='22';  hr=22;  minu=40; 
%---
xp=25; yp=106;  %start grid
len=75;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/';  outdir=['/mnt/e/figures/expri_twin/',expri2(1:7)];
titnam=[expri2,'  dwdt'];   fignam=[expri2,'_cros-dwdt_'];
%---
g=9.81; 
Rd=287.04; cpd=1005;  epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
p0=100000;
%---
zlim=4000;  % using model level height, but only below <zlim>, to interpolate
ytick=1000:1000:zlim; 

% zgi=10:500:5000;

%---
for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
      s_min=num2str(mi,'%2.2d');
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  
    hgt=ncread(infile2,'HGT');
    
     ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');     
     PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   
     %---creat 1-D zgi for interpolation---
     zg0=PH0/g;
     zg_1D=squeeze(zg0(150,150,:));   % nzgi=length(zg_1D)*2-1; 
%     zgi0(1:2:nzgi,1)= zg_1D;  zgi0(2:2:nzgi,1)= ( zg_1D(1:end-1) + zg_1D(2:end) )/2;
     zgi=zg_1D(zg_1D<zlim);
    %----  
%      w.stag = ncread(infile2,'W');     w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
     theta2 = ncread(infile2,'T');  theta2=theta2+300;
     p = ncread(infile2,'P'); pb = ncread(infile2,'PB'); P2=p+pb;
     qv2 = ncread(infile2,'QVAPOR');             
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE'));    
     hyd2=qr+qc+qg+qs+qi;   
     
    %---
    zg2=PH/g;        
    %---
    theta_rho2=theta2 .* (1+qv2/epsilon) ./ (1+qv2+hyd2) ;
    %
    Pi2= (P2/p0).^(Rd/cpd) ;
    %---
    temp2  = theta2.*(1e5./P2).^(-Rd/cpd); %temperature (K)   
    Tv2=temp2.*(1+qv2/epsilon)./(1+qv2);
    rho2=P2./Tv2/Rd;  
  %------===================================================================================
        %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      
     PH0=double(ncread(infile1,'PHB')+ncread(infile1,'PH'));  
     PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   
    %----  
%      w.stag = ncread(infile2,'W');     w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
     theta1 = ncread(infile1,'T')+300; 
     p = ncread(infile1,'P'); pb = ncread(infile1,'PB');  P1=p+pb;
     qv1 = ncread(infile1,'QVAPOR');             
     qr = double(ncread(infile1,'QRAIN'));   
     qc = double(ncread(infile1,'QCLOUD'));
     qg = double(ncread(infile1,'QGRAUP'));  
     qs = double(ncread(infile1,'QSNOW'));
     qi = double(ncread(infile1,'QICE'));    
     hyd1=qr+qc+qg+qs+qi;   
     
    %---
    zg1=PH/g;        
    %---
    theta_rho1=theta1 .* (1+qv1/epsilon) ./ (1+qv1+hyd1) ;
    %
    Pi1= (P1/p0).^(Rd/cpd) ;
    %---
    temp1  = theta1.*(1e5./P1).^(-Rd/cpd); %temperature (K)   
    Tv1=temp1.*(1+qv1/epsilon)./(1+qv1);
    rho1=P1./Tv2/Rd;   

          %------===================================================================================
%
    [nx, ny, nz]=size(theta2);
     %--
     for i=1:nx
      for j=1:ny     
        theta_rho_iso2(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(theta_rho2(i,j,:)),zgi,'linear'); 
        Pi_iso2(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(Pi2(i,j,:)),zgi,'linear'); 
        rho_iso2(i,j,:)=interp1(squeeze(zg2(i,j,:)),squeeze(rho2(i,j,:)),zgi,'linear');
        
        
        theta_rho_iso1(i,j,:)=interp1(squeeze(zg1(i,j,:)),squeeze(theta_rho1(i,j,:)),zgi,'linear'); 
        Pi_iso1(i,j,:)=interp1(squeeze(zg1(i,j,:)),squeeze(Pi1(i,j,:)),zgi,'linear'); 
        rho_iso1(i,j,:)=interp1(squeeze(zg1(i,j,:)),squeeze(rho1(i,j,:)),zgi,'linear');
        
      end
     end  
   theta_rho_bar2=mean(theta_rho_iso2,[1,2],'omitnan');
   theta_rho_p2=theta_rho_iso2-repmat(theta_rho_bar2,nx,ny,1);
   B2=theta_rho_p2./theta_rho_bar2*g;
     
   Pi_bar2=mean(Pi_iso2,[1,2],'omitnan');
   Pi_p2=Pi_iso2-repmat(Pi_bar2,nx,ny,1);
   pi_diff2= (Pi_p2(:,:,2:end)-Pi_p2(:,:,1:end-1))...
       ./repmat(reshape((zgi(2:end)-zgi(1:end-1)),1,1,length(zgi)-1),nx,ny,1);
   p_grad2 = -cpd * theta_rho_iso2(:,:,1:end-1) .*  pi_diff2;
   
%----------
   theta_rho_bar1=mean(theta_rho_iso1,[1,2],'omitnan');
   theta_rho_p1=theta_rho_iso1-repmat(theta_rho_bar1,nx,ny,1);
   B1=theta_rho_p1./theta_rho_bar1*g;
     
   Pi_bar1=mean(Pi_iso1,[1,2],'omitnan');
   Pi_p1=Pi_iso1-repmat(Pi_bar1,nx,ny,1);
   pi_diff1= (Pi_p1(:,:,2:end)-Pi_p1(:,:,1:end-1))...
       ./repmat(reshape((zgi(2:end)-zgi(1:end-1)),1,1,length(zgi)-1),nx,ny,1);
   p_grad1 = -cpd * theta_rho_iso1(:,:,1:end-1) .*  pi_diff1;
   %%
   %---  
   [xi, zi]=meshgrid(1:nx,zgi);
% %
%    hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi,zi,squeeze(B1(:,yp,:))',20,'linestyle','none');
%     colorbar;% caxis([-0.025 0.06])
%         set(gca,'xlim',[1 150],'Ylim',[0 zlim-500])
%     xlabel('x (km)'); ylabel('Height (km)')    
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[expri2,'  B1  ',mon,s_datej,'  ',s_hrj,s_min,' LT'];     
%     title(tit,'fontsize',18) 
%     %---
%        hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi,zi,squeeze(B2(:,yp,:))',20,'linestyle','none');
%     colorbar;% caxis([-0.025 0.06])
%         set(gca,'xlim',[1 150],'Ylim',[0 zlim-500])
%     xlabel('x (km)'); ylabel('Height (km)')    
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[expri2,'  B2  ',mon,s_datej,'  ',s_hrj,s_min,' LT'];     
%     title(tit,'fontsize',18) 
    
    %%
%            hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi,zi,squeeze(B1(:,yp,:)-B2(:,yp,:))',20,'linestyle','none');
%     colorbar;
%     caxis([-0.003 0.003])
%         set(gca,'xlim',[1 150],'Ylim',[0 zlim-500])
%     xlabel('x (km)'); ylabel('Height (km)')    
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[expri2,'  B1-B2  ',mon,s_datej,'  ',s_hrj,s_min,' LT'];     
%     title(tit,'fontsize',18) 
    %%
%     %---
%     B_p=p_grad+B(:,:,1:end-1);
%     
%     [xi2, zi2]=meshgrid(1:nx,zgi(1:end-1));
% %     %
%     hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi2,zi2,squeeze(p_grad2(:,yp,:))',20,'linestyle','none');
% % %      [~, hp]=contourf(xi,zi,squeeze(P_p(:,yp,:))',20,'linestyle','none');
% % %     [~, hp]=contourf(xi2,zi2,squeeze(B_p(:,yp,:))',20,'linestyle','none');
% %     
%     colorbar;% caxis([-0.025 0.06])
%         set(gca,'xlim',[1 150])
%     xlabel('x (km)'); ylabel('Height (km)')
% %     
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[expri2,'  p_grad  ',mon,s_datej,'  ',s_hrj,s_min,' LT'];     
%     title(tit,'fontsize',18,'Interpreter','none')    

    %%
%        hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi2,zi2,squeeze(p_grad1(:,yp,:))',20,'linestyle','none');
% % %      [~, hp]=contourf(xi,zi,squeeze(P_p(:,yp,:))',20,'linestyle','none');
%     [~, hp]=contourf(xi2,zi2,squeeze(B_p(:,yp,:))',20,'linestyle','none');
%     
%     colorbar;% caxis([-0.025 0.06])
%         set(gca,'xlim',[1 150])
%     xlabel('x (km)'); ylabel('Height (km)')
%     
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[expri2,'  B+p_grad  ',mon,s_datej,'  ',s_hrj,s_min,' LT'];     
%     title(tit,'fontsize',18,'Interpreter','none')    
     %}
     %%
%     [xi2, zi2]=meshgrid(1:nx,zgi(1:end-1));
%     %
%     hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi2,zi2,squeeze(p_grad1(:,yp,:)-p_grad2(:,yp,:))',20,'linestyle','none');
% %     
%     colorbar; caxis([-0.003 0.0035])
%         set(gca,'xlim',[1 150])
%     xlabel('x (km)'); ylabel('Height (km)')
% %     
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[expri2,'  p_grad diff  ',mon,s_datej,'  ',s_hrj,s_min,' LT'];     
%     title(tit,'fontsize',18,'Interpreter','none')    
  end
end
