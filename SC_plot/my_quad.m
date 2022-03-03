function [out,ymean]=my_quad(x,y)
n=length(x);
out=0.0;
d=0.0;
for i=1:n-1
    out=0.5*(x(i+1)-x(i))*(y(i)+y(i+1))+out;
    d=d+(x(i+1)-x(i));
end
ymean=out/d;
