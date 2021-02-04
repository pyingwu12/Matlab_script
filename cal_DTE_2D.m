function moDTE2D=cal_DTE_2D(infile1,infile2)

% calculate vertical mass weighted average (Selz and Craig 2015) of moist DTE  
% each term of DTE is calculated by the function "cal_DTEterms.m"
% P.Y. Wu 2021/02/03

%---moist Different Total Energy----
 [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2);
 
%---vertical mass weighted average (Selz and Craig 2015)--- 
%  p=ncread(infile2,'P');  pb = ncread(infile2,'PB');  P.f2 = (pb+p)/100; 
 dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
 dPall = P.f2(:,:,end)-P.f2(:,:,1);
 dPm = dP./repmat(dPall,1,1,size(dP,3));
 %
 total3D=KE+ThE+LH;
 moDTE2D = sum(dPm.*total3D(:,:,1:end-1),3) + Ps;  
 
end

    
   
 