function rmse=RMSE_en(A,b)
% A : A(data length,ensemble size)
% B : B(data length)
   n=size(A,1); m=length(b);
   if n~=m
     error('Error: inputs must hvae same length.');     
   end
%---cal rmse--- 
B=repmat(b,1,size(A,2));
se=(A-B).^2;
mse=sum(se,2)/(size(A,2)-1);
rmse=sqrt(mse);