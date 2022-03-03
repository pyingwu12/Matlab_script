clear all
figure(1);clf
iresid=1;
iinnov=0;
nvar=4;
if(nvar<=5)
  vert=0;
else
  vert=1;
end

for nvar=1:2
    if(nvar==1);cvar='U';end
    if(nvar==2);cvar='V';end
    if(nvar==4);cvar='Qv';end
    if(nvar==3);cvar='T';end

    for nf=1:2
    switch (nf)
    case(1)
       dir='/SAS002/scyang/WRFEXPSV3/sinlaku/e76/innov/';
       ll='-';
       cc='b';
    case(2)
       dir='/SAS002/scyang/WRFEXPSV3/sinlaku/e76-RIP/innov.1/';
       ll='-';
       cc='r';
    case(3)
       dir='/SAS002/scyang/WRFEXPSV3/sinlaku/e76-RIP-TRS2/innov/';
       %dir='/SAS002/scyang/WRFEXPSV3/sinlaku/e76-RIP/innov.2/';
       ll='-';
       cc='g';
    end

    mon=9;
    dd=9;
    hh=6;
    nt=8;
    nobs_m=0;
    nobs_o=0;
    jprf=0;
    for n=1:nt
    clear file;
    file=['model2obs_2008-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
    infile=[dir,file];
    fid=fopen(infile,'r');
    for i=1:4
        obs{i,n}.type=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
        obs{i,n}.var=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
        obs{i,n}.nobs=fscanf(fid,'%u',1); %*d %e %e %e %e\n',4);
        %if(i==2);return;end
        obs{i,n}.pres=zeros(obs{i,n}.nobs,1);
        obs{i,n}.yb1=zeros(obs{i,n}.nobs,1);
        obs{i,n}.yb2=zeros(obs{i,n}.nobs,1);
        obs{i,n}.innov=zeros(obs{i,n}.nobs,1);
        obs{i,n}.resid=zeros(obs{i,n}.nobs,1);
        nprf(i,1)=1;
        iprf=1;
        for j=1:obs{i,n}.nobs
            %a=fscanf(fid,'%f %f %g %f %f %f\n',6);
            a=fscanf(fid,'%f %f %g %f %f %f %f\n',7);
            obs{i,n}.lon(j)=a(1);
            obs{i,n}.lat(j)=a(2);
            obs{i,n}.pres(j)=a(3);
            obs{i,n}.y(j)=a(4);
            obs{i,n}.yb1(j)=a(5);
            obs{i,n}.yb2(j)=a(6);
            if(i==4)
               obs{i,n}.yb1(j)=obs{i,n}.yb1(j)*1.e3;
               obs{i,n}.yb2(j)=obs{i,n}.yb2(j)*1.e3;
            end
            
            %if( obs{i,n}.lon(j)<= 140 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 35. &  obs{i,n}.lat(j)>= 10.)
            if( obs{i,n}.lon(j)<= 130 &  obs{i,n}.lon(j)>= 120 &  obs{i,n}.lat(j)<= 27. &  obs{i,n}.lat(j)>= 12.)
            %if( obs{i,n}.lon(j)>= 130 |  obs{i,n}.lon(j)<= 120 |  obs{i,n}.lat(j)>= 27. |  obs{i,n}.lat(j)<= 12.)
            obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
            obs{i,n}.ys(j)=obs{i,n}.y(j);
            obs{i,n}.ybs(j)=obs{i,n}.yb1(j);
            obs{i,n}.pps(j)=obs{i,n}.pres(j);

            if(obs{i,n}.yb1(j)==-888888.000);obs{i,n}.innov(j)=-888888.;end
            obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
            if(obs{i,n}.yb2(j)==-888888.000);obs{i,n}.resid(j)=-888888.;end
    
            end
    
            %if(j>1)
            %if( abs(a(1)-obs{i,n}.lon(j-1))>1.e-3 & abs(a(2)-obs{i,n}.lat(j-1))>1.e-3)
            %   iprf=iprf+1;
            %   nprf(i,iprf)=j;
            %end
            %end
       end 
       if(i==6 & n<=16)
       zi=100:100:5000;
       nz=length(zi);
       iprf=1;
       clear y yb x;
       %jprf=jprf+1;
       %y(iprf)=obs{i,n}.y(1);
       %yb(iprf)=obs{i,n}.yb1(1);
       %x(iprf)=obs{i,n}.pres(1);
       %%if(n==1)
       %   lats(jprf)=obs{i,n}.lat(1);
       %   lons(jprf)=obs{i,n}.lon(1);
       %%end
       %for j=2:obs{i,n}.nobs
       %    if (abs(obs{i,n}.lon(j)-obs{i,n}.lon(j-1))<1.e-3 & abs(obs{i,n}.lat(j)-obs{i,n}.lat(j-1))<1.e-3 )
       %       iprf=iprf+1;
       %       y(iprf)=obs{i,n}.y(j);
       %       yb(iprf)=obs{i,n}.yb1(j);
       %       x(iprf)=obs{i,n}.pres(j);
       %       if(j==obs{i,n}.nobs)
       %       if(iprf>2)
       %       yi(jprf,1:nz)=interp1(x,y,zi);
       %       ybi(jprf,1:nz)=interp1(x,yb,zi);
       %       else
       %         yi(jprf,1:nz)=NaN;
       %         ybi(jprf,1:nz)=NaN;
       %       end
       %       end
       %    else
       %       if(iprf>3)
       %       yi(jprf,1:nz)=interp1(x,y,zi);
       %       ybi(jprf,1:nz)=interp1(x,yb,zi);
       %       else
       %         yi(jprf,1:nz)=NaN;
       %         ybi(jprf,1:nz)=NaN;
       %       end
       %       jprf=jprf+1
       %       iprf=1;
       %       lats(jprf)=obs{i,n}.lat(j);
       %       lons(jprf)=obs{i,n}.lon(j);
       %       %if ( abs(lons(jprf)-108.198)<= 1.e-3 &  abs(lats(jprf)-17.23)<1.e-3 );
       %       %     jprf
       %       %end
       %       clear x y yb;
       %       y(iprf)=obs{i,n}.y(j);
       %       yb(iprf)=obs{i,n}.yb1(j);
       %       x(iprf)=obs{i,n}.pres(j);
       %    end
       %end
       end
    end
    fclose(fid);
    hh=hh+6;
    if(hh>=24)
       hh=hh-24;
       dd=dd+1;
    end

end
%figure(2)
%if(nf==1)
%plot(obs{nvar,1}.ys,-0.01*obs{nvar,1}.pps,'k');hold on
%end
%plot(obs{nvar,1}.ybs,-0.01*obs{nvar,1}.pps,cc);hold on

%for nvar=1:2
if(vert==1)
   z=0:100:5000;
else
   z=[200:100:1000];
   zz=[150:100:1050];
   %zz=[150:50:1050];
   %nz=length(zz);
   %z=0.5*(zz(1:end-1)+zz(2:end));
end
innov=zeros(length(z),2);
innov_t=zeros(length(z),2,nt);
ncount_t=zeros(length(z),nt);

resid=zeros(length(z),2);
innovt=zeros(nt,2);
residt=zeros(nt,2);
nobs=zeros(nt,1);
ncount=zeros(length(z),1);
for n=1:nt
    nobs(n)=0;
    for j=1:obs{nvar,n}.nobs 
        %if( obs{nvar,n}.lon(j)<= 140 &  obs{nvar,n}.lon(j)>= 105 &  obs{nvar,n}.lat(j)<= 35. &  obs{nvar,n}.lat(j)>= 5.)
        if(vert==1)
           nz=max(find(z<=obs{nvar,n}.pres(j)));
        else
           nz=max(find(zz<=1.e-2*obs{nvar,n}.pres(j)));
        %if (1.e-2*obs{nvar,n}.pres(j) > 950)
        %   return
        %end
           %[nz,z(nz),1.e-2*obs{nvar,n}.pres(j)]
        end
        %if(obs{nvar,n}.pres(j)*1.e-2>=250 & obs{nvar,n}.pres(j)<1.e10 & abs(obs{nvar,n}.innov(j)+888888.0)>0.00001)
        if(obs{nvar,n}.pres(j)*1.e-2<=200)

        nobs(n)=nobs(n)+1;
        innovt(n,1)=innovt(n,1)+obs{nvar,n}.innov(j);
        innovt(n,2)=innovt(n,2)+obs{nvar,n}.innov(j).^2;
        residt(n,1)=residt(n,1)+obs{nvar,n}.resid(j);
        residt(n,2)=residt(n,2)+obs{nvar,n}.resid(j).^2;
        end

        if(nz>0 & nz<=length(z))
        innov(nz,1)=innov(nz,1)+obs{nvar,n}.innov(j); 
        innov(nz,2)=innov(nz,2)+obs{nvar,n}.innov(j).^2; 
        innov_t(nz,2,n)=innov_t(nz,2,n)+obs{nvar,n}.innov(j).^2; 
        ncount_t(nz,n)= ncount_t(nz,n)+1;

        resid(nz,1)=resid(nz,1)+obs{nvar,n}.resid(j); 
        resid(nz,2)=resid(nz,2)+obs{nvar,n}.resid(j).^2; 
        ncount(nz)= ncount(nz)+1;
        end
        %end
    end
        innov_t(:,2,n)=sqrt(innov_t(:,2,n)./ncount_t(:,n));

        innovt(n,:)=innovt(n,:)/nobs(n);
        residt(n,:)=residt(n,:)/nobs(n);
        innovts(1+2*(n-1),:)=innovt(n,:);
        %innovts(2*n,:)=residt(n,:);
        innovts(2*n,:)=innovt(n,:);
        tt(1+2*(n-1))=n;
        tt(2*n)=n;
end
figure(1)
subplot(2,2,nvar)
    if(nvar==1);cvar='U';end
    if(nvar==2);cvar='V';end
    if(nvar==4);cvar='Qv';end
    if(nvar==3);cvar='T';end
if(vert==1)
 if(iinnov==0)
 plot(innov(:,1)./ncount(:),1.e-3*z,cc,'linewidth',1.0,'linestyle','--');hold on
 plot(sqrt(innov(:,2)./ncount(:)),1.e-3*z,cc,'linewidth',2.0);hold on
 end
 if(iresid==0)
 plot(resid(:,1)./ncount(:),1.e-3*z,cc,'linestyle','--');hold on
 plot(sqrt(resid(:,2)./ncount(:)),1.e-3*z,cc,'linestyle','-','linewidth',2.0);hold on
 end
y0=3;
 plot([0 0],[0 5],'color',[0.5 0.5 0.5]);
 set(gca,'ylim',[0 5-y0],'xlim',[-0.022 0.022])
else
 y0=0;
 if(iinnov==0)
 plot(innov(:,1)./ncount(:),-z,cc,'linewidth',1.0,'linestyle','-');hold on
 plot(sqrt(innov(:,2)./ncount(:)),-z,cc,'linewidth',2.0);hold on

 %innov_rms_std=std(innov_t(:,2,:),0,3);
 %  for iz=1:length(z)
 %      plot([sqrt(innov(iz,2)./ncount(iz))-innov_rms_std(iz) sqrt(innov(iz,2)./ncount(iz))+innov_rms_std(iz)],[-z(iz) -z(iz)],cc,'marker','*','linewidth',2.0);hold on
 %  end
 %set(gca,'ylim',[-1000 -100],'xlim',[-1. 5.25],'yticklabel',{'1000','900','800','700','600','500','400','300','200'},'fontsize',12)
 %set(gca,'ylim',[-1000 -100],'xlim',[-1.5 7.25],'yticklabel',{'1000','900','800','700','600','500','400','300','200'},'fontsize',12)
 set(gca,'ylim',[-1000 -100],'xlim',[-1.5 3.],'yticklabel',{'1000','900','800','700','600','500','400','300','200'},'fontsize',12)
 end
 if(iresid==0)
 plot(resid(:,1)./ncount(:),-z,cc,'marker','x','linestyle','--');hold on
 plot(sqrt(resid(:,2)./ncount(:)),-z,cc,'marker','x','linestyle','-','linewidth',2.0);hold on
 end
 set(gca,'ylim',[-1000 -200],'ytick',[-1000:100:-200],'xlim',[-1. 5.5],'yticklabel',{'1000','900','800','700','600','500','400','300','200'});
 %if(nvar==1);set(gca,'ylim',[-1000 -200],'ytick',[-1000:100:-200],'xlim',[-1. 1.],'yticklabel',{'1000','900','800','700','600','500','400','300','200'});end
 %if(nvar==2);set(gca,'ylim',[-1000 -200],'ytick',[-1000:100:-200],'xlim',[-1 1.],'yticklabel',{'1000','900','800','700','600','500','400','300','200'});end
 plot([0 0],[-1000 500],'color',[0.5 0.5 0.5]);
end
if(nf==1)
title(['Bias of Obs-Bg for ',cvar],'fontweight','bold')
xlabel('Error (m/s)','fontsize',14)
ylabel('Pressure (hPa)','fontsize',14)
%title('Bias/RMS of Obs-Background')
x1=.9;
x2=2.;
xl=x1+0.075*(x2-x1);
y2=-775;
dy=25;
%5.5 5.2 4.9 4.6
set(gcf,'paperorientation','landscape','paperposition',[0.25 0.5 9 8])
end

%figure(2)
%subplot(2,1,1)
%plot(tt,innovts(:,1),cc);hold on
%subplot(2,1,2)
%plot(tt,sqrt(innovts(:,2)),cc);hold on

%end
end

end
