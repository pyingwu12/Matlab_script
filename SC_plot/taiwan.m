addpath('/work/scyang/matlab/map/m_map/')
clf
lon1=119.6;lon2=122.;
lat1=21.9;lat2=25.5;
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
m_grid('linest','none','box','fancy','tickdir','in','xtick',10);hold on
xlon=119.5:.01:122.;
ylat=21.85:0.01:25.;
nx=length(xlon);
ny=length(ylat);
a=ones(nx,ny);
[h,c]=m_contour(xlon,ylat,a');
set(h,'linestyle','none');
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
x1=120.17;x2=120.35;y1=23.15;y2=22.5;
p=(y1-y2)/(x1-x2);
q=y1-p*x1;
xc=0.5*(x1+x2);
yc=p*xc+q;
q=yc+(1/p)*xc;

x3=120;y3=(-1/p)*x3+q;
angle1=atan((yc-y3)/(xc-x3))*180/pi;
m_plot([120.17 120.35],[23.15 22.5],'r')
m_plot([xc x3],[yc y3],'r')

m_plot([120.3 120.67],[22.6 22.42],'r')
%x1=120.3;x2=120.67;y1=22.6;y2=22.42;
x1=.3000;x2=.6700;y1=.600;y2=.4200;
p=(y1-y2)/(x1-x2);
q=y1-p*x1;
xc=0.5*(x1+x2)+120.0000;
yc=p*(xc-120.0)+q+22.0000;

q=(yc-22.0)+(1/p)*(xc-120.0);
y3=0.25+22.0;
x3=(y3-22.0-q)*(-p)+120.0;
angle2=atan((yc-y3)/(xc-x3))*180/pi;
m_plot([xc x3],[yc y3],'r')
