constants;
global Re rad;
reread=0;

if(reread==1)
clear all
clf
addpath('/work/scyang/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');

file0='/SAS001/ailin/SHAND25/PT37_2/wrfinput_d01_148179_0_28';
xlon=getnc(file0,'XLONG');
ylat=getnc(file0,'XLAT');
eta=getnc(file0,'ZNU');
nx=size(xlon,2);
ny=size(xlon,1);
nz=length(eta);
in1z=1:26;in2z=in1z+1;
zg=zeros(nz,ny,nx);
pressure=zeros(nz,ny,nx);
nens=36;
run=nens;
iplt=1;
it=1;
hh=12;
dd=15;
nt=12;
expdir{1}='/SAS001/ailin/exp09/osse/e01/fcst1512/'
tag{1}=['2006-09-14_00:00:00'];
tag{2}=['2006-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
%m_proj('lambert','long',[115 135],'lat',[15 30]); hold on
m_proj('lambert','long',[115 144],'lat',[12 42]); hold on
m_grid('linest','--','box','fancy','tickdir','in');
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
xc=124.0;yc=20.0;
hold on
for i=1:run
    %if(i>1 & i< run-1)
       file=[expdir{1},'wrfout_d01_',tag{2},'_',num2str(i)];
       interval=1;
    %elseif(i==1)
    %   %file=[expdir{1},'wrfout_d01_',tag{1}];
    %   file=file0;
    %   interval=2;
    %end
    time=getnc(file,'Times');
    for it=1:size(time,1)
        if (time(it,:)==tag{2});n0=it;end
    end
    it=0;
    %for n=n0:interval:n0+interval*nt-interval
    for n=6:6
        it=it+1;
        ph=getnc(file,'PH',[n -1 -1 -1],[n -1 -1 -1]);
        ps=getnc(file,'PSFC',[n -1 -1],[n -1 -1]);
        phb=getnc(file,'PHB',[n -1 -1 -1],[n -1 -1 -1]);
        qv=getnc(file,'QVAPOR',[n -1 -1 -1],[n -1 -1 -1]);
        th=getnc(file,'T',[n -1 -1 -1],[n -1 -1 -1])+300;
        zgtmp=squeeze((ph+phb)/9.81);
        zg=0.5*(zgtmp(in1z,:,:)+zgtmp(in2z,:,:));
        for z=1:length(eta)
            pressure(z,:,:)=5000.0+(ps-5000.0).*eta(z);
        end
        temp=wrf_tk(pressure,th,'K');
        slp=calc_slp(pressure,zg,temp,qv);

        %if(it>3);yc=27;end
        ind1=find( abs(xlon-xc)<=10.0);
        ind2=find( abs(ylat(ind1)-yc)<=10.0);
        ind=ind1(ind2);
        if(it<=3)
           dlat=5.0;
        else
          dlat=9.5;
        end
        xs=xc-dlat:0.25:xc+dlat;
        ys=yc-dlat:0.25:yc+dlat;
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
   %switch (i)
   %case(1)
   %   h1=m_plot(lonc(1,:),latc(1,:),'-kx','linewidth',2.);hold on
   %case(run)
   %   h2=m_plot(lonc(i,:),latc(i,:),'-bx','linewidth',2.);
   %otherwise
      h=m_plot(lonc(i,:),latc(i,:),'rx','linewidth',.5);
   %end
end
%hl=m_legend([h1,h2],'Truth','Mean forecast');
%set(hl,'fontsize',14)
%loncs=lonc;
%latcs=latc;
end
%load /SAS001/ailin/exp09/osse/e01/AVG/Fcst1512Track.mat;
    %m_plot(lonc(3,:),latc(3,:),'-k+');%,'horizontalalignment','center','VerticalAlignment','middle','fontsize',12,'fontweight','bold')
h=m_plot(lonc(3),latc(3),'kx','markersize',8);
ir=0;
radius_p=0;
while( radius_p==0)
   radius=50+25*ir;
   rys=Re*rad*(latcs(:)-latc(6));
   rxs=Re*cos(rad*latc(6))*rad*(loncs(:)-lonc(6));
   rs=sqrt(rys.^2+rxs.^2);
   nvalid=length(find(rs<radius));
   if(nvalid> 25)
      radius_p=radius;
   end
   ir=ir+1;
end
for s=1:360
    ry=radius_p*sin(s*pi/180.);
    rx=radius_p*cos(s*pi/180.);
    ylat=ry/(Re*rad)+latc(6);
    xlon=rx/(Re*cos(rad*latc(6))*rad)+lonc(6);
    h=m_plot(xlon,ylat,'-k.','linewidth',.5);
end
return
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

