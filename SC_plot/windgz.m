%
% vertical profile for selected cross-line
% contour: potential temperture (K)
% shading: wind speed (ms^-1)
% by Shu-Chih Yang 2009 Jul06
%  
%

function windgz(file,yyyy,mm,dd,hh,do_plot,slice,lonc0,latc0)
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
%file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrf_3dvar_input_d01_2006-09-16_06:00:00_28';
%yyyy='2006';
%mm='09';
%dd='16';
%hh='06';
%lonc0=-1;
%latc0=-1;
%do_plot=1;

constants;
global Re rad;
tag=[yyyy,'-',mm,'-',dd,'_',hh,':00:00'];
% define the constant pressure levels
levs=[100000 , 98000, 96000 , 94000, 92000,90000 , 87500, 85000 ,  80000 , 75000 ,  70000 ,...
       65000 , 60000 , 55000  , 50000 ,  45000 , 40000 ,  35000 ,...
       30000 , 25000 , 20000  , 15000 ,  10000 , 5000 ,   1000];

xc=124.0;yc=22.0; %initial guess for the center
dlat=5.0;
time=getnc(file,'Times');
n=0;
for jt=1:size(time,1)
    if (time(jt,:)==tag);n=jt;end
end
if(size(time,1)*size(time,2)==19);n=1;end
disp(['Time No.=',num2str(n)])
%disp([length(time),size(time),n])

xlon=getnc(file,'XLONG');
ylat=getnc(file,'XLAT');
eta=getnc(file,'ZNU');
if(size(eta,2)>1) 
   xlontmp=xlon;
   ylattmp=ylat;
   etatmp=eta;
   clear xlon ylat eta;
   xlon=squeeze(xlontmp(1,:,:));
   ylat=squeeze(ylattmp(1,:,:));
   eta=squeeze(etatmp(1,:));
   clear xlontmp ylattmp etatmp;
end
if( n>0 )
    [u,v,w,th,qv,temp,slp,pressure,zg]=getnc_vars(file,n,xlon,ylat,eta);
    ws=sqrt(u.^2+v.^2);
    if(lonc0<0)
    ind1=find( abs(xlon-xc)<=5);
    ind2=find( abs(ylat(ind1)-yc)<=5);
    ind=ind1(ind2);
    xs=xc-dlat:0.2:xc+dlat;
    ys=yc-dlat:0.2:yc+dlat;
    [xg,yg]=meshgrid(xs,ys);
    pss=reshape(slp,size(slp,1)*size(slp,2),1);
    psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'linear');
    %check min is the location!!
    ifound=1;
    while ( ifound >0 )
      [slp_c,ic]=min(reshape(psi,size(psi,1)*size(psi,2),1) );
      iy=mod(ic,size(psi,2));
      ix=(ic-iy)/size(psi,2)+1;
      if(iy==0) 
         iy=size(psi,1);
         ix=ix-1;
      end
         ifound=0;
    end
    lonc=xg(iy,ix);
    latc=yg(iy,ix);
    else
      lonc=lonc0;
      latc=latc0;
    end
    disp([lonc,latc])
else
    disp(['No valid time is found!!!'])
    disp(['Check the input time and filename'])
end
clear xs ys;
% define the cross-line
if(strfind(file,'TRUTH')>0)
   if(dd=='15' &hh=='12')
   disp([file])
   %jj=jj-20;
   lonc=lonc-0.5;
   file
   end
end
npoint=100;
xs=zeros(npoint,1);
ys=zeros(npoint,1);
distance=800.00; % define distance
ry=Re*rad*(ylat-latc);
rx=Re*cos(rad*latc)*rad*(xlon-lonc);
r=sqrt(rx.^2+ry.^2);
[ic,jc]=find(r< 50.00);
rmin=1.e10;
for i=1:size(ic,1)
    if(r(ic(i),jc(i))<rmin);
       ii=ic(i);
       jj=jc(i);
       rmin=r(ic(i),jc(i));
    end
end
inc=50;
disp([size(xlon),ii,jj])
%xlon_s=xlon(ii-inc:ii+inc,jj-inc:jj+inc);    
%ylat_s=ylat(ii-inc:ii+inc,jj-inc:jj+inc);    
xlon_s=xlon;    
ylat_s=ylat;    
for i=1:size(xlon_s,1)
for j=1:size(xlon_s,2)
    p=log10(pressure(:,i,j));
    q1=zg(:,i,j);
    q2=qv(:,i,j);
    q3=u(:,i,j);
    q4=v(:,i,j);
    good=find(isnan(p)==0);
    i1=i;%-(ii-inc)+1;
    j1=j;%-(jj-inc)+1;
    zg_p(:,i1,j1)=interp1(p(good),q1(good),log10(levs));
    ws_p(:,i1,j1)=interp1(p(good),q2(good),log10(levs));
    u_p(:,i1,j1)=interp1(p(good),q3(good),log10(levs));
    v_p(:,i1,j1)=interp1(p(good),q4(good),log10(levs));
end
end
m_proj('miller','long',[112 144],'lat',[9 40]);
m_grid('linest','none','box','fancy','tickdir','in');hold on
%[c,h]=m_contourf(xlon_s,ylat_s,squeeze(zg_p(8,:,:)),[1.4e3:0.005e3:1.58e3]);hold on
%[c,h]=m_contour(xlon_s,ylat_s,squeeze(zg_p(11,:,:)),[2900:20:3300]);hold on
data_in=squeeze(zg_p(11,:,:));
clevs=5505:20:6000;
clevs=2900:30:3300;
[c,h]=m_contour(xlon_s,ylat_s,smooth2a(data_in,2,2),clevs);hold on
set(h,'edgecolor',[0.5 0.5 0.5])
clevs_thick=[3180 3180];
%clevs_thick=[5925 5925];
[c,h]=m_contour(xlon_s,ylat_s,smooth2a(data_in,2,2),clevs_thick);hold on
set(h,'edgecolor',[0.5 0.5 0.5],'linewidth',2.0)
clabel(c,h);
disp([max(max(squeeze(zg_p(15,:,:))))])
%set(h,'linestyle','none')
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
%h=m_quiver(xlon_s(1:2:end,1:2:end),ylat_s(1:2:end,1:2:end),squeeze(u_p(8,1:2:end,1:2:end)),squeeze(v_p(8,1:2:end,1:2:end)),1.5);
%set(h,'color',[0.5 0.5 0.5])
