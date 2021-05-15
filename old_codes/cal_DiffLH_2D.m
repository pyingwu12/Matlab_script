function MDiffLH=cal_DiffLH_2D(infile1,infile2)

% calculate different laten heat energy Lv * qv_diff^2
% Lv: specific latent heat (J/Kg)

%---setting
Lv=(2.4418+2.43)/2 * 10^6 ;
global cp 
Tr=270;

%---infile 1---
 qv1 = double( ncread(infile1,'QVAPOR') ); 

%---infile 2---
 qv2 = double( ncread(infile2,'QVAPOR') ); 
%---calculate different
 qv.diff=qv1-qv2;
 
   p=ncread(infile2,'P');  pb = ncread(infile2,'PB');
  P = (pb+p);    dP = P(:,:,2:end)-P(:,:,1:end-1);
  dPall = P(:,:,end)-P(:,:,1);
  dPm = dP./repmat(dPall,1,1,size(dP,3));   
  
%---Different Total Energy----
%  DiffLH = Lv*s.diff.^2 ;
%  DiffLH = Lv*s.diff.^2 ;
 DiffLH = 1/2 * Lv^2/cp/Tr*qv.diff.^2 ;
 MDiffLH = sum(dPm.*DiffLH(:,:,1:end-1),3) ; 

