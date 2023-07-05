function [x, y]= ellipse(a,b,x1,y1)

% a = length of x axis
% b = length of y axis
% x1 = center of x coordinate 
% y1 = center of y

t = -pi:0.01:pi;
x = x1+(a*cos(t));
y = y1+(b*sin(t));
