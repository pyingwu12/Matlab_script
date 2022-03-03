
%   plot the fcst and analysis errors
%
clear all
figure(2);clf
%close all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
% obs locations
loc(1,:)=[124.2000; 22.4000]; obs(1,:)=[957.0000;-12.0351; -44.9156];%[977.0000; -10.8704;  -40.5689];
loc(2,:)=[124.3000; 22.2000]; obs(2,:)=[944.0000     -17.9613     -38.5181];%[969.0000;  -9.8351;  -36.7052];
loc(3,:)=[124.7000; 21.9000]; obs(3,:)=[925.0000;  0.2588;   0.9659];%[938.0000;   0.6840;    1.8794];
loc(4,:)=[124.9000; 21.8000]; obs(4,:)=[925.0000;  6.5986;  37.4227];%[946.0000;  -3.0069;   34.3687];
loc(5,:)=[125.4000; 21.3000]; obs(5,:)=[960.0000;  8.3351;  47.2708];%[975.0000;   0.0000;   36.0000];
loc(6,:)=[125.6000; 21.0000]; obs(6,:)=[970.0000; 13.3125;28.5487];[977.0000;   8.5410;   31.8756];%[986.0000;   9.7476;   26.7812];
loc(7,:)=[126.0000; 20.7000]; obs(7,:)=[986.0000;  11.1994;   24.0172];%[993.0000;  10.5655;   22.6577];
%loc(8,:)=[123.6000; 22.9000]; obs(8,:)=[993.0000      -4.6017     -26.0974];
%loc(9,:)=[124.8000; 21.9000]; obs(9.:)=[938.0000      -2.7189      -1.2679];

% fiure setting
%geolocation setting
dlon=0.5;
dlat=0.5;

%expmain='/work/scyang/WRFEXPS/exp06/wrf_real_input_bdy/'; % truth for exp06
%file_t=strcat([expmain,'../initial/init_pert18/wrf_3dvar_input_d01_'],tag)
dom='d01';

switch(dom)
case('d01')
   expmain='/SAS002/scyang/WRFEXPSV3/sinlaku/e76/output/'
   file0='wrfanal_d01_2008-09-09_06:00:00';
   lat1=16.; lat2=26.5;
   lon1=120.5;lon2=129;
end
%[lon,lat]=meshgrid([lon1:dlon:lon2],[lat1:dlat:lat2]);
xlon  =getnc([expmain,file0],'XLONG');
ylat  =getnc([expmain,file0],'XLAT');
eta  = getnc([expmain,file0],'ZNU');
var={'T';'U';'V';'QVAPOR';'PSFC'};
%maindir{1}='/SAS002/scyang/WRFEXPSV3/sinlaku/e76/output/';
maindir{2}='/SAS002/scyang/WRFEXPSV3/sinlaku/e76/output/';
maindir{1}='/SAS002/scyang/WRFEXPSV3/sinlaku/e76-RIP/output/';

