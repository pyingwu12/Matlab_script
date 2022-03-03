clear all
p=[1150  1110  1100  1050  1000   950   900 ...
 850   800   750   700   650   600   550 ...
 500   450   400   350   300   250   200 ...
 150   100    50    40    30    20    10];

sig_o=[1.1   1.1   1.1   1.1   1.1   1.1   1.1 ...
 1.1   1.1   1.3   1.4   1.6   1.8   2.0 ...
 2.3   2.5   2.8   3.0   3.3   3.3   3.3 ...
 3.0   2.7   2.7   2.1   2.7   2.7   2.7];

figure(1);clf
iresid=0;
iinnov=0;
nvar=2;
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
jprf=0;
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
    obs{i,n}.sig_o=zeros(obs{i,n}.nobs,1);
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
        obs{i,n}.sig_o(j)=interp1(log(p),sig_o,log(0.01*obs{i,n}.pres(j)));        
        if(vert==0)
        if(obs{i,n}.pres(j)>100.0*p(1)); obs{i,n}.sig_o(j)=sig_o(1);end
        if(obs{i,n}.pres(j)<100.0*p(end));obs{i,n}.sig_o(j)=sig_o(end);end
        end
        obs{i,n}.y(j)=a(4);
        obs{i,n}.yb1(j)=a(5);
        obs{i,n}.yb2(j)=a(6);
        obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
        obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
        %if(j>1)
        %if( abs(a(1)-obs{i,n}.lon(j-1))>1.e-3 & abs(a(2)-obs{i,n}.lat(j-1))>1.e-3)
        %   iprf=iprf+1;
        %   nprf(i,iprf)=j;
        %end
        %end
   end 
   if(i==nvar)
   valid=find(obs{i,n}.pres(:)> 60000 & abs(obs{i,n}.lon(:)-114)< 10.0 & abs(obs{i,n}.lat(:)-20)< 10.0);
   %valid=find( abs(obs{i,n}.lon(:)-114)< 10.0 & abs(obs{i,n}.lat(:)-20)< 10.0);
   %length(valid)
        innovs(i,n,1)=sum(obs{i,n}.innov(valid))/length(valid);
        innovs(i,n,2)=sqrt(sum(obs{i,n}.innov(valid).^2)/length(valid))-sqrt(sum(obs{i,n}.sig_o(valid).^2)/length(valid));
        resids(i,n,1)=sum(obs{i,n}.resid(valid))/length(valid);
        resids(i,n,2)=sqrt(sum(obs{i,n}.resid(valid).^2)/length(valid));
   end
end
fclose(fid);
hh=hh+6;
if(hh>=24)
   hh=hh-24;
   dd=dd+1;
end
end


plot(squeeze(innovs(nvar,:,1)),'o','markersize',10);hold on
plot(squeeze(innovs(nvar,:,2)),'s')
plot(squeeze(resids(nvar,:,1)),'ro','markersize',10);hold on
plot(squeeze(resids(nvar,:,2)),'rs')
return
if(vert==1)
   z=0:100:5000;
else
   z=[100:100:700,750:50:1000];
end
sig_oi=interp1(ln(p),sig_o,ln(z));
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
