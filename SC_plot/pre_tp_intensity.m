%function fcsttrack_fixexp09(t_fcst,track)
track=0;
t_fcst=0;
addpath('/work/scyang/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');
constants;
global Re rad;
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
iplt=1;
it=1;
hh=06;
dd=14;
%t_fcst=24; %forecast legnth
expdir{1}='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/';
tag{1}=['2006-09-14_00:00:00'];
%expdir{2}='/SAS001/ailin/exp09/E28_2/e02/AVG/'; %k
%expdir{3}='/SAS001/ailin/exp09/E28_2/e02RIPK-1/AVG/'; %k
expdir{2}='/SAS001/ailin/exp09/osse/e01/AVG/'; %k
expdir{3}='/SAS001/ailin/exp09/osse/e03/AVG/'; %k
run=1;

%m_proj('lambert','long',[115 135],'lat',[15 30]); hold on
figure(1);clf

for it=1:16
    hh_f=hh;
    dd_f=dd;
    hh_f=hh_f+t_fcst;
    while( hh_f >= 24)
      hh_f=hh_f-24;
      dd_f=dd_f+1;
    end
    tag0=['2006-09-',num2str(dd_f,'%2.2d'),'_',num2str(hh_f,'%2.2d'),':00:00'];
    xc=124.0;yc=20.0;
    if(it>3)
       yc=yc+3;
    end
    for i=1:run
        if(i==1)
          %file=[expdir{1},'wrfout_d01_',tag{1}];
          %file=[expdir{1},'wrfout_d01_2006-09-14_00:00:00'];
          file=[expdir{1},'wrf_3dvar_input_d01_',tag0,'_28']
        else
          tag{2}=['2006-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
          file=[expdir{i},'/wrfout_d01_',tag{2},'.avg']
        end
        time=getnc(file,'Times');
        n=1;
        if(size(time,1)*size(time,2)>19)
        for jt=1:size(time,1)
            if (time(jt,:)==tag0);n=jt;end
        end
        end
        tag0,n
        ph=getnc(file,'PH',[n -1 -1 -1],[n -1 -1 -1]);
        ps=getnc(file,'PSFC',[n -1 -1],[n -1 -1]);
        phb=getnc(file,'PHB',[n -1 -1 -1],[n -1 -1 -1]);
        qv=getnc(file,'QVAPOR',[n -1 -1 -1],[n -1 -1 -1]);
        th=getnc(file,'T',[n -1 -1 -1],[n -1 -1 -1])+300;
        slp=getslp(ps,ph,phb,qv,th,eta);
        utmp=getnc(file,'U',[n -1 -1 -1],[n -1 -1 -1]);
        vtmp=getnc(file,'V',[n -1 -1 -1],[n -1 -1 -1]);
        in1=1:size(xlon,1);
        in2=in1+1;

        ind1=find( abs(xlon-xc)<=10.0);
        ind2=find( abs(ylat(ind1)-yc)<=10.0);
        ind=ind1(ind2);
        dlat=5.5;
        %xs=xc-dlat:0.25:xc+dlat;
        %ys=yc-dlat:0.25:yc+dlat;
        xs=xc-dlat:0.25:xc+dlat;
        ys=yc-dlat:0.25:yc+dlat;
        [xg,yg]=meshgrid(xs,ys);
        pss=reshape(slp,size(slp,1)*size(slp,2),1);
        %psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'linear');
        psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'cubic');
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
        ry=Re*rad*(ylat-latc(i,it));
        rx=Re*cos(rad*latc(i,it))*rad*(xlon-lonc(i,it));
        r=sqrt(rx.^2+ry.^2);
        min(min(r))
        [ic,jc]=find(r< 50.00);
        rmin=1.e10;
        size(ic,1)
        for k=1:size(ic,1)
            if(r(ic(k),jc(k))<rmin);
               ii=ic(k);
               jj=jc(k);
               rmin=r(ic(k),jc(k));
            end
        end
        u=0.5*(utmp(:,:,in1)+utmp(:,:,in2));
        v=0.5*(vtmp(:,in1,:)+vtmp(:,in2,:));
        inc=20;
        wsbox=sqrt((u(:,ii-inc:ii+inc,jj-inc:jj+inc).^2+v(:,ii-inc:ii+inc,jj-inc:jj+inc).^2));
        maxws(i,it)=max(max(max(wsbox)))
    end
    if (i>2)
    ry=Re*rad*(latc(1,it)-latc(2,it));
    rx=Re*cos(rad*latc(1,it))*rad*(lonc(1,it)-lonc(2,it));
    d(it)=sqrt(rx.^2+ry.^2);
    dslp(it)=abs(slpc(2,it)-slpc(1,it));
    end
    hh=hh+6;
    if(hh>=24)
       dd=dd+1;
       hh=hh-24;
    end
