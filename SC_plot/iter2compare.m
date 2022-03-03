clf;
clear all;
load /SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/fcstTRUTH_e28_1hr.mat;
lonc0=lonc(1,1:6:end);
latc0=latc(1,1:6:end);
slp0=SLP(1,1:6:end);
hh=12;
for i=3:3
subplot(3,1,i)
time=['15',num2str(hh,'%2.2d')];
hh=hh+6;
for j=1:3
    switch (j)
    case(1)
       run='e01';
       eval(['load /SAS001/ailin/exp09/osse/',run,'/AVG/Fcst',time,'Track.mat;'])
    case(2)
       run='e03';
       eval(['load /SAS001/ailin/exp09/osse/',run,'/AVG/Fcst',time,'Track.mat;'])
    case(3)
       run='e12';
       eval(['load /SAS002/ailin/exp09/osse/',run,'/AVG/Fcst',time,'Track.mat;'])
    end
eval(['lons',num2str(j),'=lonc;'])
eval(['lats',num2str(j),'=latc;'])
eval(['slp',num2str(j),'=SLP;'])
end
[lonc0(15) latc0(15)]
[lons1(9) lats1(9)]
[lons2(9) lats2(9)]
plot(slp0(6+i:end),'g'); hold on
plot(slp1,'k'); hold on
plot(slp2,'b'); hold on
plot(slp3,'r'); hold on
axis([1 8 930 970])
end
