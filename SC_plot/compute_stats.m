%function [xmin,xmax,xquarts]=compute_stats(x,ndim)
function [xquarts]=compute_stats(x,ndim)
if(size(x,1)~= ndim)
   disp(['dimension mismatch'])
   return
end
for i=1:ndim
    xquarts(i,:)=quantile(x(i,:),[0.05 0.25 0.50 0.75 0.95]);
    %xmax(i)=max(x(i,:));
    %xmin(i)=min(x(i,:));
end
return
