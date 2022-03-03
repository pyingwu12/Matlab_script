function hi=cal_histc(X,range)

% X should be a vector

  if (length(size(X))==2 && min(size(X))==1);

     len=length(range)+1;
     hi=zeros(len,1);
     for i=1:len
       if     i==1;   hi(i)=length(find(X<range(1)));  
       elseif i==len; hi(i)=length(find(X>=range(len-1)));
       else           hi(i)=length(find(X>=range(i-1) & X<range(i) )) ;       
       end
     end
   
  else
       
    error('X must to be a vector')
   
  end
end


