%
% by Shu-Chih Yang 2009 Jul06

%function [ve,vez,ve_m,vez_m,eta,lonc,latc]=steering_z(file,yyyy,mm,dd,hh,levs,lonc0,latc0)
%file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_3day';
addpath('/work/ailin/matlab/windbarb/');
%file='/SAS001/ailin/exp09/osse/e01/AVG//wrfout_d01_2006-09-15_12:00:00.avg'
ihh=12;
idd=15;
%file='/SAS001/ailin/exp09/osse/e01/AVG//wrfout_d01_2006-09-15_12:00:00.avg'
for it=1:11

lonc0=-1;
latc0=-1;
yyyy='2006';
mm='09';
dd=num2str(idd,'%2.2d');
hh=num2str(ihh,'%2.2d');
%hh='12';

if(dd=='15')
  file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_2day';
  elseif(dd=='16')
file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_3day';
 elseif(dd=='17')
 file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_4day';
end

%% define the constant pressure levels
levs=[85000,80000,75000,70000,65000,60000,55000,50000 ,  45000 , 40000 ,  35000 ,...
       30000 ];%, 25000 ];
constants;
global Re rad;
tag=[yyyy,'-',mm,'-',dd,'_',hh,':00:00']
nz=length(levs);
xc=122.50;yc=22.0; %initial guess for the center
%132.95,18.2
dlat=12;
dlon=12;
time=getnc(file,'Times');
n=0;
for jt=1:size(time,1)
    if (time(jt,:)==tag);n=jt;end
end
if(size(time,1)*size(time,2)==19);n=1;end
disp(['Time No.=',num2str(n)])
if(n<=0) 
  disp('No valid time found')
  ve(1:2)=NaN;
  lonc=NaN;
  latc=NaN;
  return
end

xlon=getnc(file,'XLONG');
ylat=getnc(file,'XLAT');
eta=getnc(file,'ZNU');
if(size(eta,2)>1) 
   xlontmp=xlon;
   ylattmp=ylat;
   etatmp=eta;
   clear xlon ylat eta;
   xlon=squeeze(xlontmp(1,:,:));
   ylat=squeeze(ylattmp(1,:,:));
   eta=squeeze(etatmp(1,:));
   clear xlontmp ylattmp etatmp;
end
    [u,v,w,th,qv,temp,slp,pressure]=getnc_varsp(file,n,xlon,ylat,eta);
    if(lonc0<0)
    ind1=find( abs(xlon-xc)<=dlon);
    ind2=find( abs(ylat(ind1)-yc)<=dlat);
    ind=ind1(ind2);
    xs=xc-dlon:0.2:xc+dlon;
    ys=yc-dlat:0.2:yc+dlat;
    [xg,yg]=meshgrid(xs,ys);
    nx=size(xg,1);
    ny=size(xg,2);
    pss=reshape(slp,size(slp,1)*size(slp,2),1);
    psi=griddata(double(ylat(ind)),double(xlon(ind)),double(pss(ind)),yg,xg,'linear');
    %contourf(xg,yg,psi)
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
      %if(yg(iy,ix)< 18.5 | xg(iy,ix)<124.0 );
      %   ifound=1;
      %   psi(iy,ix)=max(max(psi));
      %else
         ifound=0;
      %end
    end
    lonc=xg(iy,ix);
    latc=yg(iy,ix);
    else
      lonc=lonc0;
      latc=latc0;
    end
ry=Re*rad*(latc-yg);
rx=Re*cos(rad*0.5*(latc+yg(:,:))).*(rad*(xg-lonc));
r=sqrt(rx.^2+ry.^2);
mask=ones(size(xg));
mask(find(r> 500.0 | r< 100.0))=0;

p2d=reshape(pressure,size(pressure,1),size(pressure,2)*size(pressure,3));
%figure(1);clf
%plot([lonc lonc],[latc latc],'X');hold on
%axis([lonc-5 lonc+5 latc-5 latc+5])

for nvar=1:2
    sum_p=0.0;
    sum_vp=0.0;
    sum_vpz=zeros(nz,1);
    sum_A=0.0;
    if(nvar==1) 
       vel=u;
    else
       vel=v;
    end    
    v2d=reshape(vel,size(vel,1),size(vel,2)*size(vel,3));
    for iz=1:size(vel,1)
        %if(nvar==1)...
        %pp2d(iz,:,:)=griddata(double(ylat(ind)),double(xlon(ind)),double(p2d(iz,ind)),yg,xg,'linear');
        %end
        vv2d(iz,:,:)=mask.*griddata(double(ylat(ind)),double(xlon(ind)),double(v2d(iz,ind)),yg,xg,'linear');
    end
    if(nvar==1)
       u2d=vv2d;
    else
       v2d=vv2d;
    end
end
uez(:,it)=nansum(nansum(u2d,3),2)/nansum(nansum(mask,2),1);
vez(:,it)=nansum(nansum(v2d,3),2)/nansum(nansum(mask,2),1);

ihh=ihh+6;
if(ihh>=24)
idd=idd+1;
ihh=ihh-24;
end
end
save truth_steeringnew_Ro500Ri100.mat vez uez;
return

quiver(xg(1:10:end,1:10:end)',yg(1:10:end,1:10:end)',squeeze(u2d(12,1:10:end,1:10:end))',squeeze(v2d(12,1:10:end,1:10:end))');hold on

