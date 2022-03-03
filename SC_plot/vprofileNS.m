%
% vertical profile for selected cross-line
% contour: potential temperture (K)
% shading: wind speed (ms^-1)
% by Shu-Chih Yang 2009 Jul06
%  
%

function [xd,levs,ws2d]=vprofile(file,yyyy,mm,dd,hh,do_plot)
%file='/SAS001/scyang/WRFEXPS/exp09/E28_2/e02RIPB/da_out/wrfanal_d01_2006-09-14_12:00:00';
%yyyy='2006';
%mm='09';
%dd='15';
%hh='12';
do_plot=1;

constants;
global Re rad;
tag=[yyyy,'-',mm,'-',dd,'_',hh,':00:00'];
% define the constant pressure levels
levs=[100000 , 95000 ,  90000 , 85000 ,  80000 , 75000 ,  70000 ,...
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
    [u,v,w,th,qv,temp,slp,pressure]=getnc_vars(file,n,xlon,ylat,eta);
    ws=sqrt(u.^2+v.^2);
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
      %if(yg(iy,ix)< 18.5 | xg(iy,ix)<124.0 );
      %   ifound=1;
      %   psi(iy,ix)=max(max(psi));
      %else
         ifound=0;
      %end
    end
    lonc=xg(iy,ix);
    latc=yg(iy,ix);
    %lonc=124.2000;
    %latc= 19.6000
    %lonc=123.;%latc=20.0; %1500
    %lonc=124.;%latc=20.0; %1500
    %lonc=124.5;latc=20.0;%1412
    %lonc=124.2500;latc=19.7500;
    disp([lonc,latc])
    slpc=slp_c;
else
    disp(['No valid time is found!!!'])
    disp(['Check the input time and filename'])
end
clear xs ys;
% define the cross-line
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
inc=40;
disp([size(xlon),ii,jj])
xlon_s=xlon(ii-inc:ii+inc,jj-inc:jj+inc);    
ylat_s=ylat(ii-inc:ii+inc,jj-inc:jj+inc);    
for i=ii-inc:ii+inc
for j=jj-inc:jj+inc
    p=pressure(:,i,j);
    q1=th(:,i,j);
    q2=ws(:,i,j);
    good=find(isnan(p)==0);
    i1=i-(ii-inc)+1;
    j1=j-(jj-inc)+1;
    th_p(:,i1,j1)=interp1(p(good),q1(good),levs);
    ws_p(:,i1,j1)=interp1(p(good),q2(good),levs);
end
end
%ry=Re*rad*(y(1:iobs-1)-y(iobs));
lon2=distance./(Re*cos(rad*latc)*rad)+lonc;
lon1=lonc-(lon2-lonc);
%xs(1:100,1)=lon1:(lon2-lon1)/(npoint-1):lon2;
%ys(1:100,1)=latc;
% slice
ys(1:100,1)=latc-10:(20)/(npoint-1):latc+10;
xs(1:100,1)=lonc;%-10:(20)/(npoint-1):lonc+10;
%xd=Re*cos(rad*latc)*rad*(xs-lonc);
ry=Re*rad*(ys-latc);
rx=Re*cos(rad*latc)*rad*(xs-lonc);
for i=1:100
    if(ry(i,1)>0)
      xd(i)=sqrt(rx(i).^2+ry(i).^2);
    else
      xd(i)=-sqrt(rx(i).^2+ry(i).^2);
    end
end
for nz=1:length(levs)
    th2d(:,nz)=griddata(xlon_s,ylat_s,squeeze(th_p(nz,:,:)),xs,ys);
    ws2d(:,nz)=griddata(xlon_s,ylat_s,squeeze(ws_p(nz,:,:)),xs,ys);
    %thtmp=griddata(xlon_s,ylat_s,squeeze(th_p(nz,:,:)),xs,ys);
    %wstmp=griddata(xlon_s,ylat_s,squeeze(ws_p(nz,:,:)),xs,ys);
    %th2d(:,nz)=diag(thtmp);
    %ws2d(:,nz)=diag(wstmp);
end
if (do_plot < 0)
return
end
%col=colormap('jet')
col=jet(40);
col(end,:)=[0.7,0.7,0.7];
col(end-1,:)=[1,0,1];
colormap(col);
[c,h]=contourf(xd,1.e-2*levs,ws2d',[0:2:40]);hold on
caxis([0 40])
set(h,'linestyle','none');
[c,h]=contour(xd,1.e-2*levs,th2d',[300:4:380]);
hlab=clabel(c,h,'LabelSpacing',300);
%set(hlab,'BackgroundColor',[1. y. 1.],'Margin',1);
set(h,'linestyle','-','edgecolor',[150 150 150]/256);
%[c,h]=contour(xd,1.e-2*levs,th2d',[306 306]);
%set(h,'linestyle','-','linewidth',2.0,'edgecolor',[0 0 0]);
set(gca,'Ydir','reverse','Ylim',[100 990],'Xlim',[-800 800]);
%hbar=colorbar('vertical');
xlabel('Distance (km)','fontsize',14)
ylabel('Pressure (hPa)','fontsize',14)
%text(-800,85,['Date:',yyyy,'-',mm,'-',dd,' ',tag(end-7:end)],'HorizontalAlignment','left','verticalAlignment','bottom','fontweight','bold','Fontsize',12)
