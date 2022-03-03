function [AC POD FAR POFD TS ETS KSS]=score2(A,B,tresh)
   N=length(A); M=length(B);
   if N~=M
     error('Error: inputs must hvae same size.');     
   end

%-------------   
   O=0; F=0; H=0; CN=0; FA=0; M=0; Ox=0;
   for i=1:N
      if A(i)>=tresh; O=O+1; else Ox=Ox+1; end
      if B(i)>=tresh; F=F+1; end 
      if A(i)>=tresh && B(i)>=tresh; H=H+1; end
      if A(i)<=tresh && B(i)<=tresh; CN=CN+1; end
      if A(i)<=tresh && B(i)>=tresh; FA=FA+1; end
     % if A(i)>=tresh && B(i)<=tresh; M=M+1; end
   end
   
   AC=(H+CN)/N;
   %bias=(F+H)/(O+H);
   POD=H/O;
   FAR=FA/F;
   POFD=FA/Ox;
   TS=H/(F+O-H);   R=F*O/N;
   ETS=(H-R)/(F+O-H-R);
   KSS=POD-POFD;

   
