
clear

a=0; 
b=0;
c=2;

for i=1:12
   
    a=a+b;
    b=c;
    if mod(i,2)==0
     c=fix(a/2)*2;
    else
     c=fix(a/2);
    end  
    
end

answ=a+b+c;