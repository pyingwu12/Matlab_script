function rmse=RMSE(A,B)
% A : A(data length,ensemble size)
% B : B(data length)
   n=size(A,1); m=length(B);
   if n~=m
     disp('Error: input must hvae same length.');
     return
   end
%---cal rmse--- 
se=zeros(m,1);
for i=1:size(A,2)   
  se=se+(A(:,i)-B).^2;   
end
rmse=sqrt(se./(size(A,2))-1);

