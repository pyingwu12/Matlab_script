clear all
clf
addpath('/work/scyang/matlab/map/m_map/')


xlon=118.61:0.0195:121.5155;
ylat=20.85:0.0182:23.5618;
[lons,lats]=meshgrid(xlon,ylat);
nx=150;ny=150;
filter = ones(2*nx-1,2*ny-1);
%d0=12;

d0=100;
cols=jet(20);
cols(10:11,:)=1.0;
colormap(cols);
for i = 1:2*nx-1
    for j =1:2*ny-1
        dist = ((i-(nx+1))^2 + (j-(ny+1))^2)^.5;
        if dist > d0
        filter(i,j) = 0;
        end
     end 
end
lon1=119.6;lon2=122.;
lat1=22.;lat2=25.5;
lon1=119.;lon2=121.5;
lat1=21.8;lat2=23.6;
for nf=1:4
    if(nf<=3)
        switch (nf)
        case(1)
           infile='wrfanal_d01_2008-06-15_18:00:00';
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/anald01_2008-06-15_18:00:00.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/anald01_2008-06-15_18:00:00.dat';
           nx1=180;ny1=150;
           tit='(a) W Ana. (D01S)';
        case(2)
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/';
           infile='wrfanal_d02_2008-06-15_18:00:00';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00_l1.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00_l1.dat';
           nx1=159;ny1=150;
           tit='(b) W Ana. (D02DL L1)';
        case(3)
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/';
           infile='wrfanal_d02_2008-06-15_18:00:00';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00.dat';
           nx1=159;ny1=150;
           tit='(c) W Ana. (D02DL)';
        end
        [var]=rdwrfgrds(infile,nx1,ny1);
    %    wi = griddata(xlons,ylats,var(:,:,11),lons,lats); %% 1518
        wi = griddata(xlons,ylats,var(:,:,14),lons,lats); %% 1518
        fac=1.0;
        clear xlons ylats;
    else
        tit='(d) RADAR';
        fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/radar/1512-1606/realcase061518.bin','r','l');
        %fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/radar/1512-1606/realcase061606.bin','r','l');
        var=zeros(150,150,31);
        for i=1:6
            for j=1:31
               var(:,:,j)=fread(fid,[150,150],'float');
            end
            var(find(var==-999))=nan;
            if(i==6)
               w=var;
            end
        end
        %wi=squeeze(w(:,:,7)); %% 1518
        wi=squeeze(w(:,:,10));
        radarw=max(max(wi))
        wi(find(isnan(wi)==1))=0.0;
        fac=0.5;
    end
    x1=0.03+1.16*(nf-1)*0.21
    y1=0.65;
    fftv=fft2(1.e2*squeeze(wi(1:end,1:end)),2*nx-1,2*ny-1);
    fftv = fftshift(fftv);
    fil_v  = filter.*fftv;
    fil_v = ifftshift(fil_v);
    fil_v = ifft2(fil_v,2*nx-1,2*ny-1);
    fil_v = real(fil_v(1:nx,1:ny));
    %fil_v=100*wi;

    subplot(2,4,nf)
    m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
    m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
    hold on
    cmax=25;
    cmin=-25;
    cint=(cmax-cmin)/20;
    [c,h]=m_contourf(lons(1:end,1:end),lats(1:end,1:end),fac*fil_v',[cmin:cint:cmax]);
    set(h,'linestyle','none')
    m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    caxis([cmin cmax])

    [c,h]=m_contour(lons(1:end,1:end),lats(1:end,1:end),fac*fil_v',[2*cmin:cint:-cint,cint:cint:2*cmax]);
    set(h,'edgecolor','k')
    title(tit,'fontsize',12,'fontweight','bold')
    set(gca,'position',[x1 y1 0.22  0.28],'fontsize',10);
end
hbar=colorbar('south');
xh1=0.03+0.22/2;
xh2=x1+0.22/2;
set(hbar,'position',[xh1 0.61 xh2-xh1 0.025],'xtick',[cmin:cint:cmax],'XAxisLocation','bottom')
for nf=1:3
        switch (nf)
        case(1)
           infile='wrfanal_d01_2008-06-15_18:00:00';
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           nx1=180;ny1=150;
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/fcstd01_2008-06-15_18:00:00.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/fcstd01_2008-06-15_18:00:00.dat';
           [var1]=rdwrfgrds(infile,nx1,ny1);
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/anald01_2008-06-15_18:00:00.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/anald01_2008-06-15_18:00:00.dat';
           [var2]=rdwrfgrds(infile,nx1,ny1);
           var=var2-var1;
           tit='(e) W Inc. (D01S)';
        case(2)
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/';
           infile='wrfanal_d02_2008-06-15_18:00:00';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           nx1=159;ny1=150;
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/fcst_d02_2008-06-15_18:00:00_l1.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/fcst_d02_2008-06-15_18:00:00_l1.dat';
           [var1]=rdwrfgrds(infile,nx1,ny1);
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00_l1.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00_l1.dat';
           [var2]=rdwrfgrds(infile,nx1,ny1);
           var=var2-var1;
           tit='(f) W Inc. (D02DL, L1)';
        case(3)
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/';
           infile='wrfanal_d02_2008-06-15_18:00:00';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           nx1=159;ny1=150;
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/fcst_d02_2008-06-15_18:00:00_sloc.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/fcst_d02_2008-06-15_18:00:00_sloc.dat';
           [var1]=rdwrfgrds(infile,nx1,ny1);
           %infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00.dat';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-15_18:00:00.dat';
           [var2]=rdwrfgrds(infile,nx1,ny1);
           var=var2-var1;
           tit='(g) W Inc. (D02DL)';
        end
    x1=0.03+1.16*(nf-1)*0.21
    y1=0.25;
        var(find(var==nan))=0.0;
        %wi = GRIDDATA(xlons,ylats,var(:,:,11),lons,lats); %% 1518
        wi = GRIDDATA(xlons,ylats,var(:,:,14),lons,lats); 
        fac=1.0;
        clear xlons ylats;
        fftv=fft2(1.e2*squeeze(wi(1:end,1:end)),2*nx-1,2*ny-1);
        fftv = fftshift(fftv);
        fil_v  = filter.*fftv;
        fil_v = ifftshift(fil_v);
        fil_v = ifft2(fil_v,2*nx-1,2*ny-1);
        fil_v = real(fil_v(1:nx,1:ny));
        cmax=15;
        cmin=-15;
        cint=(cmax-cmin)/20;
        fil_v(find(fil_v>cmax))=cmax;
        fil_v(find(fil_v<cmin))=cmin;
        subplot(2,4,nf+4)
        m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
        m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
        hold on
        [c,h]=m_contourf(lons(1:end,1:end),lats(1:end,1:end),fac*fil_v',[cmin:cint:cmax]);
        set(h,'linestyle','none')

        [c,h]=m_contour(lons(1:end,1:end),lats(1:end,1:end),fac*fil_v',[2*cmin:cint:-cint,cint:cint:2*cmax]);
        set(h,'edgecolor','k')
        m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
        caxis([cmin cmax])
    title(tit,'fontsize',12,'fontweight','bold')
    set(gca,'position',[x1 y1 0.21  0.28],'fontsize',10);
end
hbar=colorbar('south');
set(hbar,'position',[xh1 0.21 xh2-xh1 0.025],'xtick',[cmin:cint:cmax],'XAxisLocation','bottom')
