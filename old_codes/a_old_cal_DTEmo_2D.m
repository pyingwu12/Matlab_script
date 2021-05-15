function moDTE2D=cal_DTEmo_2D(infile1,infile2)

% calculate vertical weighted mean of different total energy (Selz and Craig 2015) 
% DTE is defined DTE=1/2(u_diff^2 + v_diff^2 + cp/Tr * T_diff^2 )
% cp: Specific heat capacity (J / Kg K)
% Tr: reference temparature 
% Pr: reference pressure

%---setting
cp=1004.9;
R=287.04;
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
Pr=1000;

%---infile 1---
 u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');
 u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
 v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
 p=ncread(infile1,'P');  pb = ncread(infile1,'PB');  P.f1 = (pb+p)/100;
 th.f1=ncread(infile1,'T')+300; 
 t.f1=th.f1.*(1e3./P.f1).^(-R/cp);
 qv.f1=double(ncread(infile1,'QVAPOR'));
 psfc.f1 = ncread(infile1,'PSFC')/100; 
 
%---infile 2---
 u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');
 u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
 v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
 p=ncread(infile1,'P');  pb = ncread(infile1,'PB');  P.f2 = (pb+p)/100; 
 th.f2=ncread(infile2,'T')+300;  
 t.f2=th.f2.*(1e3./P.f2).^(-R/cp);
 qv.f2=double(ncread(infile2,'QVAPOR')); 
 psfc.f2 = ncread(infile2,'PSFC')/100; 
 
%---calculate different
 u.diff=u.f1-u.f2; 
 v.diff=v.f1-v.f2;
%  th.diff=th.f1-th.f2;
 t.diff=t.f1-t.f2;
 qv.diff=qv.f1-qv.f2;
 psfc.diff=psfc.f1-psfc.f2;
 
 dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
 dPall = P.f2(:,:,end)-P.f2(:,:,1);
 dPm = dP./repmat(dPall,1,1,size(dP,3));
 
%---Different Total Energy----
%  moDTE = 1/2*( u.diff.^2 + v.diff.^2 + cp/Tr*th.diff.^2 +  Lv^2/cp/Tr*qv.diff.^2 );  % potential temperature
  moDTE = 1/2*( u.diff.^2 + v.diff.^2 + cp/Tr*t.diff.^2 + Lv^2/cp/Tr*qv.diff.^2 );
  moDTE2D = sum(dPm.*moDTE(:,:,1:end-1),3) + 1/2 * R*Tr*(psfc.diff/Pr).^2  ;      
%  moDTE2D = sum(dPm.*moDTE(:,:,1:end-1),3);      
 