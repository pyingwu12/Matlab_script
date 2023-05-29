function DTE=cal_DTE(infile1,infile2)

% calculate different total energy (DTE, Zhang 2005, 2007) 
% defined as DTE=1/2(u_diff^2 + v_diff^2 + cp/Tr * T_diff^2 )
% cp: Specific heat capacity (J / Kg K)
% Tr: reference temparature 

cp=1004.9;  Tr=287;
%---infile1
  u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');
  u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
  v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
  t.f1=ncread(infile1,'T')+300; 
%---infile2
  u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');
  u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
  v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
  t.f2=ncread(infile2,'T')+300; 
%---calculate different
  u.diff=u.f1-u.f2; 
  v.diff=v.f1-v.f2;
  t.diff=t.f1-t.f2;
%---Different Total Energy----
  DTE=1/2*( u.diff.^2 + v.diff.^2 + cp/Tr*t.diff.^2 );
  
end

