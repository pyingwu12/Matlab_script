function [xlon,ylat,R] =get_rainfall(fdir)
yy='2008';
mm='06';
sdd=15;  %start day
shh=16;  %start hour
edd=15;  %end day 
ehh=24;  %end hour
DT=6;   %interval hour
r_dt=24; % the hour that total cumulus preciptation
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
for i=1:cyc
    s_tag=[yy,'-',mm,'-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
    for jt=1:size(Times,1)
        if ( Times(jt,:)==s_tag );n=jt;break;end
    end
    [rain1]=getrain(fdir,n);
    hh1=hh+r_dt;
    dd1=dd;
    if hh1>=24
        hh1=hh1-24;
        dd1=dd1+1;
    end
    e_tag=[yy,'-',mm,'-',num2str(dd1,'%2.2d'),'_',num2str(hh1,'%2.2d'),':00:00']
    for jt=1:size(Times,1)
        if ( Times(jt,:)==e_tag );n=jt;break;end
    end
    [rain2]=getrain(fdir,n);
    R=rain2-rain1;
    R(R==0)=-1e-6;
    clear rain1 rain2
end
