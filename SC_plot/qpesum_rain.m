addpath('/work/ailin/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');
addpath('/work/ailin/matlab/suplabel/')
addpath('/work/ailin/matlab/Discrete_colors')
addpath('/work/scyang/WRFEXPS/plot/')
constants;
obs=1;
threshold=[1 5 10 15 20 30 35 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200];

fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/fcst/wrfout_d03_2008-06-15_12:00:00'
xlon=getnc(fdir,'XLONG',[1 -1 -1],[1 -1 -1]);
ylat=getnc(fdir,'XLAT',[1 -1 -1],[1 -1 -1]);
mask=getnc(fdir,'XLAND',[1 -1 -1],[1 -1 -1]);
hgt=getnc(fdir,'HGT',[1 -1 -1],[1 -1 -1]);

yyyy=2008;
mm=6;
dd=15;
hh=16;
ETS=zeros(24,24,3);
BIAS=zeros(24,24,3);
ETSl=zeros(24,24,3);
BIASl=zeros(24,24,3);
ETSw=zeros(24,24,3);
BIASw=zeros(24,24,3);
for it=1:22
    %paper
    if(it<6)
    odir='/SAS002/scyang/figures/2008-06-15/';
    infile=[odir,'obs_ra',num2str(it+18,'%2.2d'),'.dat']
    else
    odir='/SAS002/scyang/figures/2008-06-16/';
    infile=[odir,'obs_ra',num2str(it-6,'%2.2d'),'.dat']
    end
    %if(it<3)
    %odir='/SAS002/scyang/figures/2008-06-15/';
    %infile=[odir,'obs_ra',num2str(it+21,'%2.2d'),'.dat']
    %else
    %odir='/SAS002/scyang/figures/2008-06-16/';
    %infile=[odir,'obs_ra',num2str(it-3,'%2.2d'),'.dat']
    %end
    rfid=fopen(infile,'rt');
    result=fscanf(rfid,'%g %g %g',[3 Inf]);
    fclose(rfid);
    ii=0;
    if(it==1);Ro=zeros(size(xlon,1),size(xlon,2));end;
    for i=1:size(xlon,1)
    for j=1:size(xlon,2)
        ii=ii+1;
        Ro(i,j)=Ro(i,j)+result(3,ii);
    end
    end
    rain(it)=nansum(result(3,:) );
    t1=['06',num2str(dd,'%2.2d'),num2str(hh,'%2.2d')];
    t2=['06',num2str(dd,'%2.2d'),num2str(1+hh,'%2.2d')];
    s_tag=['2008-06-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
    hh=hh+1;
    if(hh>=24)
       hh=hh-24;
       dd=dd+1;
    end


end

iplot=0
if (iplot==0)
%%% plot(rainfall)
[clevs des_color]=CWBRainColor;
[matcolor]=RGB(des_color(:,1),des_color(:,2),des_color(:,3));
m_proj('Mercator','long',[118. 122.],'lat',[21.7 25.6]); hold on
cmp=colormap(matcolor);
[c,h]=m_contourf(xlon,ylat,Ro,[0 clevs]);hold on
[hbar]=Recolor_contourf(h,cmp,clevs);
m_gshhs_i('color',[0.2 .2 0.2],'linewidth',2.0)
m_grid('linest','none','box','on','tickdir','in','backcolor','none','fontsize',12);
set(h,'linestyle','none')
set(gca,'fontsize',14)

drawnow
end
