function [R]=Func_rainfall_20120308(fdir,ibar,titname,time1,time2,r_dt)
%clear all
%addpath('/work/ailin/matlab/map/m_map/')
%addpath('/work/scyang/matlab/mexcdf/mexnc')
%addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');
%addpath('/work/ailin/matlab/suplabel/')
addpath('/work/ailin/matlab/Discrete_colors')
addpath('/work/scyang/WRFEXPS/plot/')
%constants;
[clevs des_color]=CWBRainColor;
%[clevs des_color]=RainColor;
[matcolor]=RGB(des_color(:,1),des_color(:,2),des_color(:,3));

%fdir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e03/fcst/wrfout_d03_2008-06-15_12:00:00'
yy='2010';
mm=time1(1:2);
sdd=str2num(time1(3:4)); %start day
shh=str2num(time1(5:6));  %start hour
edd=str2num(time2(3:4));  %end day 
ehh=str2num(time2(5:6));  %end hour
%DT=22;   %interval hour
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
for i=1:cyc
    s_tag=[yy,'-',mm,'-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00']
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
    %if(titname(1:19)=='(a) CNTL, 06/15 12Z')
    %   fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e17_1deg_upper/fcst/wrfout_d03_2008-06-16_01:00:00'
    %   Times=getnc(fdir,'Times');
    %end
    %if(titname(1:19)=='(b) REF, 06/15 12Z ')
    %if(titname(1:19)=='(c) BND, 06/15 12Z ')
    %   fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/quikscat/wrfout_d03_2008-06-16_07:00:00'
    %   Times=getnc(fdir,'Times');
    %end
    for jt=1:size(Times,1)
        if ( Times(jt,:)==e_tag );n=jt;break;end
    end
    [rain2]=getrain(fdir,n);
    max(max(rain2))
    R=(rain2-rain1);
    R(R==0)=-1e-6;
    %disp(num2str(length(find(R==0))))
    clear rain1 rain2
    %titname=[num2str(dd,'%2.2d'),num2str(hh,'%2.2d'),'z-',num2str(dd1,'%2.2d'),num2str(hh1,'%2.2d'),'z '];
    %if iplt==1
    %    figure
    %end
    %subplot(nplt(1),nplt(2),iplt)

    if(ibar>=0)
     m_proj('Mercator','long',[122.5 132],'lat',[32 41]); hold on
%    m_proj('Mercator','long',[110 142],'lat',[24 50]); hold on %%% large
%    m_proj('Mercator','long',[117.5 122.5],'lat',[21.3 25.8]); hold on
%    m_gshhs_i('color','k','linewidth',2.0)
    cmp=colormap(matcolor);
    [c,h]=m_contourf(xlon,ylat,R,[0 clevs]);hold on
    [hbar]=Recolor_contourf(h,cmp,clevs);
    m_gshhs_i('color',[0.2 .2 0.2],'linewidth',2.0)
    m_grid('linest','none','box','on','tickdir','in','backcolor','none','fontsize',12);    
    %m_grid('linest','none','box','fancy','tickdir','in','backcolor','none','fontsize',9);
%    m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    title(titname,'fontsize',14,'fontweight','bold')
    set(h,'linestyle','none')
    set(gca,'fontsize',14)
    drawnow
    
    %if iplt==nplt(1)*nplt(2) || i==cyc
    if(ibar==0)
       [hbar]=Recolor_contourf(h,cmp,clevs,'horizontal');
       set(hbar,'position',[0.135 0.05 0.76 0.02]);
       %set(hbar,'position',[0.1 0.4,0.8,0.02])
       get(hbar,'Xtick')
    end

    end 

    iplt=iplt+1;
    if iplt > nplt(1)*nplt(2)
       iplt=1; 
    end
    hh=hh+6;
    dd=dd;
    if hh>=24
        hh=hh-24;
        dd=dd+1;
    end
end
