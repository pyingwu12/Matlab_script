clear all
addpath('/work/scyang/matlab/map/m_map/')
fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/radar/1512-1606/realcase061518.bin','r','l');
wfid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/radar/1512-1606/fil061518.bin','w','l');
xlon=118.61:0.0195:121.5155;
ylat=20.85:0.0182:23.5618;
[lons,lats]=meshgrid(xlon,ylat);
var=zeros(150,150,31);
for i=1:6
    for j=1:31
%      dummy=fread(fid,1,'int');
       var(:,:,j)=fread(fid,[150,150],'float');
%      dummy=fread(fid,1,'int');
    end
    var(find(var==-999))=nan;
    if(i==6)
       w=var;
    end
    if(i==12)
       div=var;
    end
end
div=w;
fclose(fid);
clf
%Y=fft(squeeze(var(:,:,8)).');
%for i=1:150
%    %if(isnan(Y(1,i))==1)
%    %   Y(:,i)=0.0;
%    %end
%end
%Y2=fft(Y.');
nx=148;
ny=148;
div=squeeze(var(:,:,7));
div(find(isnan(div)==1))=0.0;
%fftv=fft2(1.e4*squeeze(div(2:end-1,2:end-1)),2*nx-1,2*ny-1);
fftv=fft2(1.e2*squeeze(div(2:end-1,2:end-1)),2*nx-1,2*ny-1);
fftv = fftshift(fftv);
subplot(2,2,1)
mesh(log(1+(abs(fftv))));
filter = ones(2*nx-1,2*ny-1);
d0=15;
for i = 1:2*nx-1
    for j =1:2*ny-1
        dist = ((i-(nx+1))^2 + (j-(ny+1))^2)^.5;
        if dist > d0
            filter(i,j) = 0;
        end
    end 
end
fil_v  = filter.*fftv;

subplot(2,2,2)
%mesh(log(1+(abs(filter))));

lon1= 119.6;lon2= 121.5;
lat1= 21.8; lat2= 24.;
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
hold on
m_contourf(lons(2:end-1,2:end-1),lats(2:end-1,2:end-1),1.e2*div(2:end-1,2:end-1)',[-100:10:100]);
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
caxis([-100 100])
title('Original data')

subplot(2,2,3)
mesh(log(1+(abs(fil_v))));

fil_v = ifftshift(fil_v);
fil_v = ifft2(fil_v,2*nx-1,2*ny-1);
fil_v = real(fil_v(1:nx,1:ny));

fwrite(wfid,fil_v,'float');
fclose(wfid)

subplot(2,2,4)
lon1=119.6;lon2=122.;
lat1=22.;lat2=25.5;
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
hold on
m_contourf(lons(2:end-1,2:end-1),lats(2:end-1,2:end-1),fil_v',[-75:7.5:75]);
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
caxis([-75 75])
title('Filtered data')
return
Y2=fftshift(fft2(squeeze(var(:,:,8))));
YLog=log(1+abs(Y2));
filter=( YLog > 0.7*max(YLog(:)) | YLog > 0.2*max(YLog(:)) );
%ws= abs(ifft2(Y2.*filter));
ws= abs(ifft2(Y2));
subplot(2,1,1)
contourf(squeeze(var(:,:,8)),[-10:1:10]);
caxis([-10 10])

Y2(75-40:75,:)=0.0+0.0i;
Y2(76,:)=0.0;
Y2(150-40:150,:)=0.0+0.0i;
ws=ifft2(Y2);
%ws=ifft(Y);
subplot(2,1,2)
contourf(real(ws),[-10:1:10]);
caxis([-10 10])
%Y=fft2(squeeze(w(:,:,7)));
