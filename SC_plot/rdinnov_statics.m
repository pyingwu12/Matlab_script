clear all
figure(1);clf
iresid=1;
iinnov=0;
nvar=6;
nt=16;
if(nvar<=5)
  vert=0;
else
  vert=1;
end
for nf=1:1
switch (nf)
case(1)
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e44/innov/';
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/fnl/wrf_real/geo_2m/innov/';
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e27/innov/REF/';
   dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e38/innov/';
   ll='-';
   cc='k';
case(2)
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e21/innov/';

   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e02/innov/';
   dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e31/innov/';
   ll='-';
   cc='b';
case(3)
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e31/innov2/';
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e27/innov/BANGLE/';
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e27/innov/';
   ll='-';
   cc='r';
case(4)
   %dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e30/innov/';
   dir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e34/innov/';
   ll='-';
   cc='g';
end
mon=6;
dd=13;
hh=00;
nobs_m=0;
nobs_o=0;
for n=1:nt
clear file;
file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),':00:00'];
infile=[dir,file];
fid=fopen(infile,'r');
for i=1:6
    obs{i,n}.type=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
    obs{i,n}.var=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
    obs{i,n}.nobs=fscanf(fid,'%u',1); %*d %e %e %e %e\n',4);
    obs{i,n}.pres=zeros(obs{i,n}.nobs,1);
    obs{i,n}.yb1=zeros(obs{i,n}.nobs,1);
    obs{i,n}.yb2=zeros(obs{i,n}.nobs,1);
    obs{i,n}.innov=zeros(obs{i,n}.nobs,1);
    obs{i,n}.resid=zeros(obs{i,n}.nobs,1);
    nprf(i,1)=1;
    iprf=1;
    for j=1:obs{i,n}.nobs
        a=fscanf(fid,'%f %f %g %f %f %f\n',6);
        obs{i,n}.lon(j)=a(1);
        obs{i,n}.lat(j)=a(2);
        obs{i,n}.pres(j)=a(3);
        obs{i,n}.y(j)=a(4);
        obs{i,n}.yb1(j)=a(5);
        obs{i,n}.yb2(j)=a(6);
        obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
        obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
        if(i==6)
        if( obs{i,n}.lon(j)<= 122 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 25. &  obs{i,n}.lat(j)>= 15.)
            obs{i,n}.pres(j);
            nobs_m=nobs_m+1;
            pres_m(nobs_m)=obs{i,n}.pres(j);
            y_m(nobs_m)=obs{i,n}.y(j);
            if(pres_m(nobs_m)<200)
               [obs{i,n}.lon(j) obs{i,n}.lat(j)]
               [pres_m(nobs_m),n,j]
            end
        else
            nobs_o=nobs_o+1;
            pres_o(nobs_o)=obs{i,n}.pres(j);
            y_o(nobs_o)=obs{i,n}.y(j);
        end
        %if(j>1)
        %if( abs(a(1)-obs{i,n}.lon(j-1))>1.e-3 & abs(a(2)-obs{i,n}.lat(j-1))>1.e-3)
        %   iprf=iprf+1;
        %   nprf(i,iprf)=j;
        %end
        %end
        end
   end 
   if(i==nvar & n<=16)
    %zi=100:100:5000;
if(vert==1)
   zi=100:100:5000;
else
   zi=[100:100:700,750:50:1000];
