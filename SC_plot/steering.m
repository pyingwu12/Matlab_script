%
% by Shu-Chih Yang 2009 Jul06

function [ve,lonc,latc]=steering(file,yyyy,mm,dd,hh,lonc0,latc0)
%file='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/wrfout_d01_2006-09-14_00:00:00_28_3day';
%lonc0=-1;
%latc0=-1;
%yyyy='2006';
%mm='09';
%dd='16';
%hh='06';
constants;
global Re rad;
tag=[yyyy,'-',mm,'-',dd,'_',hh,':00:00'];
% define the constant pressure levels
levs=[85000,80000,75000,70000,65000,60000,55000,50000 ,  45000 , 40000 ,  35000 ,...
       30000 ];%, 25000 ];
nz=length(levs);
xc=124.0;yc=22.0; %initial guess for the center
%132.95,18.2
dlat=7.5;
dlon=7.5;
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

p2d=reshape(pressure,size(pressure,1),size(pressure,2)*size(pressure,3));
%figure(1);clf
%plot([lonc lonc],[latc latc],'X');hold on
%axis([lonc-5 lonc+5 latc-5 latc+5])
for nvar=1:2
    sum_p=0.0;
    sum_vp=0.0;
    if(nvar==1) 
       vel=u;
    else
       vel=v;
    end    
    v2d=reshape(vel,size(vel,1),size(vel,2)*size(vel,3));
    for iz=1:size(vel,1)
        if(nvar==1)...
        pp2d(iz,:,:)=griddata(double(ylat(ind)),double(xlon(ind)),double(p2d(iz,ind)),yg,xg,'linear');
        end
        vv2d(iz,:,:)=griddata(double(ylat(ind)),double(xlon(ind)),double(v2d(iz,ind)),yg,xg,'linear');
    end

    indr=zeros(10,360);
    for RR=50:50:500
    for theta=0:0.5:359
        ir=(RR-50)/50+1;
        ithe=theta/0.5+1;
        dy=RR*cos(theta*rad);
        dx=RR*sin(theta*rad);
        lat=dy/(Re*rad)+latc;
        lon=dx/(Re*cos(rad*latc)*rad)+lonc;
        rmin=1.e10;
        for jj=1:ny
        for ii=1:nx
            if(isnan(psi(jj,ii))==1);continue;end
            ry=Re*rad*(lat-yg(jj,ii));
            rx=Re*cos(rad*0.5*(lat+yg(jj,ii)))*rad*(xg(jj,ii)-lon);
            r(jj,ii)=sqrt(rx.^2+ry.^2);
            if( r(jj,ii)< rmin)
                rmin=r(jj,ii);
                js=jj;
                is=ii;
            end
        end
        end
        if( sum(isnan(pp2d(:,js,is)))<5)
        vi(ir,ithe,:)=interp1(log(squeeze(pp2d(:,js,is))),squeeze(vv2d(:,js,is)),log(levs));
        %disp([js is lat lon ir ithe vi(ir,ithe,3)])
        %plot([lon lon],[lat lat],'.');hold on
        else
        vi(ir,ithe,1:nz)=NaN;
        end
        % perform vertical integration
        for iz=1:nz-1
            if( sum(isnan(vi(ir,ithe,iz:iz+1)))==0)
              sum_p=sum_p+levs(iz)-levs(iz+1);
              sum_vp=sum_vp+(levs(iz)-levs(iz+1))*0.5*(vi(ir,ithe,iz+1)+vi(ir,ithe,iz));
            end
        end

    end
    end
    ve(nvar)=sum_vp/sum_p;
end
