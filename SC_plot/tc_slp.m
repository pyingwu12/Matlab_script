clear all
clf
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
tag='2006-09-14_06:00:00';
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
it=1;
hh=6;
dd=14;
expdir='../exp06/e07/';
for it=1:12
    tag=['2006-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
    files{1}=[expdir,'wrffcst_d01_',tag];
    files{2}=[expdir,'wrfanal_d01_',tag];
    files{3}=['/work/scyang/WRFEXPS/exp06/initial/init_pert18/wrf_3dvar_input_d01_',tag];
    for i=1:3
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
        xc=125.0;yc=20.0;
        ind1=find( abs(xlon-xc)<=4.0);
        ind2=find( abs(ylat(ind1)-yc)<=4.0);
        ind=ind1(ind2);
        if(it<=3)
           dlat=4.5;
        else
          dlat=9.5;
        end
        xs=xc-dlat:0.5:xc+dlat;
        ys=yc-dlat:0.5:yc+dlat;
        [xg,yg]=meshgrid(xs,ys);
        pss=reshape(slp,size(slp,1)*size(slp,2),1);
        psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'linear');
        [slp_c,ic]=min(reshape(psi,size(psi,1)*size(psi,2),1) );
        iy=mod(ic,size(psi,2));
        ix=(ic-iy)/size(psi,2)+1;
        if(iy==0) 
           iy=size(psi,1);
           ix=ix-1;
        end
        lonc(i,it)=xg(iy,ix);
        latc(i,it)=yg(iy,ix);
        slpc(i,it)=slp_c;
   end
    hh=hh+6;
    if(hh>=24);
       hh=hh-24;
       dd=dd+1;
    end 
end
m_proj('lambert','long',[115 135],'lat',[15 30]); hold on
m_grid('linest','--','box','fancy','tickdir','in');
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
    m_plot(lonc(1,:),latc(1,:),'-b+');%,'horizontalalignment','center','VerticalAlignment','middle','fontsize',12,'fontweight','bold')
    m_plot(lonc(2,:),latc(2,:),'-r+');%,'horizontalalignment','center','VerticalAlignment','middle','fontsize',12,'fontweight','bold')
    m_plot(lonc(3,:),latc(3,:),'-k+');%,'horizontalalignment','center','VerticalAlignment','middle','fontsize',12,'fontweight','bold')

set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 11 8])
figure(2);clf
plot(slpc(3,:),'k','linewidth',2.0);;hold on
plot(slpc(1,:),'b','linewidth',2.0);
plot(slpc(2,:),'r','linewidth',2.0);
hh=0;dd=14;
yrange=get(gca,'Ylim');
for it=1:12
    hh=hh+6;
    if(hh>=24)
       hh=hh-24
       dd=dd+1;
       text(it,yrange(1)-0.075*(yrange(2)-yrange(1)),['09/',num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',12,'fontweight','bold');
    end
    xt{it}=num2str(hh,'%2.2d');
    day{it}=num2str(dd,'%2.2d');
end
ylabel('Sea-leval Pressure','Fontsize',12);
set(gca,'Xtick',[1:12],'Xticklabel',xt,'fontsize',12);
h=legend('True','Background','Analysis')
set(h,'fontsize',12,'location','southwest')
legend('boxoff')

