function dis=Great_circle_distance(lon1,lat1,lon2,lat2,unit)

% lon1=[141 139]; lat1=[35 35];
% lon2=140; lat2=35;

% lon1, lat1: longtitude and latitude of the start point(s)
% lon2, lat2: longtitude and latitude of the end point 

if size(lon1,1)~=size(lat1,1) || size(lon1,2)~=size(lat1,2)
    error('The size of str_lon and str_lat must match');    
end

if strcmp(unit(1),'d')==1    
    lon1=lon1*pi/180;
    lat1=lat1*pi/180;
    
    lon2=lon2*pi/180;
    lat2=lat2*pi/180;
end
    
earth_rad=6378;
% diff_rad=acos(sin(str_lat).*sin(fnl_lat) + cos(str_lat).*cos(fnl_lat).*(fnl_lon-str_lon));

diff_rad=2*asin( (sin((lat2-lat1)/2).^2 + cos(lat1).*cos(lat2).*sin((lon2-lon1)/2).^2 ).^0.5 );
dis=earth_rad*diff_rad;

end