clear all
figure(1);clf
iresid=0;
iinnov=1;
nvar=4;
if(nvar<=5)
  vert=0;
else
  vert=1;
end

for nvar=4:4
    if(nvar==1);cvar='U';end
    if(nvar==2);cvar='V';end
    if(nvar==4);cvar='Qv';end
    if(nvar==3);cvar='T';end

for nf=1:3
switch (nf)
case(1)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e17_1deg_upper/innov/Qv/';
   ll='-';
   cc='k';
case(2)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e16_1deg_upper/innov/Qv/';
   ll='-';
   cc='b';
case(3)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/innov/Qv/';
   ll='-';
   cc='r';
end
mon=6;
dd=15;
hh=12;
nt=4;

nobs_m=0;
nobs_o=0;
jprf=0;
for n=1:nt
clear file;
file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),':00:00'];
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
        %a=fscanf(fid,'%f %f %g %f %f %f %f\n',7);
        line=fscanf(fid,'%80c',1);
        a(1)=str2num(line(2:9)); 
        a(2)=str2num(line(11:17)); 
        a(3)=0.01*str2num(line(19:32)); 
        a(4)=str2num(line(34:44)); 
        a(5)=str2num(line(46:56)); 
        a(6)=str2num(line(58:68)); 

        obs{i,n}.lon(j)=a(1);
        obs{i,n}.lat(j)=a(2);
        obs{i,n}.pres(j)=a(3);
        obs{i,n}.y(j)=a(4);
        obs{i,n}.yb1(j)=a(5);
        obs{i,n}.yb2(j)=a(6);
        if(i==4)
           obs{i,n}.yb1(j)=obs{i,n}.yb1(j);
           obs{i,n}.yb2(j)=obs{i,n}.yb2(j);
        end
        
        %if( obs{i,n}.lon(j)<= 127 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 45. &  obs{i,n}.lat(j)>= 5.)
        %if( obs{i,n}.lon(j)<= 123 &  obs{i,n}.lon(j)>= 110 &  obs{i,n}.lat(j)<= 25. &  obs{i,n}.lat(j)>= 15.)
        %if( obs{i,n}.lon(j)<= 121 &  obs{i,n}.lon(j)>= 110 &  obs{i,n}.lat(j)<= 25. &  obs{i,n}.lat(j)>= 15.)
        if( obs{i,n}.lon(j)<= 121 &  obs{i,n}.lon(j)>= 115 &  obs{i,n}.lat(j)<= 25. &  obs{i,n}.lat(j)>= 15.)
        obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
        if(obs{i,n}.yb1(j)==-888888.000);obs{i,n}.innov(j)=-888888.;end
        obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
        if(obs{i,n}.yb2(j)==-888888.000);obs{i,n}.resid(j)=-888888.;end

        end

        %if(i==6)
        %    if( obs{i,n}.lon(j)<= 122 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 25. &  obs{i,n}.lat(j)>= 15.)
        %        obs{i,n}.pres(j);
        %        nobs_m=nobs_m+1;
        %        pres_m(nobs_m)=obs{i,n}.pres(j);
        %        y_m(nobs_m)=obs{i,n}.y(j);
        %        if(pres_m(nobs_m)<200)
        %           [obs{i,n}.lon(j) obs{i,n}.lat(j)]
        %           [pres_m(nobs_m),n,j]
        %        end
        %    else
        %        nobs_o=nobs_o+1;
        %        pres_o(nobs_o)=obs{i,n}.pres(j);
        %        y_o(nobs_o)=obs{i,n}.y(j);
        %    end
        %%if(j>1)
        %%if( abs(a(1)-obs{i,n}.lon(j-1))>1.e-3 & abs(a(2)-obs{i,n}.lat(j-1))>1.e-3)
        %%   iprf=iprf+1;
        %%   nprf(i,iprf)=j;
        %%end
        %%end
        %end
   end 
   if(i==6 & n<=16)
   zi=100:100:5000;
   nz=length(zi);
   iprf=1;
   clear y yb x;
   end
end
fclose(fid);
hh=hh+6;
if(hh>=24)
   hh=hh-24;
   dd=dd+1;
end
end
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
   %z=[100:100:800,850:50:1000];
   %z=[100:50:700,750:50:900,925,950,975,1000];
   %zz=[0,550,650,750,825,875,887.5,925,975,1025];
   %z=[600,700,800,850,900,950,1000]
   zz=[425,575,825,875,975,1050];
   z=[ 500,700,850,925,1000];
   %z=[700,750,800,850,900,950,1000];
   %z=[500,600,700,800,850,900,950,1000]
   %zz=[0,450,650:100:1050]; %paper original
   %zz=[650:100:1050]; %paper original
   %z=[500,600,700,800,900,1000]
   %z=[100:100:1000];
