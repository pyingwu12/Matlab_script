function [scc, rmse, ETS, bias]=cal_score(A,B,thres)
% Calculate SCC, RMSE, ETS, Bias of two vector A and B

   N=length(A); M=length(B);
   if N~=M
     error('Error: input must hvae same size.');     
   end
%---cal rmse---      
   mse=sum((B-A).^2)/(N);
   rmse=mse^0.5; 
%---cal scc---
   o=A-mean(A);
   f=B-mean(B); 
   s=sum(f.*o) ;  %denominator
   mf=sum(f.^2);  mo=sum(o.^2);
   m=(mf*mo)^0.5;  %numerator
   scc=s/m;   
%---cal ETS---
   %tresh=20;
   O=0; F=0; H=0; 
   for i=1:N
      if A(i)>=thres; O=O+1; end
      if B(i)>=thres; F=F+1; end 
      if A(i)>=thres && B(i)>=thres; H=H+1; end
   end
   R=F*O/N;
   ETS=(H-R)/(F+O-H-R);
   %ETS=(H)/(F+O-H);
%---cal Bias---  
   bias=F/O;