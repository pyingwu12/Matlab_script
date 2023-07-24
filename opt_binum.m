function [bin_num, intv, x, bic]=opt_binum(dat)

% test different bin number and find mininum BIC

% dat=squeeze(vari_ens(xpi,ypi,:)); n=pltensize;
n=length(dat);
xup=max(dat);    xbt=min(dat);    k=zeros(6,1);  bic0=zeros(6,1);    

% 1. Square-root choice, k=ceil(n^0.5)
     k(1)=ceil(n^0.5);
     
% 2. Sturges' formula, k=ceil(log2(n))+1
     k(2)=ceil(log2(n)+1);
     
% 3. Rice rule, k=ceil(2*n^(1/3))
     k(3)=ceil(2*n^(1/3));
     
% 4. Scott's normal reference rule
     h=3.49*std(dat)/n^(1/3);
     k(4)=ceil( (xup-xbt)/h );
     
% 5. FreedmanDiaconis' choice
     h=(2*iqr(dat))/(n)^(1/3);
     k(5)=ceil( (xup-xbt)/h );
     
% 6. First gauss of Sakamoto 1983, k= [2*√n] -1
     k(6)=floor(2*n^0.5)-1;
%-------------     

for i=1:6
  h=  (xup-xbt) / (k(i)-1);
  x0= xbt : h : xup ;%mid
         
  [ni, ~]=histcounts(dat,'BinEdges',[x0-h*0.5 x0(end)+h*0.5]);       
  ni(ni==0)=1e-8; % to avoid log(0)
  
%   maxl=sum(ni.*log(ni))-n*log(n);
  maxl=sum(ni.*log(ni))-n*log(n)-sum(ni.*log(h));
  bic0(i)=-2*maxl+(length(x0)-1)*log(n);         
end    
    
[bic, b]=min(bic0);
bin_num=k(b);
intv=  (xup-xbt) / (bin_num-1);
x= xbt : intv : xup ;
     