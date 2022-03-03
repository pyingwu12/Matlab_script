addpath('/work/ailin/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');
addpath('/work/ailin/matlab/suplabel/')
addpath('/work/ailin/matlab/Discrete_colors')
addpath('/work/scyang/WRFEXPS/plot/')
constants;
obs=1;
threshold=10;
count=zeros(1,441*561);
Robs=zeros(1,441*561);
for i=1:3
    if(i<3)
    odir='/SAS002/scyang/figures/2008-06-15/';
    file=[odir,'qpe-',num2str(i+21,'%2.2d')];
    else
    odir='/SAS002/scyang/figures/2008-06-16/';
    file=[odir,'qpe-',num2str(i-3,'%2.2d')];
    end
    %odir='/SAS002/scyang/figures/2008-06-15/';
    %file=[odir,'qpe-',num2str(i+20,'%2.2d')];
    file
    fid=fopen(file,'rt');
    a=fscanf(fid,'%g %g %g',[3 Inf]);
    Robs=Robs+a(3,:);
    fclose(fid);
end
count(1,find(Robs>=threshold) )=1.0;
count(1,find(Robs<0))=nan;
Robs(find(Robs<0))=nan;

%xlon=118.0:0.0125:123.5;
%ylat=20.0:0.0125:27.0;
[xo,yo]=meshgrid([118.0:0.0125:123.5],[20.0:0.0125:27.0]);

fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/fcst/wrfout_d03_2008-06-15_12:00:00'
xlon=getnc(fdir,'XLONG',[1 -1 -1],[1 -1 -1]);
ylat=getnc(fdir,'XLAT',[1 -1 -1],[1 -1 -1]);
wfid=fopen('obs_ra1521_1600.dat','wt');
for i=1:size(xlon,1)
    i
for j=1:size(xlon,2)
    lon=xlon(i,j);
    lat=ylat(i,j);
    ind1=find( abs(xo-lon)<=.100);
    ind2=find( abs(yo(ind1)-lat)<=.100);
    ind=ind1(ind2);
    xs=lon-0.03:0.03:lon+0.03;
    ys=lat-0.03:0.03:lat+0.03;
    [xss,yss]=meshgrid(xs,ys);
    
    xvalid=min(length(find(xo(ind)>lon)),length(find(xo(ind)<lon)));
    yvalid=min(length(find(yo(ind)>lat)),length(find(yo(ind)<lat)));
    
    if(length(ind)>3 & xvalid*yvalid>0)
       Ri=griddata(double(yo(ind)),double(xo(ind)),double(Robs(ind)),yss,xss,'linear');
       Ro(i,j)=Ri(2,2);
    else
       Ro(i,j)=nan;
    end
    clear ind1 ind2 ind;
    fprintf(wfid,'%7.4f %7.4f %7.2f\n',[lon lat Ro(i,j)]);
end
end
