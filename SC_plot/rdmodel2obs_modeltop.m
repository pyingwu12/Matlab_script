clear all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
lat1=18.; lat2=27.0;
lon1=115.;lon2=125.;
%axes('position',[x1 y1 dx dy])
m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
hold on

figure(1);clf
iresid=0;
iinnov=1;
nvar=4;
if(nvar<=5)
  vert=0; % pressure
else
  vert=1;% height
end
subtit{1}='(a)';
subtit{2}='(b)';
for nvar=3:3
    if(nvar==1);cvar='U';end
    if(nvar==2);cvar='V';end
    if(nvar==4);cvar='Qv';end
    if(nvar==3);cvar='T';end

for nf=1:1
switch (nf)
case(1)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/bangle_check/e48b_all_level/';
   ll='-';
end
mon=6;
%dd=14;
%hh=00;
%nt=12;
dd=15;
hh=12;
nt=1;
ct{1}='m';
ct{2}='g';
ct{3}='b';
ct{4}='r';

nobs_m=0;
nobs_o=0;
jprf=0;
iprf=0;

y1km=0.0
y5km=0.0
ytop=0.0

for n=1:nt
clear file;
if(n== nt+1)
   dd=15;
   hh=00;
end
file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),':00:00'];
infile=[dir,file]

