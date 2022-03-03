%file='../output/letkf_weight_09-14_06:00:00.1 ';
%fid=fopen(file,'r');
clear all;
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');
file0='/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/wrfinput_d01';
xlon=getnc(file0,'XLONG');
ylat=getnc(file0,'XLAT');
%xlon  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG',1);
%ylat  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT',1);
fid=fopen('../output/letkf_weight_2006-09-14_06:00:00.1','r');
fid2=fopen('../output/letkf_weightsm.out','r');
dum=fread(fid2,1,'int');
ws=fread(fid2,[110,110],'float');
dum=fread(fid2,1,'int');
ieof=0;
i=1;
wmap=zeros(5000,20);
w1=zeros(5000);
w2=zeros(5000);
xobs=zeros(5000);
yobs=zeros(5000);
while (ieof==0)
dum=fread(fid,1,'int');
is(1:3)=fread(fid,[3,1],'int');
if (is(3)==1)
    xobs(i)=xlon(is(1),is(2));
    yobs(i)=ylat(is(1),is(2));
    w=fread(fid,[20,20],'double');
    wbar=mean(w,2);
    w1(i)=w(2,2)-wbar(2);
    wmap(i,:)=wbar;
    dum=fread(fid,1,'int');
    ieof=feof(fid);
    i=i+1;
else
   break
end
end
fclose(fid);
n=i-1
lons=111.5:0.5:135.0;
lats=13.0:0.5:33.0;
[xi,yi]=meshgrid(lons,lats);
figure
subplot(2,1,1)
zi=griddata(xobs(1:n),yobs(1:n),wmap(1:n,1),xi,yi);
%[c,h]=contourf(xi,yi,smooth2a(zi,5,5),[-0.75:0.075:0.75]);
[c,h]=contourf(xi,yi,zi,[-0.75:0.075:0.75]);
set(gca,'xtick',[115:5:130],'xticklabel',{'115E';'120E';'125E';'130E'},'ytick',[15:5:30],'yticklabel',{'15N';'20N';'25N';'30N'},...
'fontsize',12,'fontweight','bold')
colorbar('vert')
caxis([-0.75 0.75])
return
subplot(2,1,2)
zi=griddata(xobs(1:n),yobs(1:n),w1(1:n),xi,yi);
[c,h]=contourf(xi,yi,zi,[0.6:0.02:1.]);
set(gca,'xtick',[115:5:130],'xticklabel',{'115E';'120E';'125E';'130E'},'ytick',[15:5:30],'yticklabel',{'15N';'20N';'25N';'30N'},...
'fontsize',12,'fontweight','bold')
caxis([0. 1.])
colorbar('vert')
