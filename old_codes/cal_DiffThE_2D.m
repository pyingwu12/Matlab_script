function MDiffTE=cal_DiffTE_2D(infile1,infile2)

% calculate different laten heat energy Lv * qv_diff^2
% Lv: specific latent heat (J/Kg)

%---setting
cp=1004.9;   Tr=287;

%---infile 1---
 t.f1=ncread(infile1,'T')+300; 
  p=ncread(infile1,'P');  pb = ncread(infile1,'PB');
  P = (pb+p);    dP = P(:,:,2:end)-P(:,:,1:end-1);
  dPall = P(:,:,end)-P(:,:,1);
  dPm = dP./repmat(dPall,1,1,size(dP,3));    
%---infile 2---
 t.f2=ncread(infile2,'T')+300; 
%---calculate different
 t.diff=t.f1-t.f2;
%---Different Thermal Energy----
 DiffTE = cp/Tr*t.diff.^2 ;
 MDiffTE = sum(dPm.*DiffTE(:,:,1:end-1),3) ; 

