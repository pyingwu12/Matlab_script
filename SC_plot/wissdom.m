clf
fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/radar/WISSDOM_out/realcase061600.bin','r','l');
var=zeros(150,150,29);
for i=1:24
    for j=1:29
       var(:,:,j)=fread(fid,[150,150],'float');
    end
    var(find(var==-999))=nan;
    if(i==4)
       mask=var;
    end
     
    if(i==24)
       w=var;
    end
end
wi=10.*squeeze(w(:,:,3));
radarw=max(max(wi))
%addpath('/SAS004/pwin/system/pwin_tool/colorbar')
%cmap=colormap_wind; 
%L=[-8 -7 -6 -5 -4 -3 -2 -1 1 2 3 4 5 6 7 8];
cols1=zeros(9,3);
cols1(1,:)=[30 110 235];
cols1(2,:)=[80 165 245];
cols1(3,:)=[150 210 250];
cols1(4,:)=[225 255 255];
cols1(5,:)=[255 255 255];
cols1(6,:)=[255 250 170];
cols1(7,:)=[255 192  60];
cols1(8,:)=[255  96   0];
cols1(9,:)=[192   0   0];
cols1=cols1/255;
colormap(cols1);

xlon=118.61:0.0195:121.5155;
ylat=21.487:0.0182:23.5618;
[lons,lats]=meshgrid(xlon,ylat);
%wi(find(isnan(wi)==1))=0.0;
%ccols=jet(8);
%colormap(ccols);
contourf(lons',lats',wi(:,36:end),[-5 -2 -1 -0.25 0.25 1 2 5]);
caxis([-5 5])
set(gca,'xlim',[119.5 121.5],'ylim',[ 21.8 24.]);
return
[hbar]=colorbar;
set(hbar,'ytick',[-5 -2 -1 -0.25 0.25 1 2 5])
set(hbar,'ytickLabel',num2str([-5 -2 -1 -0.25 0.25 1 2 5]'))
