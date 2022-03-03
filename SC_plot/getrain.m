function [train raintime]=getrain(infile,tsn)
% infile:the file you want to get the total rainfull
% tsn:time serial number
% printButton:[]

addpath('/work/ailin/matlab/lib')
addpath('/work/ailin/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/')
constants;

time=getnc(infile,'Times');
rainc=getnc(infile,'RAINC',[tsn -1 -1],[tsn -1 -1]);
rainnc=getnc(infile,'RAINNC',[tsn -1 -1],[tsn -1 -1]);
train=rainc+rainnc;
if(tsn==1 & size(time,2)==1)
   raintime=1;
   return
end
stim=time(1,:);
etim=time(tsn,:);
sDD=datestr(datenum(time(1,:), 'yyyy-mm-dd_HH:MM:SS'), 'ddHH');
eDD=datestr(datenum(time(tsn,:), 'yyyy-mm-dd_HH:MM:SS'), 'ddHH');
sday=str2num(sDD(1:2));
shr=str2num(sDD(3:4));
eday=str2num(eDD(1:2));
ehr=str2num(eDD(3:4));
if (eday < sday)
    fprintf(1,'error time input.\n')
else
    if shr <= ehr
       raintime=(eday-sday)*24+(ehr-shr);
    else
       raintime=(eday-sday)*24-(shr-ehr);            
    end
end
