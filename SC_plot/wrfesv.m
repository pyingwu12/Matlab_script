%clear all
figure(1);clf
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
maindir='/SAS004/davidchou/expoutput/e26/exp1100/';
file='cycle_01/wrfout_d01_2008-09-11_00:00:00';
xlon  =getnc([maindir,file],'XLONG');
ylat  =getnc([maindir,file],'XLAT');
eta  = getnc([maindir,file],'ZNU');
i1=1;i2=199;
j1=1;j2=179;
nz=27;
nx=i2-i1+1;
ny=j2-j1+1;
nn=nx*ny*27;
constants;
global Re rad;
%latc=21.2;
%lonc=125.2;
%lonc=125.161;latc=22.015;
lonc=125.174;latc=22.768;
lonc=124.634;latc=24.982;
ry=Re*rad*(ylat-latc);
rx=Re*cos(rad*latc)*rad*(xlon-lonc);
r=reshape(sqrt(rx.^2+ry.^2),179*199,1);
%mask=find(r<2000.0 & r> 150.0);
%mask2=find(r<2000.0 & r> 150.0);
%mask2=find(r<2000.0 & r> 150.0);
%mask2=find(r<500.0);
mask=find(r<3000.0);
mask2=find(r<1500.0);
%utmp=zeros(179,199);
%for i=1:ns
%    ii=mask(i);
%    iy=mod(ii,ny)
%    ix=(ii-iy)/ny+1
%    if(iy==0)
%       iy=ny;ix=ix-1;
%    end
%    utmp(iy,ix)=1.0;
%end
%return
%icount=0;
%for j=1:179
%for i=1:199
%    if(r(j,i)<=1000.0);then
%       icount=icount+1;
%       mask(j,i)=1;
%    end
%end
%end

%% choose a domain
%i1=max(find(xlon(1,:)<=119));
%i2=min(find(xlon(1,:)>=134));
%j1=max(find(ylat(:,1)<=12));
%j2=min(find(ylat(:,1)>=28));
var={'T';'U';'V';'QVAPOR';'PSFC'};
iread=1;
if(iread==0)
for it=1:2
    if(it==1)
       tag=['2008-09-11_00:00:00'];
       ns=length(mask);
    else
       %tag=['2008-09-12_00:00:00'];
       tag=['2008-09-13_00:00:00'];
       ns=length(mask2);
    end
    for k=1:32
        file=strcat([maindir,'cycle_',num2str(k,'%2.2d'),'/wrfout_d01_'],[tag,''])
        [u,v,w,th,qv,temp,slp,pressure]=getnc_vars(file,1,xlon,ylat,eta);
        if(it==1)
           for iz=1:nz
               vtmp=reshape(u(iz,:,:),179*199,1);
               ei(1+(iz-1)*ns:iz*ns,k)=vtmp(mask);
               vtmp=reshape(v(iz,:,:),179*199,1);
               ei(ns*27 +1+(iz-1)*ns:iz*ns+ns*27,k)=vtmp(mask);
           end
        else
           for iz=1:nz
               vtmp=reshape(u(iz,:,:),179*199,1);
               ef(1+(iz-1)*ns:iz*ns,k)=vtmp(mask2);
               vtmp=reshape(v(iz,:,:),179*199,1);
               ef(ns*27 +1+(iz-1)*ns:iz*ns+ns*27,k)=vtmp(mask2);
           end
        end
        uens(:,:,:,k)=u(:,j1:j2,i1:i2);
        vens(:,:,:,k)=v(:,j1:j2,i1:i2);
    end
    if(it==1)
       for k=1:32
           ei(:,k)=ei(:,k)-mean(ei,2);
       end
    else
       for k=1:32
           ef(:,k)=ef(:,k)-mean(ef,2);
       end
    end
end
end
A=inv(ei'*ei)*(ef'*ef);
[V,D]=eig(A);
iesv1=ei*V(:,1);
fesv1=ef*V(:,1);
uiesv=zeros(nz,ny,nx);
viesv=zeros(nz,ny,nx);
ufesv=zeros(nz,ny,nx);
vfesv=zeros(nz,ny,nx);
%kz=15
k1=1;
ns=length(mask);
for i=1:ns
    ii=mask(i);
    iy=mod(ii,ny);
    ix=(ii-iy)/ny+1;
    if(iy==0)
       iy=ny;ix=ix-1;
    end
    for kz=1:nz
    ii=i+(kz-1)*ns;
    uiesv(kz,iy,ix)=iesv1(ii,1);
    ii=i+(kz-1)*ns+ns*nz;
    viesv(kz,iy,ix)=iesv1(ii,1);
    end
