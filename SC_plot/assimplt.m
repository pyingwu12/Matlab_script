clear all
%clf
figure
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
tag='2006-09-14_18:00:00';
xlon  =netcdf_var('/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/wrfinput_d01','XLONG',1);
ylat  =netcdf_var('/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/wrfinput_d01','XLAT',1);
eta  =netcdf_var('/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/wrfinput_d01','ZNU',1);
nx=size(xlon,2);
ny=size(xlon,1);
nz=length(eta);

U=zeros(ny,nx);
V=zeros(ny,nx);
in1=1:nx;in2=in1+1;
in1z=1:26;in2z=in1z+1;
zg=zeros(nz,ny,nx);
pressure=zeros(nz,ny,nx);
iplt=1;
tag='2006-09-14_12:00:00';
files{1}=['/mnt/ddal01/scyang/WRFEXPS/exp07/e06d01/da_out/wrfanal_d01_',tag];
%files{2}=['/work/scyang/WRFEXPS/output/wrfanal_d01_',tag];
files{2}=['/mnt/ddal01/scyang/WRFEXPS/exp07/K40/e01d01/da_out/wrfanal_d01_',tag];
%files{1}=['../exp07/e04d01a/smooth/wrfsmth_d01_',tag,'.1'];
%files{2}=['../exp07/e06d01/smooth/wrfsmth_d01_',tag,'.1'];
%files{2}=['../exp06/e04/wrfanal_d01_',tag];
%files{1}=['/mnt/ddal01/scyang/WRFEXPS/exp06/e05/wrffcst_d01_',tag];
%files{2}=['/mnt/ddal01/scyang/WRFEXPS/exp06/e05/wrfanal_d01_',tag];
%files{1}=['../exp06/e02RIP/wrfinit_d01_',tag,'.1'];
%files{2}=['../exp06/e02RIP/wrfsmth_d01_',tag,'.1'];
%files{1}=['../output/wrffcst_d01_',tag];
%files{2}=['../output/wrfanal_d01_',tag];
files{3}=['/mnt/ddal01/ailin/test2/truth_run/wrf_3dvar/wrf_3dvar_input_d01_',tag];

lon1=105;
lon2=140;
lat1=6;
lat2=40;
tit{1}='Background';
tit{2}='Analysis';
tit{3}='Truth';
tit{4}='Increment';
col(2:41,1:3)=colormap(jet(40));
col(42,:)=[255 0 189]/255;
col(1,:)=[0.5 0.5 0.5];

for i=1:4
    subplot(2,2,i)
    colormap(col);
    %file=['wrf_3dvar_input_d01_',tag,'.avg']
    %file=['/work/scyang/WRFEXPS/exp06/initial/init_pert06/wrf_3dvar_input_d01_2006-09-14_06:00:00'];
    if (i<=3)
        file=files{i};
        ps=netcdf_var(file,'PSFC',0);
        ph=netcdf_var(file,'PH',0);
        phb=netcdf_var(file,'PHB',0);
        zgtmp=squeeze((ph+phb)/9.81);
        zg=0.5*(zgtmp(in1z,:,:)+zgtmp(in2z,:,:));
        qv=squeeze(netcdf_var(file,'QVAPOR',0));
        ttmp=squeeze(netcdf_var(file,'T',0));
        th=ttmp+300.0;
        for z=1:length(eta)
            pressure(z,:,:)=5000.0+(ps-5000.0).*eta(z);
        end
        temp=wrf_tk(pressure,th,'K');
        slp=calc_slp(pressure,zg,temp,qv);
        Utmp=netcdf_var(file,'U',0);
        Vtmp=netcdf_var(file,'V',0);
        
        U=squeeze(0.5*(Utmp(1,1,:,in1)+Utmp(1,1,:,in2)));
        V=squeeze(0.5*(Vtmp(1,1,in1,:)+Vtmp(1,1,in2,:)));
        clevs=990:1020;
        %clevs=205:1.:225;
    end
    switch (i)
    case(1)
      slpb=slp;
      tb=temp;
      ub=U;
      vb=V;
    case(2)
      slpa=slp;
      ta=temp;
      ua=U;
      va=V;
    case(3)
      slpt=slp;
      tt=temp;
      ut=U;
      vt=V;
    case(4)
      slp=slpa-slpb; clevs=-10:10;
      temp=ta-tb;clevs=-5:0.5:5;
      U=ua-ub;
      V=va-vb;
    end
    
    %[c,h]=contourf(xlon,ylat,slp,clevs);hold on
    %set(h,'linestyle','none')
    %caxis([clevs(1) clevs(end)])
    %quiver(xlon(1:5:end,1:5:end),ylat(1:5:end,1:5:end),U(1:5:end,1:5:end),V(1:5:end,1:5:end));
    slp(find(slp>clevs(end)))=clevs(end);
    slp(find(slp<clevs(1)))=clevs(1);

    m_proj('lambert','long',[lon1 lon2],'lat',[lat1 lat2]);
    m_grid('linest','none','box','fancy','tickdir','in');
    hold on
    [c,h]=m_contourf(xlon,ylat,slp,clevs); caxis([clevs(1) clevs(end)]);hold on
    %[c,h]=m_contourf(xlon,ylat,squeeze(temp(19,:,:)),clevs); caxis([clevs(1) clevs(end)]);hold on
    set(h,'linestyle','none')
    m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    h=m_quiver(xlon(1:5:end,1:5:end),ylat(1:5:end,1:5:end),U(1:5:end,1:5:end),V(1:5:end,1:5:end));
    set(h,'Color',[0 0 0]);
    %m_text(xc,yc,'X','horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
    m_text(0.5*(lon1+lon2),lat2+0.015*(lat2-lat1),tit{i},'horizontalalignment','center','VerticalAlignment','bottom','fontsize',14,'fontweight','bold')
end

text(0.7,-0.2, ['SLP , Time: ',tag(1:10),' ',tag(12:13),'Z'],'unit','normal');
set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 11 8])
pfile=['exp06e05_slpinc',tag,'.ps'];
%eval(['print -dpsc ',pfile]);