end
   nz=length(zi);
   iprf=1;
   clear y yb x;
   jprf=0;
   jprf=jprf+1;
   y(iprf)=obs{i,n}.y(1);
   yb(iprf)=obs{i,n}.yb1(1);
   x(iprf)=obs{i,n}.pres(1);
   %if(n==1)
      lats(jprf)=obs{i,n}.lat(1);
      lons(jprf)=obs{i,n}.lon(1);
   %end
   for j=2:obs{i,n}.nobs
       if (abs(obs{i,n}.lon(j)-obs{i,n}.lon(j-1))<1.e-3 & abs(obs{i,n}.lat(j)-obs{i,n}.lat(j-1))<1.e-3 )
          iprf=iprf+1;
          y(iprf)=obs{i,n}.y(j);
          yb(iprf)=obs{i,n}.yb1(j);
          x(iprf)=obs{i,n}.pres(j);
          if(j==obs{i,n}.nobs)
          if(iprf>2)
          yi(jprf,1:nz)=interp1(x,y,zi);
          ybi(jprf,1:nz)=interp1(x,yb,zi);
          else
            yi(jprf,1:nz)=NaN;
            ybi(jprf,1:nz)=NaN;
          end
          end
       else
          if(iprf>3)
          yi(jprf,1:nz)=interp1(x,y,zi);
          ybi(jprf,1:nz)=interp1(x,yb,zi);
          else
            yi(jprf,1:nz)=NaN;
            ybi(jprf,1:nz)=NaN;
          end
          jprf=jprf+1
          iprf=1;
          lats(jprf)=obs{i,n}.lat(j);
          lons(jprf)=obs{i,n}.lon(j);
          %if ( abs(lons(jprf)-108.198)<= 1.e-3 &  abs(lats(jprf)-17.23)<1.e-3 );
          %     jprf
          %end
          clear x y yb;
          y(iprf)=obs{i,n}.y(j);
          yb(iprf)=obs{i,n}.yb1(j);
          x(iprf)=obs{i,n}.pres(j);
       end
   end
   end


end
fclose(fid);
hh=hh+6;
if(hh>=24)
   hh=hh-24;
   dd=dd+1;
end
end

valid=find( lons<= 122.5 &  lons>= 105 & lats<= 30. & lats>= 12.5);
invalid=find( lons> 122.5 |  lons< 105 | lats> 30. | lats< 12.5);   
%subplot(2,1,1)
for iz=1:length(zi)
    if( sum(1-isnan(yi(valid,iz)))>2)
    yi1(iz)=nanmean(yi(valid,iz));
    else
    yi1(iz)=nan;
    end
    if( sum(1-isnan(yi(invalid,iz)))>2)
    yi2(iz)=nanmean(yi(invalid,iz));
    else
    yi2(iz)=nan;
    end

    if( sum(1-isnan(ybi(valid,iz)))>2)
    ybi1(iz)=nanmean(ybi(valid,iz));
    else
    ybi1(iz)=nan;
    end
    if( sum(1-isnan(ybi(invalid,iz)))>2)
    ybi2(iz)=nanmean(ybi(invalid,iz));
    else
    ybi2(iz)=nan;
    end
end
subplot(1,2,1)
plot(yi1,zi,'-ro','linewidth',2.0);hold on
plot(yi2,zi,'-ko','linestyle','-')
plot(ybi1,zi,'-rx','linewidth',2.0);hold on
plot(ybi2,zi,'-kx','linestyle','-')
legend('MOIST(OBS)','OUTSIDE(OBS)','MOIST(MODEL)','OUTSIDE(MODEL)')
legend('boxoff')
set(gca,'ylim',[200 5000]);
xlabel('Bending Angle','fontsize',12)
ylabel('Altitude (m)','fontsize',12)
subplot(1,2,2)
plot(yi1,zi,'-ro','linewidth',2.0);hold on
plot(yi2,zi,'-ko','linestyle','-')
plot(ybi1,zi,'-rx','linewidth',2.0);hold on
plot(ybi2,zi,'-kx','linestyle','-')
legend('MOIST(OBS)','OUTSIDE(OBS)','MOIST(MODEL)','OUTSIDE(MODEL)')
legend('boxoff')
set(gca,'ylim',[200 2000]);
xlabel('Bending Angle','fontsize',12)
ylabel('Altitude (m)','fontsize',12)
set(gcf,'Paperorientation','landscape','paperposition',[0. 0. 11 8.5])
%print -dpsc bangle_moistbox.ps;
return
if(vert==1)
   z=0:100:5000;
else
   z=[100:100:700,750:50:1000];
end
innov=zeros(length(z),2);
resid=zeros(length(z),2);
ncount=zeros(length(z),1);
for n=1:nt
    for j=1:obs{nvar,n}.nobs 
        if(vert==1)
           nz=max(find(z<=obs{nvar,n}.pres(j)));
        else
           nz=max(find(z<=1.e-2*obs{nvar,n}.pres(j)));
        end
        if(obs{nvar,n}.pres(j)<1.e10)
        innov(nz,1)=innov(nz,1)+obs{nvar,n}.innov(j); 
        innov(nz,2)=innov(nz,2)+obs{nvar,n}.innov(j).^2; 
        resid(nz,1)=resid(nz,1)+obs{nvar,n}.resid(j); 
        resid(nz,2)=resid(nz,2)+obs{nvar,n}.resid(j).^2; 
        ncount(nz)= ncount(nz)+1;
        end
    end
