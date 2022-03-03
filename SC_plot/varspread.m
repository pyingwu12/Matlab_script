
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
maindir='/work/scyang/WRFEXPS/exp05/';
%maindir='/work/scyang/WRFEXPS/';
subdir{1}='e01';
subdir{3}='e03';
subdir{2}='e02';
%subdir{3}='output';

%xlon_u=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG_U',1);
%ylat_u=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT_U',1);
%xlon_v=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG_V',1);
%ylat_v=netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT_V',1);
xlon  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLONG',1);
ylat  =netcdf_var('/work/scyang/WRFV2/test/em_real/wrfinput_d01','XLAT',1);
var={'T';'U';'V';'PSFC'};
nens=20;
tag='2006-09-14_06:00:00'
si=zeros(size(xlon,1),size(xlon,2),nens+1);
sbar=zeros(size(xlon,1),size(xlon,2));
sstd=zeros(size(xlon,1),size(xlon,2));
for j=4:4
    dir_this=[maindir,subdir{1}];
    %file=strcat([dir_this,'/wrf_3dvar_input_d01_'],tag);
    for k=1:nens%+1
        %if (k<=nens)
            infile=[file,'_',num2str(k,'%2.2d')];
            infile=['../init_pert',num2str(k,'%2.2d'),'/wrf_3dvar_input_d01_',tag,''];
            %infile=['../init_pert',num2str(k,'%2.2d'),'/wrfinput_d01_148179_0_',num2str(k)];
        %else
        %    infile=file;
        %end
        disp([infile])
        S=netcdf_var(infile,var(j),0);
        switch( cell2mat(var(j)) )
            case('U')
               clevs=-20:2:20;
               i1=1:size(S,4)-1;
               i2=2:size(S,4);
               si(:,:,k)=squeeze(0.5*(S(1,1,:,i1)+S(1,1,:,i2)));
            case('V')
               clevs=-20:2:20;
               j1=1:size(S,3)-1;
               j2=2:size(S,3);
               si(:,:,k)=0.5*(S(1,1,j1,:)+S(1,1,j2,:));
            case('T')
               lons=xlon;
               lats=ylat;
               clevs=-10:1:10;
               si(:,:,k)=S(1,1,:,:);
            case('PSFC')
               lons=xlon;
               lats=ylat;
               clevs=[8.5:0.15:9.7,9.8:0.02:10.2];
               si(:,:,k)=S(1,:,:)*1.e-4;
            case('W')
                    lons=xlon;
                    lats=ylat;
                    clevs=-2:0.2:2;
        end
    end
    sbar=mean(si(:,:,1:nens),3);
    for k=1:nens
        si(:,:,k)=si(:,:,k)-sbar;
    end
    sstd=sqrt(squeeze(mean(si(:,:,1:nens).^2,3)));
    return
    %[c,h]=contourf(xlon,ylat,sbar,9.9:0.02:10.2);hold on
    [c,h]=contourf(sbar,9.9:0.02:10.2);hold on
    caxis([9.9 10.2])
    set(h,'linestyle','none');
    %[c,h]=contour(xlon,ylat,sstd,[0.005 0.0075 0.01 0.0125 0.015 0.0175 0.02]);
    %[c,h]=contour(sstd,[0.005 0.0075 0.01 0.0125 0.015 0.0175 0.02]);
    [c,h]=contour(sstd,20);
    set(h,'edgecolor','k');
    return
end

