xm(1:2)=[1 4]
ym(1:2)=[2 5]
scale=1;
xunit=1;
yunit=1;
ll = sqrt((xm(2)-xm(1))^2+(ym(2)-ym(1))^2);
l1 = ll * 0.1 * scale;
l2 = 0.45 * l1;
l3 = sqrt(l1^2+l2^2-2*l1*l2*cos(pi*(90+30)/180));d1 = 180/pi*acos((l1^2+l3^2-l2^2)/2/l1/l3);
d0 = dir_tmp + d1; %1xN
d0(find(d0>360))=d0(find(d0>360))-360;
X2=Xv+(l3*xunit)*sin((pi/180)*d0); %1xN
Y2=Yv+(l3*yunit)*cos((pi/180)*d0); %1xN