for nbar=1:2

    dR=50;
    R1=50;
    R2=500;
    
    NR=(R2-R1)/dR+1;
    Ntheta=(359-0)/1+1;
    vez_m(nvar,1:size(vv2d,1))=0.0;
    vi=zeros(NR,Ntheta,nz);
    for RR=R1:dR:R2
    %for theta=0:0.5:359
    for theta=0:1:359
        ir=(RR-R1)/dR+1;
        ithe=theta/1+1;
        dy=RR*cos(theta*rad);
        dx=RR*sin(theta*rad);
        lat(ithe)=dy/(Re*rad)+latc;
        lon(ithe)=dx/(Re*cos(rad*0.5*(lat(ithe)+latc))*rad)+lonc;
        rmin=1.e10;
        %for jj=1:ny
        %for ii=1:nx
        %    if(isnan(psi(jj,ii))==1);continue;end
        %    ry=Re*rad*(lat-yg(jj,ii));
        %    rx=Re*cos(rad*0.5*(lat+yg(jj,ii)))*rad*(xg(jj,ii)-lon);
        %    r(jj,ii)=sqrt(rx.^2+ry.^2);
        %    if( r(jj,ii)< rmin)
        %        rmin=r(jj,ii);
        %        js=jj;
        %        is=ii;
        %    end
        %end
        %end
        %if( sum(isnan(pp2d(:,js,is)))<5)
        %vi(ir,ithe,:)=interp1(log(squeeze(pp2d(:,js,is))),squeeze(vv2d(:,js,is)),log(levs));
        %%disp([js is lat lon ir ithe vi(ir,ithe,3)])
        plot([lon lon],[lat lat],'.');hold on
        %else
        %vi(ir,ithe,1:nz)=NaN;
        %end
        % perform vertical integration
        %for iz=1:nz-1
        %    if( sum(isnan(vi(ir,ithe,iz:iz+1)))==0)
        %      sum_p=sum_p+levs(iz)-levs(iz+1);
        %      sum_vp=sum_vp+(levs(iz)-levs(iz+1))*0.5*(vi(ir,ithe,iz+1)+vi(ir,ithe,iz));
        %    end
        %end
    end
        for iz=1:size(vv2d,1)
            vvr(:,iz)=interp2(xg,yg,squeeze(vv2d(iz,:,:)),lon,lat);
            ppr(:,iz)=interp2(xg,yg,squeeze(pp2d(iz,:,:)),lon,lat);
            vez_m(nvar,iz)=vez_m(nvar,iz)+nansum(reshape(vvr(:,iz),Ntheta,1));
        end
            %[RR,std(ppr(:,1)*0.01)
        if( std(ppr(:,1)*0.01)<5 )
            for ithe=1:360
            if( sum(isnan(ppr(ithe,:)))<6)
               vi(ir,ithe,:)=interp1(log(squeeze(ppr(ithe,:))),squeeze(vvr(ithe,:)),log(levs));
            else
               vi(ir,ithe,1:nz)=NaN;
            end
            end
        else
               vi(ir,:,1:nz)=NaN;
        end
        %plot(lon,lat,'x')
    end
        %plot(lonc,latc,'kx')
    ve_m(nvar)=sum(vez_m(nvar,8:17))/(Ntheta*NR*8);
    for iz=1:size(vv2d,1)
       vez_m(nvar,iz)=vez_m(nvar,iz)/(Ntheta*NR);
    end

    for iz=1:nz
        sum_A(iz)=0.0;
        for ir=1:(R2-R1)/dR
            if(sum(isnan(squeeze(vi(ir,:,iz))))==0)
%               for ithe=1:359/1
%                  %sum(isnan(reshape(vi(ir:ir+1,ithe:ithe+1,iz),2*2,1)))
%                  %if( sum(isnan(reshape(vi(ir:ir+1,ithe:ithe+1,iz),2*2,1)))==0)
%                  vc=0.25*(vi(ir,ithe,iz)+vi(ir,ithe+1,iz)+vi(ir+1,ithe,iz)+vi(ir+1,ithe+1,iz));
%                  sum_vpz(iz)=sum_vpz(iz)+vc*dR*1.*(pi/180);
%                  sum_A=sum_A+dR*1.*(pi/180);
%                  %else
%                  %disp([ir ithe iz])
%                  %end
%              end
            sum_vpz(iz)=sum_vpz(iz)+sum(vi(ir,:,iz));
            sum_A(iz)=sum_A(iz)+360;
            end
        end
        %vez(nvar,iz)=sum_vpz(iz)/sum_A;
        vez(nvar,iz)=nanmean(reshape(vi(:,:,iz),NR*Ntheta,1));
    end
    %mz=max(find((levs-50000.0)>0));
    %sum_p=0.0
    %sum_vp=0.0
    %for iz=1:nz-1
    %%for iz=1:mz
    %    sum_p=sum_p+sum_A*(levs(iz)-levs(iz+1));
    %    sum_vp=sum_vp+(levs(iz)-levs(iz+1))*0.5*(sum_vpz(iz+1)+sum_vpz(iz));
    %end
    %ve(nvar)=sum_vp/sum_p;
    
     ve(nvar)=nanmean(reshape(vi,NR*Ntheta*nz,1));
end
