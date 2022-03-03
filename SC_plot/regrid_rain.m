addpath('/work/ailin/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');
addpath('/work/ailin/matlab/suplabel/')
addpath('/work/ailin/matlab/Discrete_colors')
addpath('/work/scyang/WRFEXPS/plot/')
constants;
obs=1;
%threshold=[10 15 25 35 50 100 150 200 350 500];
threshold=[1 5 10 15 20 30 35 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200];
%threshold=[1 5 10 15 20 30 35 40 50 60 70 100 120 150 180 200 250 300 100 100 100 100 100 100];

%fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e03/fcst/wrfout_d03_2008-06-15_16:00:00'
fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/fcst/wrfout_d03_2008-06-15_12:00:00'
xlon=getnc(fdir,'XLONG',[1 -1 -1],[1 -1 -1]);
ylat=getnc(fdir,'XLAT',[1 -1 -1],[1 -1 -1]);
mask=getnc(fdir,'XLAND',[1 -1 -1],[1 -1 -1]);
hgt=getnc(fdir,'HGT',[1 -1 -1],[1 -1 -1]);
rfid=fopen('obs_ra1601_1607.dat','rt');
%rfid=fopen('obs_ra1600_1603.dat','rt');
%rfid=fopen('obs_ra1604_1607.dat','rt');
%%rfid=fopen('obs_ra.dat','rt');
result=fscanf(rfid,'%g %g %g',[3 Inf]);
fclose(rfid);
ii=0;
for i=1:size(xlon,1)
for j=1:size(xlon,2)
    ii=ii+1;
    Ro(i,j)=result(3,ii);
