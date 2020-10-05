
clear
%close all

x=1:250;
y=1:200;

[xi, yi]=meshgrid(x,y);


ide=length(xi);

hm=1000;  
xa=10;  %helf height radius (gird)
ya=10;
icmx=length(x)/2; %center of hill
icmy=length(y)/2;

Vol=624000;
      
   %ht = hm./(  1  +  ((xi-icmx).^2 + (yi-icmy).^2)/xa^2 );   
   
   %ht_g =  hm * exp(- ((xi-icmx)/(2*xa)).^2 - ((yi-icmy)/(2*ya)).^2 ) ;  % GOOOOD~
    
   ht_g = Vol * 1/(2*pi*xa^2)^0.5 * 1/(2*pi*ya^2)^0.5 * exp(- ((xi-icmx)/(2^0.5*xa)).^2 - ((yi-icmy)/(2^0.5*ya)).^2 ) ; 
  % figure
%    plot(ht_g(:,icmx)) ; hold on
%    sum(ht_g(:,icmx))
   
%    sigm=5;
%    ht_g1 =  1/(2*pi*sigm^2)^0.5 * exp(- (  (x-icmx)/(2^0.5*sigm)  ).^2) ; 
%    plot(ht_g1)
%    sum(ht_g1)
   
   %ht_g2 =  hm * exp(- ((xi-icmx).^2 + (yi-icmy).^2) ./ (2*xa^2) ) ;
     
%    
%    figure('position',[-1000 200 700 500])
%      contour(xi,yi,ht,30)

%    figure('position',[-800 200 700 500])
%      contour(xi,yi,ht_g2,30)
% 
   figure('position',[100 200 700 500])
     contour(xi,yi,ht_g,30)
%    
     figure('position',[100 200 800 500])
% %      plot(ht(icmy,:));  hold on
%       plot(ht_g(icmy,:));hold on
       plot(ht_g(:,icmx))
%      plot(ht_g2(icmy,:))
%      legend('ht','ht_g','ht_g2')
