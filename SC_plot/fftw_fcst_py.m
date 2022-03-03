clear all
clf
addpath('/work/scyang/matlab/map/m_map/')
addpath '/SAS004/pwin/system/pwin_tool/colorbar'

%ylat=20.85:0.0182:23.5618;
xlon=118.61:0.0195:121.5155;
ylat=21.487:0.0182:23.5618;
[lons,lats]=meshgrid(xlon,ylat);
nx=150;ny=length(ylat);
filter = ones(2*nx-1,2*ny-1);
d0=30;
%cols=jet(20);
%cols(10:11,:)=1.0;
%colormap(cols);
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
L=[-5 -2 -1 -0.25 0.25 1 2 5];

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
for nf=1:3
    if(nf<=2)
        switch (nf)
        case(1)
           infile='wrfout_d03_2008-06-16_00:00:00';
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/fcst/1518/';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/fcst/1518/';
           infile='out_d03_2008-06-16_00:00:00.dat';
           nx1=150;ny1=150;
           tit='(a) W FCST (D01S)';
        case(2)
           infile='wrfout_d03_2008-06-16_00:00:00';
           maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/fcst/1518/';
           xlons  = (getnc([maindir,infile],'XLONG'))';
           ylats  = (getnc([maindir,infile],'XLAT'))';
           nx1=150;ny1=150;
           infile='out_d03_2008-06-16_00:00:00.dat';
           tit='(b) W FCST (D02DL)';
        end
        [var]=rdwrfgrds([maindir,infile],nx1,ny1);
        wi = griddata(xlons,ylats,var(:,:,10),lons,lats); %% 1600
        fac=1.0;
        clear xlons ylats;
    else
        tit='(c) RADAR';
        fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/radar/WISSDOM_out/realcase061600.bin','r','l');
        var=zeros(150,150,29);
        for i=1:24
            for j=1:29
               var(:,:,j)=fread(fid,[150,150],'float');
            end
            if(i==16)
               mask1=var;
               mask1(mask1==-999)=0;
            end
            if(i==17)
               mask2=var;
               mask2(mask2==-999)=0;
            end
            var(find(var==-999))=nan;
            if(i==24)
               w=var;
            end
        end
        wi=squeeze(w(:,:,3));
        newmask=mask1(:,36:end,3)+mask2(:,36:end,3);
        radarw=max(max(wi))
        %wi(find(isnan(wi)==1))=0.0;
        wi(find(wi>0.5))=0.5;
        wi(find(wi<-0.5))=-0.5;
    end
    x1=0.03+1.16*(nf-1)*0.21
    y1=0.65;
    if(nf<3)
    fftv=fft2(1.e1*squeeze(wi(1:end,1:end))',2*nx-1,2*ny-1);
    fftv = fftshift(fftv);
    fil_v  = filter.*fftv;
    fil_v = ifftshift(fil_v);
    fil_v = ifft2(fil_v,2*nx-1,2*ny-1);
    fil_v = real(fil_v(1:nx,1:ny));
    %fil_v=10.*wi';
    else
    fil_v=10.*wi(1:end,36:end);
    end
    
    L2=[min(min(fil_v)),L];
    subplot(2,2,nf)
    m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
    m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
    hold on
    [cm,hp]=m_contourf(lons(1:end,1:end),lats(1:end,1:end),fil_v',L2);
    cm=colormap(cols1);   
    set(hp,'linestyle','none');
    caxis([-5 5])
    %if(nf==3)
    %  newmask(find(newmask==0))=nan;
    %  [cmask,hpmask]=m_contourf(lons(1:end,1:end),lats(1:end,1:end),newmask',[0 1]);
    %  set(hp,'linestyle','none');
    %end
    colorbar;   
    hc=Recolor_contourf(hp,cm,L,'vert');    
    set(hc,'fontsize',13)
    %set(gca,'xlim',[119.5 121.5],'ylim',[ 21.8 24.],'fontsize',12);
    m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    
    %
    if(nf==3)
    for ii=1:3:150
    for jj=1:3:115
        if(newmask(ii,jj)==0)
           m_plot(lons(jj,ii),lats(jj,ii),'x','markersize',3,'color',[0 0 0],'LineWidth',1.1);
        end
    end
    end
    end
   
    %}
    title(tit,'fontsize',14,'fontweight','bold') 

end
%hbar=colorbar('south');
%xh1=0.03+0.22/2;
%xh2=x1+0.22/2;
%set(hbar,'position',[xh1 0.61 xh2-xh1 0.025],'xtick',[cmin:cint:cmax],'XAxisLocation','bottom')
