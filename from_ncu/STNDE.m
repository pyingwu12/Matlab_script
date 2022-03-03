function std=STNDE(A)
   n=length(A);
   d=(A-mean(A)).^2;    
   std=(sum(d)/n)^0.5;
   
