function [yr,a]=multireg(x,y,no)
n=length(x);
D=zeros(n,no);
D(:,1)=1;
D(:,2)=x;
if(no>2)
  for i=3:no
      D(:,i)=x.^(i-1);
  end
end
Z=D'*D;
b=D'*(y);
a=inv(Z)*b;


yr=D*a;% regressed valie
return
