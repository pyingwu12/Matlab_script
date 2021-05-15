function MDiffKE=cal_DiffKE_2D(infile1,infile2)

% calculate different laten heat energy Lv * qv_diff^2
% Lv: specific latent heat (J/Kg)

%---setting
cp=1004.9;   Tr=287;

%---infile 1---
 u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');
 u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
 v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
  p=ncread(infile1,'P');  pb = ncread(infile1,'PB');
  P = (pb+p);    dP = P(:,:,2:end)-P(:,:,1:end-1);
  dPall = P(:,:,end)-P(:,:,1);
  dPm = dP./repmat(dPall,1,1,size(dP,3));    
%---infile 2---
 u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');
 u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
 v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
%---calculate different
 u.diff=u.f1-u.f2; 
 v.diff=v.f1-v.f2;
%---Different Total Energy----
 DiffKE=1/2*(u.diff.^2+v.diff.^2);
 MDiffKE = sum(dPm.*DiffKE(:,:,1:end-1),3) ; 