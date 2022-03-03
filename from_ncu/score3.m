function [POD SR]=score3(A,B,tresh)
   N=length(A); M=length(B);
   if N~=M
     error('Error: inputs must hvae same size.');     
   end
%-------------   
   O=0; F=0; H=0; 
   for i=1:N
      if A(i)>=tresh; O=O+1; end
      if B(i)>=tresh; F=F+1; end 
      if A(i)>=tresh && B(i)>=tresh; H=H+1; end
   end
   POD=H/O;
   SR=H/F;


   
