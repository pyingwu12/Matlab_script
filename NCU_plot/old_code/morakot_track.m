
clear
infile='/SAS004/pwin/data/Morakot_JTWC_track.txt';

A=importdata(infile);

len=size(A,1);


for i=1:len
lon(i)=str2double(A{i}(36:38))/10;
lat(i)=str2double(A{i}(42:45))/10;
yyyy(i)=str2double(A{i}(9:12));
mm(i)=str2double(A{i}(13:14));
dd(i)=str2double(A{i}(15:16));
hh(i)=str2double(A{i}(17:18));
end


lon1=lon(dd==7 & hh==12)*pi/180;  lat1=lat(dd==7 & hh==12)*pi/180;
lon2=lon(dd==7 & hh==18)*pi/180;  lat2=lat(dd==7 & hh==18)*pi/180;


ra=6371.22;



dis= ra*  sqrt(   cos((lat1+lat2)/2)^2  *  (lon2-lon1)^2    + (lat2-lat1)^2    );

disl= sqrt( (lon2-lon1)^2 + (lat2-lat1)^2  ) ;