fid=fopen(infile,'r');
for i=1:6
    obs{i,n}.type=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
    obs{i,n}.type
    obs{i,n}.var=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
    obs{i,n}.nobs=fscanf(fid,'%u',1); %*d %e %e %e %e\n',4);
    %if(i==2);return;end
    obs{i,n}.pres=zeros(obs{i,n}.nobs,1);
    obs{i,n}.yb1=zeros(obs{i,n}.nobs,1);
    obs{i,n}.yb2=zeros(obs{i,n}.nobs,1);
    obs{i,n}.innov=zeros(obs{i,n}.nobs,1);
    obs{i,n}.resid=zeros(obs{i,n}.nobs,1);
    nprf(i,n)=1;

    jprf=1;
    prof_obs=0;
    for j=1:obs{i,n}.nobs
        %a=fscanf(fid,'%f %f %g %f %f %f\n',6);
        %a=fscanf(fid,'%f %f %g %f %f %f %f\n',7);
        line=fscanf(fid,'%80c',1);
        a(1)=str2num(line(3:9)); 
        a(2)=str2num(line(11:17)); 
        a(3)=str2num(line(19:32)); 
        a(4)=str2num(line(34:44)); 
        if( line(45)=='*')
          a(5)=0.0;
          a(6)=0.0;
        else
        a(5)=str2num(line(46:56)); 
        a(6)=str2num(line(58:68)); 
        end

        obs{i,n}.lon(j)=a(1);
        obs{i,n}.lat(j)=a(2);
        obs{i,n}.pres(j)=a(3);
        obs{i,n}.y(j)=a(4);
        obs{i,n}.yb1(j)=a(5);
        obs{i,n}.yb2(j)=a(6);
 
        if(j>2 & i==6)
          if( abs(a(1)-obs{i,n}.lon(j-1))<1.e-3 & abs(a(2)-obs{i,n}.lat(j-1))<1.e-3)
           prof_obs=prof_obs+1;
           %lons(jprf,prof_obs)=obs{i,n}.lon(j);
          else
            jprf=jprf+1;
            prof_obs=1;
          end
           lons(jprf,prof_obs)=obs{i,n}.lon(j);
           lats(jprf,prof_obs)=obs{i,n}.lat(j);
           levs(jprf,prof_obs)=obs{i,n}.pres(j);
           y(jprf,prof_obs)=obs{i,n}.y(j);
           yb1(jprf,prof_obs)=obs{i,n}.yb1(j);
           yb2(jprf,prof_obs)=obs{i,n}.yb2(j);
        end
        
        if(i==4)
           obs{i,n}.yb1(j)=obs{i,n}.yb1(j)*1.e3;
           obs{i,n}.yb2(j)=obs{i,n}.yb2(j)*1.e3;
        end

        if(j>1 & i==6)
           if( abs(obs{i,n}.yb1(j)) <=1.e-4 & abs(obs{i,n}.yb1(j-1)) >1.e-3)
               iprf=iprf+1;
               ro_yo(iprf) =obs{i,n}.y(j-1);
               ro_yb(iprf) =obs{i,n}.yb1(j-1);
               ro_ztop(iprf) =obs{i,n}.pres(j-1);
               %ro_diff(iprf)=abs(ro_yo(iprf) -ro_yb(iprf) )/ro_yo(iprf);
               ro_diff(iprf)=abs(ro_yo(iprf) -ro_yb(iprf) )/ro_yo(iprf);
               %% fine 1km
               iz1=min(find( levs(jprf,:)>= 1.000e3));
               iz5=min(find( levs(jprf,:)>= 0.500e4));
               ytop=ytop+ro_yo(iprf);
               y1km=y1km+y(jprf,iz1);
               y5km=y5km+y(jprf,iz5);

               ro_diff1km(iprf)=abs(y(jprf,iz1)-yb1(jprf,iz1))/y(jprf,iz1);
               ro_diff5km(iprf)=abs(y(jprf,iz5)-yb1(jprf,iz5))/y(jprf,iz5);
               ro_topdiff1km(iprf)=abs(ro_yo(iprf) -ro_yb(iprf) )/y(jprf,iz1);
               ro_topdiff5km(iprf)=abs(ro_yo(iprf) -ro_yb(iprf) )/y(jprf,iz5);
           end
        end
        
        if( obs{i,n}.lon(j)<= 127 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 35. &  obs{i,n}.lat(j)>= 10.)
        %if( obs{i,n}.lon(j)<= 123 &  obs{i,n}.lon(j)>= 117 &  obs{i,n}.lat(j)<= 24. &  obs{i,n}.lat(j)>= 19.)
        obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
        if(obs{i,n}.yb1(j)==-888888.000);obs{i,n}.innov(j)=-888888.;end
        obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
        if(obs{i,n}.yb2(j)==-888888.000);obs{i,n}.resid(j)=-888888.;end

        end

        %if(i==6)
        %if( obs{i,n}.lon(j)<= 122 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 25. &  obs{i,n}.lat(j)>= 10.)
        %    obs{i,n}.pres(j);
        %    nobs_m=nobs_m+1;
        %    pres_m(nobs_m)=obs{i,n}.pres(j);
        %    y_m(nobs_m)=obs{i,n}.y(j);
        %    if(pres_m(nobs_m)<200)
        %       [obs{i,n}.lon(j) obs{i,n}.lat(j)]
        %       [pres_m(nobs_m),n,j]
        %    end
        %else
        %    nobs_o=nobs_o+1;
        %    pres_o(nobs_o)=obs{i,n}.pres(j);
        %    y_o(nobs_o)=obs{i,n}.y(j);
        %end
        %if(j>1)
        %   iprf=iprf+1;
        %   nprf(i,iprf)=j;
        %end
        %end
        %end
   end 
   %if(i==6 & n<=16)
   %zi=100:100:5000;
   %nz=length(zi);
   %iprf=1;
   %clear y yb x;
   %end
end
fclose(fid);
hh=hh+6;
if(hh>=24)
   hh=hh-24;
   dd=dd+1;
end

