
% close all

xpi=648; ypi=425;

dat=squeeze(vari_ens(xpi,ypi,:)); n=pltensize;
sig=std(dat);    mea=mean(dat);   IQR=iqr(dat);
xup=max(dat);    xbt=min(dat);    k=zeros(6,1);  bic0=zeros(6,1);    

%--------
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

%---
figure ('Position',[100 100 1500 800]);    

for i=1:6
  h=  (xup-xbt) / (k(i)-1);
  x0= xbt : h : xup ;%mid
  [ni, ~]=histcounts(dat,'BinEdges',[x0-h*0.5 x0(end)+h*0.5]);
  ni(ni==0)=1e-8; % to avoid log(0)
  maxl=sum(ni.*log(ni))-n*log(n)-sum(ni.*log(h));
  bic0(i)=-2*maxl+(length(x0)-1)*log(n);
    
    %--plot histgram for check
    subplot(2,3,i)
    histogram(dat,'BinEdges',[x0-h*0.5 x0(end)+h*0.5],'Normalization','pdf') ;
    gaus=1/(sig*(2*pi)^0.5)*exp(-(1/2)*((x0-mea)/sig).^2);   gaus(gaus+1==1)=0;
    hold on; plot(x0,gaus)
    q=ni/n/h;
    kl=sum(gaus*log(gaus/q));
    title({['x',num2str(xpi),', y',num2str(ypi)];['sig=',num2str(sig),', IQR=',num2str(iqr(dat))];...
             ['bin=',num2str(length(x0)),', kld=',num2str(kl),', bic=',num2str(bic0(i))]})
end    



     sig1=std(dat,1);
     dat_G1=1/(sig1*(2*pi)^0.5)*exp(-(1/2)*((dat-mea)/sig1).^2);  % pdf from dat
     maxlG1=sum(log(dat_G1));
     
%      sig0=std(dat,0);
%      dat_G0=1/(sig0*(2*pi)^0.5)*exp(-(1/2)*((dat-mea)/sig0).^2);  % pdf from dat
%      maxlG0=sum(log(dat_G0));

          
     maxlG=-(n/2)*log(2*pi/n*sum((dat-mea).^2))-(n/2); %Eq (3.28)
     
     

     