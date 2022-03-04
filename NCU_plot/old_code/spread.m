function sprd=spread(A)
% calcultae the ensemble spread of A(data size , ensemble size)
   if length(size(A))>2
     error('Error: A must be a 2-D matrix.');          
   end
meanA=mean(A,2);
se=zeros(size(meanA));
for i=1:size(A,2)   
  se=se+(A(:,i)-meanA).^2;   
end
sprd=sqrt(se./(size(A,2)));
  