end
if(track>0)
figure
m_proj('miller','long',[115 135],'lat',[15 30]); hold on
m_grid('linest','--','box','fancy','tickdir','in');
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
hold on
h1=m_plot(lonc(1,:),latc(1,:),'-k','linewidth',3.0);hold on
h2=m_plot(lonc(2,:),latc(2,:),'-b','linewidth',2.,'markersize',12);
h3=m_plot(lonc(3,:),latc(3,:),'-r','linewidth',2.,'markersize',12);
title([num2str(t_fcst),'hr Forecast'],'Fontsize',14,'Fontweight','bold');
end
%legs={'Truth';'Without RIP';'With RIP'};
%lines={'-k';'-b';'-r';'-r';'--r'};
%for l=1:run
%   yy=20.5-(l-1)*0.6;
%   m_plot([125.5,125.75],[yy yy],lines{l},'linewidth',2.0)
%   m_text(126,yy,legs{l},'fontsize',12,'horizontalalignment','left','VerticalAlignment','middle')
%end
%set(hl,'Position',[90 20 30. 7.5]);
%for l=1:length(tl)
%    set(tl(l),'Fontsize',12)
%end
%pfile=['ftrack_expe02_',num2str(t_fcst,'%2.2d'),'hr_091400-091700.ps'];
%eval(['print -dpsc -f1 ',pfile])
figure(2);
plot(maxws(1,:),'color',[0.7 0.7 0.7],'linewidth',3.0);;hold on
plot(maxws(2,:),'k','linewidth',3);
plot(maxws(3,:),'r','linewidth',3.);
%axis([1 8 938 995])
axis([1 8 20 80])
yrange=get(gca,'Ylim');
set(gca,'Xlim',[1 8]);
hh=0+t_fcst;
dd=14;
while (hh>=24)
   hh=hh-24
   dd=dd+1;
end
for it=1:8
    hh=hh+6;
    if(hh>=24)
       hh=hh-24
       dd=dd+1;
       text(it,yrange(1)-0.075*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
    end
    xt{it}=num2str(hh,'%2.2d');
    day{it}=num2str(dd,'%2.2d');
    if(it==1)
       text(it,yrange(1)-0.075*(yrange(2)-yrange(1)),[num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14);
    end
end
text(4.5,yrange(1)+1.075*(yrange(2)-yrange(1)),[num2str(t_fcst),'-HR Forecast'],'verticalalignment','top','Fontsize',16,'horizontalalignment','center')
ylabel('Sea-leval Pressure','Fontsize',16);
set(gca,'Xtick',[1:12],'Xticklabel',xt,'fontsize',14);
%h=legend('TRUTH','CNT','AL25','BW3S','BW1','AL25BW3','AL25BW3S')
h=legend('TRUTH','LETKF','LETKF-RIP')
set(h,'fontsize',10,'location','northeast')
legend('boxoff')

%pfile=['fslp_e27rip_',num2str(t_fcst,'%2.2d'),'hr_091406z-091500z.ps'];
%eval(['print -dpsc -f2 ',pfile])