end
end
ETS=zeros(24,3);
BIAS=zeros(24,3);
count=zeros(24,3);
countl=zeros(24,3);
countw=zeros(24,3);
for nfile=1:2
    switch(nfile)
    case(1)
      fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/fcst/wrfout_d03_2008-06-15_12:00:00'
      itime=2;
    case(2)
      fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e07a/fcst/wrfout_d03_2008-06-16_01:00:00';
      itime=1;
    case(3)
      fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e03/fcst/wrfout_d03_2008-06-16_01:00:00';
      itime=1;
    end
    [Rmdl]=rdrain(fdir,1,'MDL','061601','061607',6,itime);
    if(nfile==1)
       Rmdl1=Rmdl;
    else
       Rmdl2=Rmdl;
    end
    ind=find( (isnan(Ro)+isnan(Rmdl))==0 & Ro>0 & mask==1);
    [RR,p]=corrcoef([Ro(ind),Rmdl(ind)]);
    RR
    p
    clear ind
    ind=find( (isnan(Ro)+isnan(Rmdl))==0 & Ro>0 & mask==2);
    [RR,p]=corrcoef([Ro(ind),Rmdl(ind)]);
    RR
    p
    clear ind

    for is=1:24
        a=0;b=0;c=0;d=0;
        al=0;bl=0;cl=0;dl=0;
        aw=0;bw=0;cw=0;dw=0;
        ac=0;bc=0;cc=0;dc=0;
        at=0;bt=0;ct=0;dt=0;
        for i=1:size(xlon,1)
        for j=1:size(xlon,2)
            % build te congingency table
            if(isnan(Ro(i,j))==0 & isnan(Rmdl(i,j))==0)
               if(Ro(i,j)>= threshold(is))
                  if(Rmdl(i,j)>= threshold(is))
                     a=a+1;
                  else
                     c=c+1;
                  end
               else
                  if(Rmdl(i,j)>= threshold(is))
                     b=b+1;
                  else
                     d=d+1;
                  end
               end
            end

            if(mask(i,j)==2 & isnan(Ro(i,j))==0 & isnan(Rmdl(i,j))==0)
               if(Ro(i,j)>= threshold(is))
                  if(Rmdl(i,j)>= threshold(is))
                     aw=aw+1;
                  else
                     cw=cw+1;
                  end
               else
                  if(Rmdl(i,j)>= threshold(is))
                     bw=bw+1;
                  else
                     dw=dw+1;
                  end
               end
            end
            if(mask(i,j)==1 & isnan(Ro(i,j))==0 & isnan(Rmdl(i,j))==0)
               if(Ro(i,j)>= threshold(is))
                  if(Rmdl(i,j)>= threshold(is))
                     al=al+1;
                  else
                     cl=cl+1;
                  end
               else
                  if(Rmdl(i,j)>= threshold(is))
                     bl=bl+1;
                  else
                     dl=dl+1;
                  end
               end
            end
            if(hgt(i,j)<=1500.0 & isnan(Ro(i,j))==0 & isnan(Rmdl(i,j))==0)
               if(Ro(i,j)>= threshold(is))
                  if(Rmdl(i,j)>= threshold(is))
                     ac=ac+1;
                  else
                     cc=cc+1;
                  end
               else
                  if(Rmdl(i,j)>= threshold(is))
                     bc=bc+1;
                  else
                     dc=dc+1;
                  end
               end
            end
            if(hgt(i,j)>1500.0 & isnan(Ro(i,j))==0 & isnan(Rmdl(i,j))==0)
               if(Ro(i,j)>= threshold(is))
                  if(Rmdl(i,j)>= threshold(is))
                     at=at+1;
                  else
                     ct=ct+1;
                  end
               else
                  if(Rmdl(i,j)>= threshold(is))
                     bt=bt+1;
                  else
                     dt=dt+1;
                  end
               end
             end

        end
        end
        
        n=a+b+c+d;
        aref=(a+b)*(a+c)/n;
        H=a/(a+c);
        F=b/(b+d);
        area=F*H/2+(H+1.0)*(1.0-F)/2;
        ROC(is,nfile)=area;
        %ETS(is,nfile)=(a-aref)/(a-aref+b+c);
        ETS(is,nfile)=(a)/(a+c);
        BIAS(is,nfile)=(a+b)/(a+c);

        nl=al+bl+cl+dl;
        aref=(al+bl)*(al+cl)/nl;
        %ETSl(is,nfile)=(al-aref)/(al-aref+bl+cl);
        ETSl(is,nfile)=(al)/(al+cl);
        BIASl(is,nfile)=(al+bl)/(al+cl);

        nw=aw+bw+cw+dw;
        aref=(aw+bw)*(aw+cw)/nw;
        %ETSw(is,nfile)=(aw-aref)/(aw-aref+bw+cw);
        ETSw(is,nfile)=(aw)/(aw+cw);
        BIASw(is,nfile)=(aw+bw)/(aw+cw);
        count(is,nfile)=n;
        countl(is,nfile)=nl;
        countw(is,nfile)=nw;
        [is nfile n nl nw];
        nc=ac+bc+cc+dc;
        aref=(ac+bc)*(ac+cc)/nc;
        ETSc(is,nfile)=(ac-aref)/(ac-aref+bc+cc);
        BIASc(is,nfile)=(ac+bc)/(ac+cc);
        nt=at+bt+ct+dt;
        aref=(at+bt)*(at+ct)/nt;
        ETSt(is,nfile)=(at-aref)/(at-aref+bt+ct);
        BIASt(is,nfile)=(at+bt)/(at+ct);
    end
end
ithreshold=1:24;
figure(10);clf
subplot(2,3,1)
plot(ithreshold,ETS(:,1),'b','linewidth',2);hold on
plot(ithreshold,ETS(:,2),'r','linewidth',2);hold on
title('ETS (6hr)','fontsize',14);
axis([1 16 0 0.8]);
set(gca,'fontsize',12,'xtick',[1:24],'xticklabel',{'1';'5';'10';'15';'20';'30';'35';'40';'50';'60';'70';'80';'90';'100';'110';'120';'130';'140';'150';'160';'170';'180';'190';'200'});

