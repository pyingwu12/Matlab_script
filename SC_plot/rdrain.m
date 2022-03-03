function [R]=Func_rainfall_20120308(fdir,ibar,titname,time1,time2,r_dt,itime)
%clear all
addpath('/work/ailin/matlab/Discrete_colors')
addpath('/work/scyang/WRFEXPS/plot/')
%constants;
[clevs des_color]=CWBRainColor;
[matcolor]=RGB(des_color(:,1),des_color(:,2),des_color(:,3));
%fid=fopen(outfile,'wt');
yy='2008';
mm=time1(1:2);
sdd=str2num(time1(3:4)); %start day
shh=str2num(time1(5:6));  %start hour
edd=str2num(time2(3:4));  %end day 
ehh=str2num(time2(5:6));  %end hour
%r_dt=22; % the hour that total cumulus preciptation
nplt=[1 1]; % subplot set
%============================================
cyc=(24*(edd-sdd)+(ehh-shh))/6+1;
cyc=1;
hh=shh;
dd=sdd;
Times=getnc(fdir,'Times');
iplt=1;
xlon=getnc(fdir,'XLONG',[1 -1 -1],[1 -1 -1]);
ylat=getnc(fdir,'XLAT',[1 -1 -1],[1 -1 -1]);
%hgt=getnc(fdir,'HGT',[1 -1 -1],[1 -1 -1]);
mask=getnc(fdir,'XLAND',[1 -1 -1],[1 -1 -1]);
%[min(min(xlon)) max(max(xlon))]
%[min(min(ylat)) max(max(ylat))]
for i=1:cyc
    s_tag=[yy,'-',mm,'-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00']
    if(size(Times,2)==1);
       n=1;
    else
       for jt=1:size(Times,1)
           if ( Times(jt,:)==s_tag );n=jt;break;end
       end
    end
    [rain1]=getrain(fdir,n);
    hh1=hh+r_dt;
    dd1=dd;
    if hh1>=24
        hh1=hh1-24;
        dd1=dd1+1;
    end

    e_tag=[yy,'-',mm,'-',num2str(dd1,'%2.2d'),'_',num2str(hh1,'%2.2d'),':00:00']
    if(itime==1)
       nchar=length(fdir);
       fdir=[fdir(1:nchar-19),e_tag];
       Times=getnc(fdir,'Times');
    end
   
    for jt=1:size(Times,1)
        if ( Times(jt,:)==e_tag );n=jt;break;end
    end
    [rain2]=getrain(fdir,n);
    R=(rain2-rain1);
    R(R==0)=-1e-6;
    %Rs=reshape(R,size(R,1)*size(R,2),1);
    %lons=118.05:0.07:123.4400;
    %lats=20.06:0.07:26.9900;
    %for i=1:78
    %for j=1:100
    %    lon=lons(i);
    %    lat=lats(j);
    %    ind1=find( abs(xlon-lon)<=.300);
    %    ind2=find( abs(ylat(ind1)-lat)<=.300);
    %    ind=ind1(ind2);
    %    xs=lon-0.07:0.07:lon+0.07;
    %    ys=lat-0.07:0.07:lat+0.07;
    %    [xss,yss]=meshgrid(xs,ys);
    %    if(length(ind)>3)
    %    Ri=griddata(double(ylat(ind)),double(xlon(ind)),double(Rs(ind)),yss,xss,'linear');
    %    Rnew(i,j)=Ri(2,2);
    %    else
    %    Rnew(i,j)=-999;
    %    end
    %    fprintf(fid,'%7.4f %7.4f %7.2f\n',[lon lat Rnew(i,j)]);
    %end
    %end
    clear rain1 rain2

    hh=hh+6;
    dd=dd;
    if hh>=24
        hh=hh-24;
        dd=dd+1;
    end
end
