

sigma1=12;
sigma2=4;


dh=0:0.1:20;
dv=0:0.1:20;


y2=exp(-(dh.^2+dv.^2)/(2*sigma1^2));
y=exp(-dh.^2/(sigma1^2) -dv.^2/(sigma2^2) );
yh=exp(-dh.^2/(sigma1^2));

dis=(dh.^2+dv.^2).^0.5;

figure

plot(dis,y)
hold on
plot(dis,y2)

%plot(dis,yh)



