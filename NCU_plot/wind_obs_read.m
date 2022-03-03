function [lon lat wspd wdir]=wind_obs_read(s_hr,year,mon,date,s_datexp)
% date: date of data file name
% s_datexp: date of the directory with obs data

%clear; s_hr='2'; year='2008'; mon='06';  date='16';  s_datexp='16';

%---station list
infile='/SAS004/pwin/data/obs_rain/station_auto.txt'; auto=importdata(infile);
infile='/SAS004/pwin/data/obs_rain/station_cwb.txt';  cwb=importdata(infile);
%---read obs data
infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/',year,mon,date,s_hr,'_auto.txt']; 
A=importdata(infile);
infile=['/SAS004/pwin/data/obs_rain/raingauge_',year,mon,s_datexp,'/',year,mon,date,s_hr,'_cwb.txt']; 
B=importdata(infile);
%---get longitude and latitude from station lists
for i=1:size(A.data,1) % auto station
  lon(i,1) = auto.data(strcmp(auto.textdata,A.textdata(i))==1,2);
  lat(i,1) = auto.data(strcmp(auto.textdata,A.textdata(i))==1,3);
end
for i=1:size(B,1)      % cwb station
  j=size(A.data,1)+i;
  lon(j,1) = cwb(cwb==B(i,1),3);
  lat(j,1) = cwb(cwb==B(i,1),4);
end
%---wind
wspd=[A.data(:,5); B(:,10)];  wdir=[A.data(:,6); B(:,11)];   
    
end