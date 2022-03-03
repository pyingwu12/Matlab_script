clear all
clf
addpath('/work/scyang/matlab/map/m_map/')


%xlon=118.61:0.0195:121.5155;
%ylat=20.85:0.0182:23.5618;
%nx=150;ny=150;
xlon=113.5:0.1:126.5;
ylat=17.5:0.1:29.;
nx=152;ny=127;
[lons,lats]=meshgrid(xlon,ylat);
nx=length(xlon);
ny=length(ylat);
%filter = ones(2*nx-1,2*ny-1);
%d0=12;
%cols=jet(20);
%cols(10:11,:)=1.0;
%colormap(cols);
%for i = 1:2*nx-1
%    for j =1:2*ny-1
%        dist = ((i-(nx+1))^2 + (j-(ny+1))^2)^.5;
%        if dist > d0
%        filter(i,j) = 0;
%        end
%     end 
%end
lon1=119.6;lon2=122.;
lat1=22.;lat2=25.5;
lon1=119.;lon2=121.5;
lat1=21.8;lat2=23.6;
for nf=1:2
        switch (nf)
        case(1)
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/';
           infile='wrfanal_d02_2008-06-15_18:00:00';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/cycle_01/input_d02_2008-06-15_12:00:00_sloc.dat';
           nx1=159;ny1=150;
           tit='(b) W Ana. (D02DL L1)';
        case(2)
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/';
           infile='wrfanal_d02_2008-06-15_18:00:00';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           infile='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/cycle_01/input_d02_2008-06-15_12:00:00_l1.dat';
           nx1=159;ny1=150;
           tit='(c) W Ana. (D02DL)';
        end
        [var]=rdwrfgrds(infile,nx1,ny1);
        wi = griddata(xlons,ylats,var(:,:,14),lons,lats); %% 1518
        fac=1.0;
        clear xlons ylats;

    fftv=fft2(squeeze(wi(1:end,1:end)),2*nx-1,2*ny-1);
    %fftv = fftshift(fftv);
    %fil_v  = filter.*fftv;
    %fil_v = ifftshift(fil_v);
    %fil_v = ifft2(fil_v,2*nx-1,2*ny-1);
    %fil_v = real(fil_v(1:nx,1:ny));
    hold on
    power=fftv.*conj(fftv);
    %semilogy([1:299],power(1,:));
    if(nf==1)
    powers=power;
   % semilogy([1:299],diag(power)); hold on
    else
   % semilogy([1:299],diag(power),'r'); hold on
    end
    %set(gca,'xlim',[1 50])
end