end
innov=zeros(length(z),2);
resid=zeros(length(z),2);
innovt=zeros(nt,2);
residt=zeros(nt,2);
nobs=zeros(nt,1);
ncount=zeros(length(z),1);
jcount=0;
for n=1:nt
    nobs(n)=0;
    for j=1:obs{nvar,n}.nobs 
        %if( obs{nvar,n}.lon(j)<= 125 &  obs{nvar,n}.lon(j)>= 105 &  obs{nvar,n}.lat(j)<= 30. &  obs{nvar,n}.lat(j)>= 5.)
        if(vert==1)
           nz=max(find(z<=obs{nvar,n}.pres(j)));
        else
           nz=max(find(zz<=obs{nvar,n}.pres(j)));
           %[nz,z(nz),1.e-2*obs{nvar,n}.pres(j)]
           if(obs{nvar,n}.pres(j)*1.e-2>= 950);
             jcount=jcount+1;
           end
        end
        %if(obs{nvar,n}.pres(j)*1.e-2>=250 & obs{nvar,n}.pres(j)<1.e10 & abs(obs{nvar,n}.innov(j)+888888.0)>0.00001)
        %if(obs{nvar,n}.pres(j)*1.e-2<=200)
        %nobs(n)=nobs(n)+1;
        %innovt(n,1)=innovt(n,1)+obs{nvar,n}.innov(j);
        %innovt(n,2)=innovt(n,2)+obs{nvar,n}.innov(j).^2;
        %residt(n,1)=residt(n,1)+obs{nvar,n}.resid(j);
        %residt(n,2)=residt(n,2)+obs{nvar,n}.resid(j).^2;
        %end

        if(nz>0 & nz<=length(z))
        innov(nz,1)=innov(nz,1)+obs{nvar,n}.innov(j); 
        innov(nz,2)=innov(nz,2)+obs{nvar,n}.innov(j).^2; 
        resid(nz,1)=resid(nz,1)+obs{nvar,n}.resid(j); 
        resid(nz,2)=resid(nz,2)+obs{nvar,n}.resid(j).^2; 
        ncount(nz)= ncount(nz)+1;
        end
    end
        innovt(n,:)=innovt(n,:)/nobs(n);
        residt(n,:)=residt(n,:)/nobs(n);
        innovts(1+2*(n-1),:)=innovt(n,:);
        %innovts(2*n,:)=residt(n,:);
        innovts(2*n,:)=innovt(n,:);
        tt(1+2*(n-1))=n;
        tt(2*n)=n;
end
%subplot(2,1,1)
figure(1)
subplot(2,1,1)
if(vert==1)
    if(iinnov==0)
    plot(innov(:,1)./ncount(:),1.e-3*z,cc,'linewidth',1.0,'linestyle','--');hold on
    plot(sqrt(innov(:,2)./ncount(:)),1.e-3*z,cc,'linewidth',2.0);hold on
    end
    if(iresid==0)
    %plot(resid(:,1)./ncount(:),1.e-3*z,cc,'linestyle','--');hold on
    plot(sqrt(resid(:,2)./ncount(:)),1.e-3*z,cc,'linestyle','-','linewidth',2.0);hold on
    end
    y0=3;
    plot([0 0],[0 5],'color',[0.5 0.5 0.5]);
    set(gca,'ylim',[0 5-y0],'xlim',[-0.022 0.022])
else
    y0=0;
    if(iinnov==0)
       plot(innov(:,1)./ncount(:),-z,cc,'linewidth',1.0,'linestyle','--');hold on
       plot(sqrt(innov(:,2)./ncount(:)),-z,cc,'linewidth',2.0);hold on
    set(gca,'ylim',[-1000 -500],'xlim',[-1. 3],'yticklabel',{'1000','900','800','700','600','500'})
    end
    if(iresid==0)
       plot(resid(:,1)./ncount(:),-z,cc,'marker','x','linestyle','--');hold on
       plot(sqrt(resid(:,2)./ncount(:)),-z,cc,...
            'marker','x','linestyle','-','linewidth',2.0);hold on
    end
    set(gca,'ylim',[-1005 -490],'ytick',[-1000:100:-500],...
        'xlim',[-0.25 .75],'xminortick','on',...
        'yticklabel',{'1000','900','800','700','600','500'});
    plot([0 0],[-1000 500],'color',[0.5 0.5 0.5]);
end

if(nf==1)
title(['BIAS/RMS of Obs-Analysis for ',cvar],'fontweight','bold')
xlabel('Error (g/Kg)')
ylabel('Pressure (hPa)')
%title('Bias/RMS of Obs-Background')
x1=.4;
x2=1.3;
xl=x1+0.075*(x2-x1);
y2=-550;
dy=25;
%5.5 5.2 4.9 4.6
plot([xl xl+0.1*(x2-x1)],[y2-y0 y2-y0],'-k')
plot([xl xl+0.1*(x2-x1)],[y2-dy-y0 y2-dy-y0],'r')
plot([xl xl+0.1*(x2-x1)],[y2-2*dy-y0 y2-2*dy-y0],'-b')
text(xl+0.11*(x2-x1),y2-0.05*dy-y0,'CNTL','horizontalalignment','left')
text(xl+0.11*(x2-x1),y2-1.05*dy-y0,'REF','horizontalalignment','left')
text(xl+0.11*(x2-x1),y2-2.05*dy-y0,'BANGLE','horizontalalignment','left')
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 5 10.5])
end

%figure(2)
%subplot(2,1,1)
%plot(tt,innovts(:,1),cc);hold on
%subplot(2,1,2)
%plot(tt,sqrt(innovts(:,2)),cc);hold on

end
end
