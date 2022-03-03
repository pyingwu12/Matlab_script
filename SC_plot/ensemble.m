clear all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
tag='2006-09-15_18:00:00';
xlon  =netcdf_var('/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/wrfinput_d01','XLONG',1);
ylat  =netcdf_var('/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/wrfinput_d01','XLAT',1);
U=zeros(110,110);
V=zeros(110,110);
in1=1:110;in2=2:111;

iplt=1;
for i=1:20
    %dir=['/work/scyang/WRFEXPS/init_pert',num2str(i,'%2.2d')];
    %dir=['/work/scyang/WRFEXPS/exp06/initial2/init_pert',num2str(i,'%2.2d')];
    dir=['/work/scyang/WRFEXPS/exp06/initial/init_pert',num2str(i,'%2.2d')];
    file=[dir,'/wrf_3dvar_input_d01_',tag]
    %file=[dir,'/wrfinput_d01_148179_0_',num2str(i)];
    S=squeeze(netcdf_var(file,'PSFC',0));
    Utmp=netcdf_var(file,'U',0);
    Vtmp=netcdf_var(file,'V',0);
    
    in1=1:110;in2=2:111;
    U=squeeze(0.5*(Utmp(1,1,:,in1)+Utmp(1,1,:,in2)));
    V=squeeze(0.5*(Vtmp(1,1,in1,:)+Vtmp(1,1,in2,:)));
    if(iplt==1);figure;clf;end
    subplot(3,3,iplt)
    [c,h]=contourf(xlon,ylat,S*1.e-4,[9.8:0.02:10.2]);hold on
    %if(i>1)
    %   S0=S0+S/20.;
    %else
    %   S0=S/20.;
    %end
    set(h,'linestyle','none')
    caxis([9.8 10.2])
    %[c,h]=contourf(xlon,ylat,U-U0,[-10:1:10]);hold on
    %caxis([-20 20])
    quiver(xlon(1:5:end,1:5:end),ylat(1:5:end,1:5:end),U(1:5:end,1:5:end),V(1:5:end,1:5:end));
    if(iplt==9);iplt=iplt-9;end
    iplt=iplt+1;
    set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 11 8])
end
%print -dpdf -f1 f1.pdf
%print -dpdf -f2 f2.pdf
%print -dpdf -f3 f3.pdf