end
ytop=ytop/iprf;
y1km=y1km/iprf;
y5km=y5km/iprf;
return
%
%valid=find( lons<= 122.5 &  lons>= 105 & lats<= 30. & lats>= 12.5);
%invalid=find( lons> 122.5 |  lons< 105 | lats> 30. | lats< 12.5);   
%%subplot(2,1,1)
%for iz=1:length(zi)
%    if( sum(1-isnan(yi(valid,iz)))>2)
%    yi1(iz)=nanmean(yi(valid,iz));
%    else
%    yi1(iz)=nan;
%    end
%    if( sum(1-isnan(yi(invalid,iz)))>2)
%    yi2(iz)=nanmean(yi(invalid,iz));
%    else
%    yi2(iz)=nan;
%    end
%
%    if( sum(1-isnan(ybi(valid,iz)))>2)
%    ybi1(iz)=nanmean(ybi(valid,iz));
%    else
%    ybi1(iz)=nan;
%    end
%    if( sum(1-isnan(ybi(invalid,iz)))>2)
%    ybi2(iz)=nanmean(ybi(invalid,iz));
%    else
%    ybi2(iz)=nan;
%    end
%end
%subplot(1,2,1)
%plot(yi1,zi,'-ro','linewidth',2.0);hold on
%plot(yi2,zi,'-ko','linestyle','-')
%plot(ybi1,zi,'-rx','linewidth',2.0);hold on
%plot(ybi2,zi,'-kx','linestyle','-')
%legend('MOIST(OBS)','OUTSIDE(OBS)','MOIST(MODEL)','OUTSIDE(MODEL)')
%legend('boxoff')
%set(gca,'ylim',[200 5000]);
%xlabel('Bending Angle','fontsize',12)
%ylabel('Altitude (m)','fontsize',12)
%subplot(1,2,2)
%plot(yi1,zi,'-ro','linewidth',2.0);hold on
%plot(yi2,zi,'-ko','linestyle','-')
%plot(ybi1,zi,'-rx','linewidth',2.0);hold on
%plot(ybi2,zi,'-kx','linestyle','-')
%legend('MOIST(OBS)','OUTSIDE(OBS)','MOIST(MODEL)','OUTSIDE(MODEL)')
%legend('boxoff')
%set(gca,'ylim',[200 2000]);
%xlabel('Bending Angle','fontsize',12)
%ylabel('Altitude (m)','fontsize',12)
%set(gcf,'Paperorientation','landscape','paperposition',[0. 0. 11 8.5])
%%print -dpsc bangle_moistbox.ps;
%return
if(vert==1)
   z=0:100:5000;
else
   z=[50,100,200,500,700,850,1000];
   zz(1)=20;
   for ii=2:length(z)
       zz(ii)=0.5*(z(ii-1)+z(ii));
   end
   zz(length(z)+1)=1050;
   %z=[100:100:800,850:50:1000];
   %z=[100:50:700,750:50:900,925,950,975,1000];
   %zz=[0,550,650,750,825,875,887.5,925,975,1025];
   %z=[600,700,800,850,900,950,1000]

   %zz=[575,625,675,725,775,825,875,925,975,1050];
   %z=[   600,650,700,750,800,850,900,950,1000];

   %z=[700,750,800,850,900,950,1000];
   %z=[500,600,700,800,850,900,950,1000]
   %zz=[0,450,650:100:1050]; %paper original
   %zz=[650:100:1050]; %paper original
   %z=[500,600,700,800,900,1000]
   %z=[100:100:1000];
end

innov=zeros(length(z),2,nt);
resid=zeros(length(z),2,nt);
ncount=zeros(length(z),nt);
for n=1:nt
    nobs=zeros(nt,1);
    jcount=0;
    nobs(n)=0;
    for j=1:obs{nvar,n}.nobs 
        %if( obs{nvar,n}.lon(j)<= 125 &  obs{nvar,n}.lon(j)>= 105 &  obs{nvar,n}.lat(j)<= 30. &  obs{nvar,n}.lat(j)>= 5.)
        if(vert==1)
           nz=max(find(z<=obs{nvar,n}.pres(j)));
        else
           nz=max(find(zz<=1.e-2*obs{nvar,n}.pres(j)));
           %[nz,z(nz),1.e-2*obs{nvar,n}.pres(j)]
           if(obs{nvar,n}.pres(j)*1.e-2>= 950);
             jcount=jcount+1;
           end
        end

        if(nz>0 & nz<=length(z))
        innov(nz,1,n)=innov(nz,1,n)+obs{nvar,n}.innov(j); 
        innov(nz,2,n)=innov(nz,2,n)+obs{nvar,n}.innov(j).^2; 
        resid(nz,1,n)=resid(nz,1,n)+obs{nvar,n}.resid(j); 
        resid(nz,2,n)=resid(nz,2,n)+obs{nvar,n}.resid(j).^2; 
        ncount(nz,n)= ncount(nz,n)+1;
        end
    end
        tt(1+2*(n-1))=n;
        tt(2*n)=n;
    for nz=1:length(z)
        if(ncount(nz,n)<5) 
           innov(nz,1:2,n)=nan;
           resid(nz,1:2,n)=nan;
        end
    end