subplot(2,3,2)
plot(ithreshold,ETSw(:,1),'b','linewidth',2);hold on
plot(ithreshold,ETSw(:,2),'r','linewidth',2);hold on
title('ETS (6hr, OCEAN)','fontsize',14)'
%plot(ithreshold,ETSc(:,1),'b','linewidth',2);hold on
%plot(ithreshold,ETSc(:,2),'r','linewidth',2);hold on
%title('ETS (6hr, COAST)','fontsize',14)'
axis([1 16 0 0.8])
set(gca,'fontsize',12,'xtick',[1:24],'xticklabel',{'1';'5';'10';'15';'20';'30';'35';'40';'50';'60';'70';'80';'90';'100';'110';'120';'130';'140';'150';'160';'170';'180';'190';'200'});

subplot(2,3,3)
plot(ithreshold,ETSl(:,1),'b','linewidth',2);hold on
plot(ithreshold,ETSl(:,2),'r','linewidth',2);hold on
%plot(ithreshold,ETSt(:,1),'b','linewidth',2);hold on
%plot(ithreshold,ETSt(:,2),'r','linewidth',2);hold on
%plot(ithreshold,ETS(:,3),'g','linewidth',2);hold on
title('ETS (6hr, LAND)','fontsize',14)'
%title('ETS (6hr, TERRAIN)','fontsize',14)'
%legend('D01S','D02DL','D02S')
axis([1 16 0 1.])
%set(gca,'xtick',threshold,'xticklabel');
set(gca,'fontsize',12,'xtick',[1:24],'xticklabel',{'1';'5';'10';'15';'20';'30';'35';'40';'50';'60';'70';'80';'90';'100';'110';'120';'130';'140';'150';'160';'170';'180';'190';'200'});

subplot(2,3,4)
plot(ithreshold,BIAS(:,1),'b','linewidth',2);hold on
plot(ithreshold,BIAS(:,2),'r','linewidth',2);hold on
axis([1 16 0 3])
plot([1 24],[1 1],'k-')
title('BIAS (6hr)','fontsize',14)'
set(gca,'fontsize',12,'xtick',[1:24],'xticklabel',{'1';'5';'10';'15';'20';'30';'35';'40';'50';'60';'70';'80';'90';'100';'110';'120';'130';'140';'150';'160';'170';'180';'190';'200'});

subplot(2,3,5)
plot(ithreshold,BIASw(:,1),'b','linewidth',2);hold on
plot(ithreshold,BIASw(:,2),'r','linewidth',2);hold on
title('BIAS (6hr, OCEAN)','fontsize',14)'
%plot(ithreshold,BIASc(:,1),'b','linewidth',2);hold on
%plot(ithreshold,BIASc(:,2),'r','linewidth',2);hold on
%title('BIAS (6hr, COAST)','fontsize',14)'
axis([1 16 0 3])
plot([1 24],[1 1],'k-')
set(gca,'fontsize',12,'xtick',[1:24],'xticklabel',{'1';'5';'10';'15';'20';'30';'35';'40';'50';'60';'70';'80';'90';'100';'110';'120';'130';'140';'150';'160';'170';'180';'190';'200'});

subplot(2,3,6)
plot(ithreshold,BIASl(:,1),'b','linewidth',2);hold on
plot(ithreshold,BIASl(:,2),'r','linewidth',2);hold on
title('BIAS (6hr, LAND)','fontsize',14)'
%plot(ithreshold,BIASt(:,1),'b','linewidth',2);hold on
%plot(ithreshold,BIASt(:,2),'r','linewidth',2);hold on
%title('BIAS (6hr, TERRAIN)','fontsize',14)'
legend('D01S','D02DL')
axis([1 16 0 3])
plot([1 24],[1 1],'k-')
set(gca,'fontsize',12,'xtick',[1:24],'xticklabel',{'1';'5';'10';'15';'20';'30';'35';'40';'50';'60';'70';'80';'90';'100';'110';'120';'130';'140';'150';'160';'170';'180';'190';'200'});

%subplot(3,1,3)
%plot(threshold,ROC(:,1),'b','linewidth',2);hold on
%plot(threshold,ROC(:,2),'r','linewidth',2);hold on
return

fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e07a/fcst/wrfout_d03_2008-06-15_16:00:00'
fdir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/fcst/wrfout_d03_2008-06-15_12:00:00'
