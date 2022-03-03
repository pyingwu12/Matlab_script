function [theta,r]=getdir(lon1,lat1,lon2,lat2)
constants;
global Re rad;
ry=Re*rad*(lat2-lat1);
rx=Re*cos(rad*(0.5*(lat1+lat2)))*rad*(lon2-lon1);
r=sqrt(rx.^2+ry.^2);
theta=atan(rx/ry)*(180/pi);
