

sigma1=12;
sigma2=4;


dh=0:0.1:40;
dv=0:0.1:40;

y=exp(-dh.^2/(sigma1^2) -dv.^2/(sigma2^2) );
y2=exp(-(dh.^2+dv.^2)/(2*sigma1^2));
yh=exp(-dh.^2/(sigma1^2));

dis=(dh.^2+dv.^2).^0.5;

figure

plot(dis,y,dis,y2)
%plot(dis,yh)




