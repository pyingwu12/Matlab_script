function rmse=RMSD(A,B)
   n=length(A); m=length(B);
   if n~=m
     disp('Error: input must hvae same size.');
     return
   end
%---cal rmse---    
   meanA=mean(A);
   meanB=mean(B);
 
   diff= ((A-meanA)-(B-meanB)).^2 ;
   rmse=(sum(diff)/n)^0.5;
