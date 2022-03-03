clf
close all
clear all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')

% fiure setting
expmain='/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/';
xlon  =getnc([expmain,'wrfinput_d01'],'XLONG');
ylat  =getnc([expmain,'wrfinput_d01'],'XLAT');
mask  =getnc([expmain,'wrfinput_d01'],'LANDMASK');
imask=find(mask==1);
lons=111.5:2.0:135.0;
lats=13.0:2.0:33.0;
maindir{1}='../output/';
%maindir{2}='../exp05/e02/';
maindir{2}='../output/';

nx=110;
ny=110;
tag='2006-09-16_06:00:00';
var={'U';'V';'T';'PSFC'};

%file_t=strcat('../work/wrf_3dvar_input_d01_',tag)
file_t=strcat([expmain,'../initial/init_pert18/wrf_3dvar_input_d01_'],tag)

nz=1;
for nf=1:1
file=[maindir{nf},'wrfletkf_stat_',tag];
file_a=strcat(maindir{nf},'wrffcst_d01_',tag)
fid=fopen(file,'r');
for j=1:1
for i=1:4
    St=getnc(file_t,var{i});
    Sa=getnc(file_a,var{i});
    if(i<=3)
    sf=fread(fid,[nx*ny*26,1],'float');
    wk3d=reshape(sf,nx*ny,26);
    else
    sf=fread(fid,[nx*ny,1],'float');
    wk2d=reshape(sf,nx*ny,1);
    end
    dum=fread(fid,1,'int');
    if(j==1 )
       wk(:,:,i)=reshape(wk3d(:,nz),nx,ny)';
       switch (i)
       case(1)
       in1=1:nx;
       in2=2:nx+1;
       err(:,:,i)=squeeze(0.5*(Sa(nz,:,in1)+Sa(nz,:,in2))-0.5*(St(nz,:,in1)+St(nz,:,in2)));
       case(2)
       in1=1:ny;
       in2=2:ny+1;
       err(:,:,i)=squeeze(0.5*(Sa(nz,in1,:)+Sa(nz,in2,:))-0.5*(St(nz,in1,:)+St(nz,in2,:)));
       %err(:,:,1)=squeeze(Sa(1,in1,:));
       %err(:,:,2)=squeeze(St(1,in1,:));
       case(3) 
       err(:,:,i)=squeeze(Sa(nz,:,:)-St(nz,:,:));
       end
    %wk(:,:,nf)=reshape(wk2d(:,1),nx,ny)'*1.e-4;
    end
    end
    dum=fread(fid,1,'int');
    lobs=fread(fid,[nx*ny,1],'int');
    dum=fread(fid,1,'int');
    nobs=reshape(lobs(:,1),nx,ny)'/2;
end
end
wk(find(abs(wk)<=1.e-5))=NaN;
subplot(2,1,1)
clevs=0:1:20.;

%[c,h]=contourf(xlon,ylat,squeeze(wk(:,:,1)),[0:0.1:2]);hold on
%set(h,'linestyle','none');
%[c,h]=contour(xlon,ylat,mask,[0 0]);hold on
%set(h,'edgecolor','k','linewidth',3.0,'color',[0.2 0.2 0.2]);
%[c,h]=contour(xlon,ylat,squeeze(err(:,:,1)),clevs(2:end));hold on
%caxis([0 2])
%set(h,'edgecolor','k');
%axis([110 135 11 35])
%
lon1=110;lon2=135;lat1=10;lat2=35;
subplot(2,1,1)
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
m_grid('linest','none','box','fancy','tickdir','in');
clevs=-15:1.5:15;
hold on
[c,h]=m_contourf(xlon,ylat,squeeze(err(:,:,1)),clevs); caxis([clevs(1) clevs(end)]);hold on
set(h,'linestyle','none');
[c,h]=m_contour(xlon,ylat,squeeze(wk(:,:,1)),[0.5:0.5:10]);hold on
set(h,'edgecolor','k')
m_text(0.5*(lon1+lon2),lat2+0.012*(lat2-lat1),['U err. vs. spread (z=',num2str(nz),')'],'horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
subplot(2,1,2)
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
m_grid('linest','none','box','fancy','tickdir','in');
hold on
clevs=-3.:0.3:3.;
[c,h]=m_contourf(xlon,ylat,squeeze(err(:,:,3)),clevs); caxis([clevs(1) clevs(end)]);hold on
set(h,'linestyle','none');
[c,h]=m_contour(xlon,ylat,squeeze(wk(:,:,3)),[0.1:0.1:5]);hold on
set(h,'edgecolor','k')
m_text(0.5*(lon1+lon2),lat2+0.012*(lat2-lat1),['T err. vs. spread (z=',num2str(nz),')'],'horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
set(gcf,'Paperorientation','portrait','paperposition',[0.5 0.5 7.5 10])
eval(['print -dpng -r200 errspreadz',num2str(nz),'_',tag(1:13),'.png']);
%for j=1:length(lats)
%for i=1:length(lons)
%    plot(lons(i),lats(j),'+k','markersize',6)
%end
%end
