clear all
close all
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
run=3;
iplt=1;
it=1;
hh0=12; dd0=15;
hhi=hh0; ddi=dd0;
nt=1;
expdir{1}='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/';
expdir{2}='/SAS001/scyang/WRFEXPS/exp09/osse/e01/da_out/'; %k
expdir{3}='/SAS001/scyang/WRFEXPS/exp09/osse/e03/da_out/'; %k
%expdir{4}='/work/scyang/WRFEXPS/exp06/e02/';
Time_init=['2006-09-',num2str(dd0,'%2.2d'),' ',num2str(hh0,'%2.2d'),'Z'];
fcstlength=(nt-1)*6;

m_proj('Miller','long',[115 135],'lat',[15 30]); hold on
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
           file=strcat([expdir{1},'wrf_3dvar_input_d01_'],[tag0,'_28'])
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
        xc=125.0;yc=20.0;
        if(it<=3)
           dlat=5;
        else
          xc=122.0;yc=22.0;
          %dlat=7.5;
          dlat=5;
        end
        ind1=find( abs(xlon-xc)<=5);
        ind2=find( abs(ylat(ind1)-yc)<=5);
        ind=ind1(ind2);
        xs=xc-dlat:0.25:xc+dlat;
        ys=yc-dlat:0.25:yc+dlat;
        [xg,yg]=meshgrid(xs,ys);
        pss=reshape(slp,size(slp,1)*size(slp,2),1);
        %psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'linear');
        psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'cubic');
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
        if(i==1 & xg(iy,ix)> 126.0); 
           ifound=1;
           psi(iy,ix)=max(max(psi));
        else
           ifound=0;
        end
        end

        lonc(i,it)=xg(iy,ix);
        latc(i,it)=yg(iy,ix);
        slpc(i,it)=slp_c;
        %slpc(i,it)=min(min(pss));
        tag0
        [ lonc(i,it),latc(i,it),slpc(i,it)]
        else
        lonc(i,it)=NaN;
        latc(i,it)=NaN;
        slpc(i,it)=NaN;
        end
        figure(i+10)
        %subplot(3,3,it)
        minph=min(min(squeeze(phb(8,40:80,60:100)+ph(8,40:80,60:100))));
        maxph=max(max(squeeze(phb(8,40:80,60:100)+ph(8,40:80,60:100))));
        [c,h]=contourf(xlon,ylat,squeeze(phb(8,:,:)+ph(8,:,:)),[minph:(maxph-minph)/50:maxph]);hold on
        caxis([minph minph+20*(maxph-minph)/50])
        axis([123. 125. 19. 21.5])
        set(h,'edgecolor',[0.5 0.5 0.5])
        [c,h]=contour(xg,yg,psi,[min(min(psi)) min(min(psi))+0.125 min(min(psi))+0.25 min(min(psi))+0.5 min(min(psi))+1 min(min(psi))+2 min(min(psi))+3 min(min(psi))+4 max(max(psi))]); hold on
        set(h,'linestyle','-','edgecolor','w')
        text(lonc(i,it),latc(i,it),'X','horizontalalignment','center','verticalalignment','middle','color','b');
        text(lonc(1,it),latc(1,it),'o','horizontalalignment','center','verticalalignment','middle','color','w');
        drawnow

        hh=hh+6;
        if(hh>=24)
           dd=dd+1;
           hh=hh-24;
        end
   end
   figure(1)
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
title(['Typhoon Track'],'Fontsize',16,'Fontweight','bold');
[hl,tl]=m_legend([h1,h2,h3],'Truth','LETKF','LETKF-RIP');
set(hl,'position',[124 45 30 8],'fontsize',14)
set(gcf,'Paperorientation','landscape','paperposition',[0.5 0.25 11 8])
%legend('boxoff')
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
       text(it,yrange(1)-0.075*(yrange(2)-yrange(1)),['09/',num2str(dd)],'HorizontalAlignment','center','verticalAlignment','top','fontsize',14,'fontweight','bold');
    end
    xt{it}=num2str(hh,'%2.2d');
    day{it}=num2str(dd,'%2.2d');
end
ylabel('Sea-leval Pressure','Fontsize',16);
set(gca,'Xtick',[1:12],'Xticklabel',xt,'fontsize',14);
h=legend('True','LETKF','LETKF-RIP')
set(h,'fontsize',14,'location','northeast')
legend('boxoff')
tfile='track_ossee01e03.ps';
slpfile='slpc_ossese01e03.ps';
eval(['print -dpsc -f1 ',tfile])
eval(['print -dpsc -f2 ',slpfile])