if(vert==1)
 %if(iinnov==0)
 %   plot(innov(:,1)./ncount(:),1.e-3*z,cc,'linewidth',1.0,'linestyle','--');hold on
 %   plot(sqrt(innov(:,2)./ncount(:)),1.e-3*z,cc,'linewidth',2.0);hold on
 %end
 %if(iresid==0)
 %plot(resid(:,1)./ncount(:),1.e-3*z,cc,'linestyle','--');hold on
 %plot(sqrt(resid(:,2)./ncount(:)),1.e-3*z,cc,'linestyle','-','linewidth',2.0);hold on
 %end
y%0=3;
 %plot([0 0],[0 5],'color',[0.5 0.5 0.5]);
 %set(gca,'ylim',[0 5-y0],'xlim',[-0.022 0.022])
else
 y0=0;
 %if(iinnov==0)
 %   plot(innov(:,1)./ncount(:),-z,cc,'linewidth',1.0,'linestyle','--');hold on
 %   plot(sqrt(innov(:,2)./ncount(:)),-z,cc,'linewidth',2.0);hold on
 %   set(gca,'ylim',[-1005 -690],'xlim',[-1. 3],'yticklabel',{'1000','900','800','700','600','500'})
 %end
 if(iresid==0)
   plot(resid(:,1,n)./ncount(:,n),-z,ct{n},'linestyle','--');hold on
   plot(sqrt(resid(:,2,n)./ncount(:,n)),-z,ct{n},'linestyle','-','linewidth',2.0);hold on
 end
 set(gca,'ylim',[-1005 -50],'xlim',[-1. 10],'ytick',[-1000:100:-100,-50],'yticklabel',{'1000','900','800','700','600','500','400','300','200','100','50'})
 plot([0 0],[-1000 50],'color',[0.5 0.5 0.5]);
end

end

end %n_loop

if(nf==1)
title([' Bias/RMS of Obs-Analysis for ',cvar],'fontweight','bold')
xlabel('Error (m/s)')
ylabel('Pressure (hPa)')
%title('Bias/RMS of Obs-Background')
x1=3.5;
x2=6.5;
xl=x1+0.075*(x2-x1);
y2=-720;
dy=20;
%5.5 5.2 4.9 4.6
plot([xl xl+0.15*(x2-x1)],[y2-y0 y2-y0],'-k')
plot([xl xl+0.15*(x2-x1)],[y2-dy-y0 y2-dy-y0],'r')
plot([xl xl+0.15*(x2-x1)],[y2-2*dy-y0 y2-2*dy-y0],'-b')
text(xl+0.16*(x2-x1),y2-0.05*dy-y0,'CNTL','horizontalalignment','left')
text(xl+0.16*(x2-x1),y2-1.05*dy-y0,'REF','horizontalalignment','left')
text(xl+0.16*(x2-x1),y2-2.05*dy-y0,'BANGLE','horizontalalignment','left')
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 5 10])
end

%figure(2)
%subplot(2,1,1)
%plot(tt,innovts(:,1),cc);hold on
%subplot(2,1,2)
%plot(tt,sqrt(innovts(:,2)),cc);hold on

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
