function [KE, ThE, LH, Ps]=cal_DTE_term(udiff,vdiff,tdiff,qvdiff,psdiff)

%---calculate each term of moist DTE---
% P.Y. Wu 2021/02/03
% Reference: Ehrendorfer et al. (1999); Zhang et al. (2003)
%---
% cp: Specific heat capacity (J / Kg K)
% R : gas constant
% Lv: laten heat
% Tr: reference temparature 
% Pr: reference pressure

%---pamaters---
% cp=1004.9;
% R=287.04;
global cp R
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
Pr=1000;
%---caculation---
KE = 1/2 * ( udiff.^2 + vdiff.^2 );
ThE= 1/2 *  cp/Tr*tdiff.^2 ;
LH = 1/2 * Lv^2/cp/Tr*qvdiff.^2 ;
Ps = 1/2 * R*Tr*(psdiff/Pr).^2 ;

end