end
%subplot(2,1,1)
if(vert==1)
 if(iinnov==0)
 plot(innov(:,1)./ncount(:),1.e-3*z,cc,'linewidth',1.0);hold on
 plot(sqrt(innov(:,2)./ncount(:)),1.e-3*z,cc,'linewidth',2.0);hold on
 end
 if(iresid==0)
 plot(resid(:,1)./ncount(:),1.e-3*z,cc,'linestyle','--');hold on
 plot(sqrt(resid(:,2)./ncount(:)),1.e-3*z,cc,'linestyle','--','linewidth',2.0);hold on
 end
 set(gca,'ylim',[0 5])
else
 if(iinnov==0)
 plot(innov(:,1)./ncount(:),-z,cc,'linewidth',1.0);hold on
 plot(sqrt(innov(:,2)./ncount(:)),-z,cc,'linewidth',2.0);hold on
 end
 if(iresid==0)
 plot(resid(:,1)./ncount(:),-z,cc,'linestyle','--');hold on
 plot(sqrt(resid(:,2)./ncount(:)),-z,cc,'linestyle','--','linewidth',2.0);hold on
 end
 set(gca,'ylim',[-1000 -250])
end
%subplot(2,1,2)

%set(gca,'ylim',[0 5])
%set(gca,'ylim',[-1000 -250])
end
return

for n=1:11
    plot(obs{5,n}.y(:),obs{5,n}.yb1(:),'.');hold on
    plot(obs{5,n}.y(:),obs{5,n}.yb2(:),'r.')
end
axis([0.01 0.04 0.01 0.04])
return
t1=1;t2=14;
t=11:1:11;
m=1;
figure(3)
subplot(2,2,1)
plot(squeeze(mean(innov_rms(1,t,:,m),2)),z,'linestyle',ll,'linewidth',2.0,'color',cc);hold on
%plot(squeeze(mean(innov_bias(1,t,:,m),2)),z,'linestyle',ll,'color',cc);hold on
%plot(squeeze(mean(innov_rms(3,t1:t2,:,2),2)),z,'r','linestyle',ll);
set(gca,'ydir','reverse','ylim',[100 1000])
plot([0 0],[0 1000],'-.')
subplot(2,2,2)
plot(squeeze(mean(innov_rms(2,t,:,m),2)),z,'linestyle',ll,'linewidth',2.0,'color',cc);hold on
%plot(squeeze(mean(innov_bias(2,t,:,m),2)),z,'linestyle',ll,'color',cc);hold on
plot([0 0],[0 1000],'-.')
set(gca,'ydir','reverse','ylim',[100 1000])
subplot(2,2,3)
plot(squeeze(mean(innov_rms(3,t,:,m),2)),z,'linestyle',ll,'linewidth',2.0,'color',cc);hold on
plot(squeeze(mean(innov_bias(3,t,:,m),2)),z,'linestyle',ll,'color',cc);hold on
set(gca,'ydir','reverse','ylim',[100 1000])
plot([0 0],[0 1000],'-.')

figure(1)
subplot(2,1,1)
plot(squeeze(mean(innov_rms(5,t,:,m),2)),1.e-2*z,'linestyle',ll,'linewidth',2.0,'color',cc);hold on
set(gca,'ylim',[0 5])
xlabel('RMS OMA','fontsize',12)
ylabel('Height (km)','fontsize',12)
legend('NoREF','REF','BANG','location','northwest')
legend('boxoff')
subplot(2,1,2)
plot(squeeze(mean(innov_bias(5,t,:,m),2)),1.e-2*z,'linestyle',ll,'linewidth',2.0,'color',cc);hold on
set(gca,'ylim',[0 5])
xlabel('BIAS OMA','fontsize',12)
ylabel('Height (km)','fontsize',12)
legend('NoREF','REF','BANG','location','northwest')
legend('boxoff')

%end

figure(1)
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 5 10])
