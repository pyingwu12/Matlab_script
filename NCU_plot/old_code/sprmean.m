function sprd=sprmean(A)
% calcultae the "domain mean" ensemble spread of A(data size , ensemble size)
meanA=mean(A,2);
se=zeros(size(meanA));
for i=1:size(A,2)   
  se=se+(A(:,i)-meanA).^2;   
end
se=mean(se);
sprd=sqrt(se./(size(A,2)));