dx=0.35; dy=0.23;
row=2;
column=4;
dd=11;
hh=12;
%for j=1:column
xc=124.5;
yc=22;
for j=1:1
   tag=['2008-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
   file_a=strcat([maindir{1},'wrffcst_',dom,'_'],[tag,'.2'])
   file_b=strcat([maindir{2},'wrffcst_',dom,'_'],[tag,''])
   file_t=strcat([maindir{1},'wrffcst_',dom,'_'],[tag,''])
   for i=1:row
       switch(i)
       case(1)
         infile=file_a;
         tit=strcat('LETKF-RIP');
         %tit=strcat('3-hr FCST');
       case(2)
         infile=file_b;
         tit=strcat('LETKF');
       case(3)
         %infile=file_t;
         infile=file_a;
         %tit=strcat('TRUTH');
         tit=strcat('DIFF');
       end
   
       %check the time
       times=getnc(infile,'Times');
       n=1;
       if(size(times,1)*size(times,2)>19)
          for jt=1:length(times)
            if( times(jt,:)==tag)
                n=jt;
            end
          end
       end
    
       
       [utmp,vtmp,w,th,qv,temp,slp,pressure]=getnc_varsfew(infile,n,xlon,ylat,eta);
       if(i==1);pressure0=pressure;end
       %% fine the TC center
       %----------------------------------------------------------------------------
       ind1=find( abs(xlon-xc)<=7.5);
       ind2=find( abs(ylat(ind1)-yc)<=7.5);
       ind=ind1(ind2);
       dlat=4.;
       xs=xc-dlat:0.2:xc+dlat;
       ys=yc-dlat:0.2:yc+dlat;
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
       lonc=xg(iy,ix)
       latc=yg(iy,ix)
       slpc=slp_c
       %----------------------------------------------------------------------------
      
       % interpolate
       %----------------------------------------------------------------------------

       nz=1;
       dlat=1.;
       for ivar=1:3
          switch (ivar)
          case(1)
            model_var=utmp;
          case(2)
            model_var=vtmp;
          case(3)
            model_var=0.01*pressure;
          end
          for ll=1:size(loc,1)
              ind1=find( abs(xlon-loc(ll,1))<=2.0);
              ind2=find( abs(ylat(ind1)-loc(ll,2))<=2.0);
              ind=ind1(ind2);
              xs=loc(ll,1)-dlat:0.2:loc(ll,1)+dlat;
              ys=loc(ll,2)-dlat:0.2:loc(ll,2)+dlat;
              [xg,yg]=meshgrid(xs,ys);
              for nz=1:14
                  var2d=squeeze(model_var(nz,:,:));
                  varss=reshape(var2d,size(var2d,1)*size(var2d,2),1);
                  varsi=griddata(double(ylat(ind)),double(xlon(ind)),double(varss(ind)),yg,xg,'linear');
                  %loc_var(ll,ivar,nz,i)=varsi( (size(xg,1)+1)/2,(size(xg,1)+1)/2);
                  var1d(ll,nz,ivar)=varsi( (size(xg,1)+1)/2,(size(xg,1)+1)/2);
              end
          end
       end
       for ll=1:size(loc,1)
          u_interp(ll)=interp1(var1d(ll,:,3),var1d(ll,:,1),obs(ll));
          v_interp(ll)=interp1(var1d(ll,:,3),var1d(ll,:,2),obs(ll));
       end
          % perform vertical integration
       ws_mod(:,i)=sqrt(u_interp.^2+v_interp.^2);

       %----------------------------------------------------------------------------
       %si=sqrt(squeeze(utmp(nz,:,:)).^2+squeeze(vtmp(nz,:,:)).^2);
       si=sqrt(squeeze(utmp(3,:,:)).^2+squeeze(vtmp(3,:,:)).^2);
       if(i==1);si0=si;end
       %si=squeeze(w(3,:,:))*5;
       %si=squeeze(th(1,:,:))-290;
       %iplt=i;
       %ii=mod(i,column);
       %if(ii==0);ii=column;end
       %x1=-0.03+(j-1)*0.7*dx;
       %y1=0.1+(4-i-1)*1.3*dy;
       %axes('position',[x1 y1 dx dy])
       %m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
       %m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
       %hold on
       %%[c,h]=m_contourf(xlon,ylat,squeeze(si),[0:1.25:25]); 
       %%caxis([0 25]);hold on
       %col=jet(40);
       %%col=jet(24);
       %col(end,:)=[0.75,0.75,0.75];
       %colormap(col);
       %%m_coast('patch','color',[0.2 .2 0.2],'linewidth',2.0);
       %set(gca,'Fontsize',10)
       %Time=[tag(6:13),'Z'];
       %Time(3)='/';Time(6)=' ';
       %m_text(0.5*(lon1+lon2),lat2+0.01*(lat2-lat1),[Time,' (',tit,')'],...
       %'horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
       %%m_text(xc,yc,'X','horizontalalignment','center','VerticalAlignment','bottom','fontsize',12,'fontweight','bold')
       %clear si
       clear S;
       %if(i==1 &j==1)
       %   hbar=colorbar('horiz');
       %   set(hbar,'position',[0.06 0.032 0.9 0.02],'XTick',[0:3:30]);
       %   set(gcf,'Paperorientation','landscape','paperposition',[0.75 0. 9.5 8.5])
       % end
   end %i
   Date=tag(1:10);
   Time=tag(12:19);
   hh=hh+06;
   if(hh>=24)
      dd=dd+1;
      hh=hh-24;
   end
end % j
return
ws_obs=sqrt(squeeze(obs(:,2)).^2+squeeze(obs(:,3)).^2);
subplot(2,1,1)
plot(ws_mod(:,1),'k');hold on
plot(ws_mod(:,2),'r');hold on
plot(ws_obs(:),'ro','markersize',10);
%subplot(2,1,2)
%plot(0.01*loc_var(:,3,1),'k');hold on
%plot(0.01*loc_var(:,3,2),'r');hold on
%plot(obs(:,1),'ro','markersize',10);hold on
