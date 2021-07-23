
% close all
clear;   ccc=':';
%---setting
expri='TWIN024B';  s_date='22';  hr=23;  minu=00; 
%---
Crosid=0; %0: define by <xp>, <yp>; 1: max of hyd
xp=25; yp=100;  %start grid
len=75;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam=[expri,'  dwdt'];   fignam=[expri,'_cros-dwdt_'];
%---
g=9.81; 
Rd=287.04; cpd=1005;  epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
p0=100000;
%---
zlim=4000;  % using model level height, but only below <zlim>, to interpolate
ytick=1000:1000:zlim; 
%---
for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     hgt = ncread(infile,'HGT');
     ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');    
     w.stag = ncread(infile,'W');
     w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;
     theta = ncread(infile,'T');  theta=theta+300;
     p = ncread(infile,'P'); pb = ncread(infile,'PB'); P=p+pb;
     qv = ncread(infile,'QVAPOR');               
     qr = double(ncread(infile,'QRAIN'));   
     qc = double(ncread(infile,'QCLOUD'));
     qg = double(ncread(infile,'QGRAUP'));  
     qs = double(ncread(infile,'QSNOW'));
     qi = double(ncread(infile,'QICE'));    
     hyd=qr+qc+qg+qs+qi;   
     hyd2d=sum(hyd,3);
    %---
    theta_rho=theta .* (1+qv/epsilon) ./ (1+qv+hyd) ;
    %---
%     Pi= (P/p0).^(Rd/cpd) ;
    %---
    temp  = theta.*(1e5./P).^(-Rd/cpd); %temperature (K)   
    Tv=temp.*(1+qv/epsilon)./(1+qv);
    rho=P./Tv/Rd;
    
    %---
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;  
    zg=PH/g;     
    %---creat 1-D zgi for interpolation---
    zg0=PH0/g;
    zg_1D=squeeze(zg0(150,150,:));    nzgi=length(zg_1D)*2-1; 
    zgi0(1:2:nzgi,1)= zg_1D;  zgi0(2:2:nzgi,1)= ( zg_1D(1:end-1) + zg_1D(2:end) )/2;
    zgi=zgi0(zgi0<zlim);
    %----

    if Crosid~=0
     [~,yy]=find(hyd2d == max(hyd2d(:)));   
     yp=yy;
    end

    [nx, ny, nz]=size(theta);
     %--
     for i=1:nx
      for j=1:ny     
        theta_rho_iso(i,j,:)=interp1(squeeze(zg(i,j,:)),squeeze(theta_rho(i,j,:)),zgi,'linear'); 
%         Pi_iso(i,j,:)=interp1(squeeze(zg(i,j,:)),squeeze(Pi(i,j,:)),zgi,'linear'); 
        P_iso(i,j,:)=interp1(squeeze(zg(i,j,:)),squeeze(P(i,j,:)),zgi,'linear'); 
        rho_iso(i,j,:)=interp1(squeeze(zg(i,j,:)),squeeze(rho(i,j,:)),zgi,'linear');
      end
     end  
   theta_rho_bar=mean(theta_rho_iso,[1,2],'omitnan');
   theta_rho_p=theta_rho_iso-repmat(theta_rho_bar,nx,ny,1);
   B=theta_rho_p./theta_rho_bar*g;
     
%    Pi_bar=mean(Pi_iso,[1,2],'omitnan');
%    Pi_p=Pi_iso-repmat(Pi_bar,nx,ny,1);
%    pi_diff= (Pi_p(:,:,2:end)-Pi_p(:,:,1:end-1))...
%        ./repmat(reshape((zgi(2:end)-zgi(1:end-1)),1,1,length(zgi)-1),nx,ny,1);
%    p_grad = -cpd * theta_rho_iso(:,:,1:end-1) .*  pi_diff;
   
   P_bar=mean(P_iso,[1,2],'omitnan');
   P_p=P_iso-repmat(P_bar,nx,ny,1);

   p_diff= (P_p(:,:,2:end)-P_p(:,:,1:end-1))...
       ./repmat(reshape((zgi(2:end)-zgi(1:end-1)),1,1,length(zgi)-1),nx,ny,1);
   p_grad = -1./rho_iso(:,:,1:end-1) .*  p_diff;
   
   %%
   %---  
%    [xi, zi]=meshgrid(1:nx,zgi);
% %
%    hf=figure('position',[100 200 900 600]);
%     [~, hp]=contourf(xi,zi,squeeze(B(:,yp,:))',20,'linestyle','none');
%     colorbar;% caxis([-0.025 0.06])
%         set(gca,'xlim',[1 150],'Ylim',[0 zlim-500])
%     xlabel('x (km)'); ylabel('Height (km)')
%     
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST'];     
%     title(tit,'fontsize',18)    
    %%
    %---
%     B_p=p_grad+B(:,:,1:end-1);
%     
%     [xi2, zi2]=meshgrid(1:nx,zgi(1:end-1));
%     %
%     hf=figure('position',[100 200 900 600]);
% %     [~, hp]=contourf(xi2,zi2,squeeze(p_grad(:,yp,:))',20,'linestyle','none');
%      [~, hp]=contourf(xi,zi,squeeze(P_p(:,yp,:))',20,'linestyle','none');
% %     [~, hp]=contourf(xi2,zi2,squeeze(B_p(:,yp,:))',20,'linestyle','none');
%     
%     colorbar;% caxis([-0.025 0.06])
%         set(gca,'xlim',[1 150],'Ylim',[0 zlim-500])
%     xlabel('x (km)'); ylabel('Height (km)')
%     
%     s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
%     if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
%     tit=[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST'];     
%     title(tit,'fontsize',18)    

     
  end
end