end
ns=length(mask2);
for i=1:ns
    ii=mask2(i);
    iy=mod(ii,ny);
    ix=(ii-iy)/ny+1;
    if(iy==0)
       iy=ny;ix=ix-1;
    end
    for kz=1:nz
    ii=i+(kz-1)*ns;
    ufesv(kz,iy,ix)=fesv1(ii,1);
    ii=i+(kz-1)*ns+ns*nz;
    vfesv(kz,iy,ix)=fesv1(ii,1);
    end
end
kz=5;
%uiesv=reshape(iesv1(1:nn,1),27,ny,nx);
%viesv=reshape(iesv1(1+nn:2*nn),27,ny,nx);
%ufesv=reshape(fesv1(1:nn),27,ny,nx);
%vfesv=reshape(fesv1(1+nn:2*nn),27,ny,nx);
[lons,lats]=textread('location_24hr.dat');
erri=squeeze(sum(sqrt(uiesv(:,:,:).^2+viesv(:,:,:).^2),1));
errf=squeeze(sum(sqrt(ufesv(:,:,:).^2+vfesv(:,:,:).^2),1));
%erri=squeeze(sum(sqrt(viesv(:,:,:).^2),1));
%errf=squeeze(sum(sqrt(vfesv(:,:,:).^2),1));
ws=sqrt(mean(uens(kz,:,:,:),4).^2+mean(vens(kz,:,:,:),4).^2);
lon1=115;lon2=142;
lat1=5;lat2=35;

subplot(2,2,1)
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);hold on
m_grid('linest','none','box','fancy','tickdir','in');hold on
m_contour(xlon(j1:j2,i1:i2),ylat(j1:j2,i1:i2),squeeze(ws));hold on
m_quiver(xlon(j1:2:j2,i1:2:i2),ylat(j1:2:j2,i1:2:i2),squeeze(uiesv(kz,1:2:j2,i1:2:i2)),squeeze(viesv(kz,1:2:j2,i1:2:i2)),3) ;
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
set(gca,'position',[0.08 0.52 0.4  0.44]);

subplot(2,2,3)
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);hold on
m_grid('linest','none','box','fancy','tickdir','in');
cmax=200;%max(max(erri(:,:)));
cmin=0.;
cint=(cmax-cmin)/20;
[c,h]=m_contourf(xlon(j1:j2,i1:i2),ylat(j1:j2,i1:i2),squeeze(erri),[4*cint:cint:cmax]);hold on
caxis([4*cint cmax])
set(h,'linestyle','none')
m_plot(lonc,latc,'kx','linewidth',2.,'markersize',10)
%for i=1:length(lons)
%    m_plot(lons(i),lats(i),'ko','markersize',10)
%end
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
set(gca,'position',[0.08 0.05 0.4  0.44]);
%axis([115 134 12 31])
subplot(2,2,2)
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);hold on
m_grid('linest','none','box','fancy','tickdir','in');
m_contour(xlon(j1:j2,i1:i2),ylat(j1:j2,i1:i2),squeeze(ws));hold on
m_quiver(xlon(j1:2:j2,i1:2:i2),ylat(j1:2:j2,i1:2:i2),squeeze(ufesv(kz,j1:2:j2,i1:2:i2)),squeeze(vfesv(kz,j1:2:j2,i1:2:i2)),4) ;
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
set(gca,'position',[0.54 0.52 0.4  0.44]);
subplot(2,2,4)
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);hold on
m_grid('linest','none','box','fancy','tickdir','in');
cmax=max(max(errf(:,:)));
cmin=0;
cint=(cmax-cmin)/20;
[c,h]=m_contourf(xlon(j1:j2,i1:i2),ylat(j1:j2,i1:i2),squeeze(errf),[2*cint:cint:cmax]);hold on
caxis([2*cint cmax])
set(h,'linestyle','none')
m_plot(lonc,latc,'kx','linewidth',2.,'markersize',10)
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
set(gca,'position',[0.54 0.05 0.4  0.44]);
set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 10 8])
