clear all
close all
clf
addpath('/work/scyang/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');

file0='/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/wrfinput_d01';
%file0='/mnt/ddal01/WRFEXPS/exp07B/wrfout_d01_2006-09-12_12:00:00'; %wrfout_d01_1212_1400';

xlon=getnc(file0,'XLONG');
%xlon=squeeze(xlon0(1,:,:));
ylat=getnc(file0,'XLAT');
%ylat=squeeze(ylat0(1,:,:));
eta=getnc(file0,'ZNU');
%eta=squeeze(eta0(1,:));
nx=size(xlon,2);
ny=size(xlon,1);
nz=length(eta);
in1z=1:26;in2z=in1z+1;
zg=zeros(nz,ny,nx);
pressure=zeros(nz,ny,nx);
run=5;
iplt=1;
it=1;
hh0=06; dd0=14;
hhi=hh0; ddi=dd0;
nt=9;
expdir{1}='/work5/ailin/exp06/TRUTH/dom1/';
expdir{2}='/mnt/ddal01/scyang/WRFEXPS/exp08/e03/da_out/';
expdir{3}='/work5/scyang/WRFEXPS/exp08/e03RIPA/da_out/';
expdir{4}='/work5/scyang/WRFEXPS/exp08/e03RIPB/da_out/';
expdir{5}='/work5/scyang/WRFEXPS/exp08/e04/da_out/';
%expdir{4}='/work/scyang/WRFEXPS/exp06/e02/';
Time_init=['2006-09-',num2str(dd0,'%2.2d'),' ',num2str(hh0,'%2.2d'),'Z'];
fcstlength=(nt-1)*6;

m_proj('lambert','long',[115 135],'lat',[15 30]); hold on
m_grid('linest','--','box','fancy','tickdir','in');
m_coast('color',[0.2 .2 0.2],'linewidth',2.0);
hold on
for i=1:run
    hh=hh0;
    dd=dd0;
    for it=1:nt
        tag0=['2006-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
        if(i==1)
           %file=[expdir{1},'wrfout_d01_2006-09-12_12:00:00'];
           file=strcat([expdir{1},'wrf_3dvar_input_d01_'],[tag0,''])
        else
           file=[expdir{i},'wrfanal_d01_',tag0];
           %file=[expdir{i},'wrffcst_d01_',tag0];
        end
        time=getnc(file,'Times');
        n=0;
        for jt=1:size(time,1)
            if (time(jt,:)==tag0);n=jt;end
        end
        if(n==0) 
           if(strfind(time',tag0)>0);n=1;end
        end

        if(n>0) 
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
        xc=124.0;yc=20.0;
        ind1=find( abs(xlon-xc)<=3);
        ind2=find( abs(ylat(ind1)-yc)<=3);
        ind=ind1(ind2);
        if(it<=3)
           dlat=3;
        else
          %xc=122.0;yc=22.0;
          %dlat=7.5;
          dlat=3;
        end
        xs=xc-dlat:0.25:xc+dlat;
        ys=yc-dlat:0.25:yc+dlat;
        [xg,yg]=meshgrid(xs,ys);
        pss=reshape(slp,size(slp,1)*size(slp,2),1);
        psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'linear');
        %check min is the location!!
        ifound=1;
        while ( ifound >0 )
        [slp_c,ic]=min(reshape(psi,size(psi,1)*size(psi,2),1) );
        iy=mod(ic,size(psi,2));
        ix=(ic-iy)/size(psi,2)+1;
        if(iy==0) 
           iy=size(psi,1);
           ix=ix-1;
        end
        if(yg(iy,ix)< 18.5); 
           ifound=1;
           psi(iy,ix)=max(max(psi));
        else
           ifound=0;
        end
        end

        lonc(i,it)=xg(iy,ix);
        latc(i,it)=yg(iy,ix);
        slpc(i,it)=slp_c;
        tag0
        [ lonc(i,it),latc(i,it),slpc(i,it)]
        else
        lonc(i,it)=NaN;
        latc(i,it)=NaN;
        slpc(i,it)=NaN;
        end

        hh=hh+6;
        if(hh>=24)
           dd=dd+1;
           hh=hh-24;
        end
   end
   switch (i)
   case(1)
   h1=m_plot(lonc(1,:),latc(1,:),'-kx','linewidth',4.0);hold on
   case(2)
   h2=m_plot(lonc(2,:),latc(2,:),'-bx','linewidth',2.0);
   case(3)
   h3=m_plot(lonc(3,:),latc(3,:),'-rx','linewidth',2.0);
   case(4)
   h4=m_plot(lonc(4,:),latc(4,:),'-gx','linewidth',2.0);
   case(5)
   h5=m_plot(lonc(5,:),latc(5,:),'-cx','linewidth',2.0);
   case(6)
   h6=m_plot(lonc(6,:),latc(6,:),'-cx','linewidth',2.0);
   end
end
title(['Analysis track'],'Fontsize',14,'Fontweight','bold');
%title(['6Hr forecast track'],'Fontsize',14,'Fontweight','bold');
%[hl,tl]=m_legend([h1,h2,h3],'Truth','E17','E17S');
%set(hl,'Position',[90 20 30. 7.5]);
%for l=1:length(tl)
%    set(tl(l),'Fontsize',12)
%end
    %m_plot(lonc(3,:),latc(3,:),'-k+');%,'horizontalalignment','center','VerticalAlignment','middle','fontsize',12,'fontweight','bold')
set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 11 8])
figure(2);clf
plot(slpc(1,:),'k','linewidth',2.0);;hold on
plot(slpc(2,:),'b','linewidth',2.0);
if(i>=3);plot(slpc(3,:),'r','linewidth',2.0);end
if(i>=4);plot(slpc(4,:),'--g','linewidth',2.0);end
if(i>=5);plot(slpc(5,:),'g','linewidth',2.0);end
hh=hhi-6;dd=ddi;
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
h=legend('True','E17','E17S')
set(h,'fontsize',12,'location','northeast')
legend('boxoff')
tfile='track_e17smooth.ps';
slpfile='slpc_e17smooth.ps';
%eval(['print -dpsc -f1 ',tfile])
%eval(['print -dpsc -f2 ',slpfile])
