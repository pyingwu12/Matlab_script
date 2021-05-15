function [MDTE_2D, CMDTE_2D]=cal_DTE_2D(infile1,infile2)

% calculate vertical mass weighted average (Selz and Craig 2015) of moist DTE  
% each term of DTE is calculated by the function "cal_DTEterms.m"
% P.Y. Wu 2021/02/03
% CMDTE: using u, v, w for KE (KE3D)  @ 2021/05/02

%---moist Different Total Energy----
 [DTE, P]=cal_DTEterms(infile1,infile2);
 
%---vertical mass weighted average (Selz and Craig 2015)--- 
 dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
 dPall = P.f2(:,:,end)-P.f2(:,:,1);
 dPm = dP./repmat(dPall,1,1,size(dP,3));
 %
 MDTE = DTE.KE + DTE.SH + DTE.LH;
 CMDTE = DTE.KE3D + DTE.SH + DTE.LH;
 
 MDTE_2D = sum(dPm.*MDTE(:,:,1:end-1),3) + DTE.Ps;
 CMDTE_2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
 
end