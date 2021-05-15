% close all

a=0.1;

H=2000;

L=20;

x=1:300;
y=1:300;

z=910;


[x1, y1]=meshgrid(x,y);

qv= a * exp(-z/H) * sin(2*pi*(x1/L-0)).*sin(2*pi*(y1/L-0));
%qv=0.01*sin((x1+y1)/L*pi/2);
%figure
surf(x1(1:50,1:50),y1(1:50,1:50),qv(1:50,1:50),'Linestyle','none')
%surf(x1(1:100,1:100),y1(1:100,1:100),qv(1:100,1:100),'Linestyle','none')
colorbar


% [X,Y] = meshgrid(1:0.5:10,1:20);
% Z = sin(X) + cos(Y);
% C = X.*Y;
% figure
% surf(X,Y,Z,C)
% colorbar


% t=0:0.1:10;
% fx=exp(t);
% figure
% plot(t,fx)



