function [scc rmse]=score(A,B)
   n=length(A); m=length(B);
   if n~=m
     disp('Error: input must hvae same size.');
     return
   end
%---cal rmse---      
   mse=sum((B-A).^2)/(n-1);
   rmse=mse^0.5; 
%---cal scc---
   o=A-mean(A);
   f=B-mean(B); 
   s=sum(f.*o) ;  %denominator
   mf=sum(f.^2);  mo=sum(o.^2);
   m=(mf*mo)^0.5;  %numerator
%---
   scc=s/m;