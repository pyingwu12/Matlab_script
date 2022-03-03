%clear all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')
addpath('/work/scyang/matlab/stats/')
lat1=18.; lat2=27.0;
lon1=115.;lon2=125.;
%axes('position',[x1 y1 dx dy])
%m_proj('miller','long',[lon1 lon2],'lat',[lat1 lat2]);
%m_grid('linest','none','box','fancy','tickdir','in','xtick',4);
%hold on

figure(1);
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

for nf=1:4
switch (nf)
case(1)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/innov/all_levs/';
   cc='b';
   ll=1.;
case(2)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_cwb45/innov/';
   cc='r';
   ll=1.;
case(3)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/innov/all_levs/';
   cc='--b';
   ll=1.;
case(4)
   dir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_cwb45/innov/';
   cc='--r';
   ll=1.;
end
mon=6;
dd=14;
hh=12;
nt=6;
%dd=15;
%hh=12;
%nt=1;
ct{1}='m';
ct{2}='g';
ct{3}='b';
ct{4}='r';

nobs_m=0;
nobs_o=0;
jprf=0;
iprf=0;

y1km=0.0;
y5km=0.0;
ytop=0.0;

for n=1:nt
clear file;
if(n== nt+1)
   dd=15;
   hh=00;
end
file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),':00:00'];
infile=[dir,file];

fid=fopen(infile,'r');
for i=1:1
    obs{i,n}.type=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
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
        a(1)=str2num(line(2:9)); 
        a(2)=str2num(line(11:17)); 
        a(3)=str2num(line(19:32)); 
        a(4)=str2num(line(34:44)); 
        if( line(45)=='*')
          a(5)=0.0;
        else
          a(5)=str2num(line(46:56)); 
        end
        if( line(58)=='*')
          a(6)=0.0;
        else
          a(6)=str2num(line(58:68)); 
        end
        if(abs(a(5)*a(6))<1.e-5)
          a(5)=0.0;
          a(6)=0.0;
        end

        obs{i,n}.lon(j)=a(1);
        obs{i,n}.lat(j)=a(2);
        obs{i,n}.pres(j)=a(3);
        obs{i,n}.y(j)=a(4);
        obs{i,n}.yb1(j)=a(5);
        obs{i,n}.yb2(j)=a(6);
 
        if(j>2 & i==1)
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

        %for zlev=500:500:5000
        %    lz=(zlev-500)/500+1;
        %    iz=min(find( levs(jprf,:)>= zlev))
        %    y1km=y1km+y(jprf,iz);
        %    ro_diff(lz,iprf)=(y(jprf,iz)-yb1(jprf,iz))/y(jprf,iz);
        %    ro_diffs(lz,iprf)=((y(jprf,iz)-yb1(jprf,iz))/y(jprf,iz)).^2;
        %end

        %if(j>1 & i==1)
        %   [j,obs{i,n}.yb1(j),obs{i,n}.yb1(j-1)]
        %   if( abs(obs{i,n}.yb1(j)) <=1.e-4 & abs(obs{i,n}.yb1(j-1)) >1.e-3)
        %   iprf=iprf+1;
        %       ro_yo(iprf) =obs{i,n}.y(j-1);
        %       ro_yb(iprf) =obs{i,n}.yb1(j-1);
        %       ro_ztop(iprf) =obs{i,n}.pres(j-1);
        %       %ro_diff(iprf)=abs(ro_yo(iprf) -ro_yb(iprf) )/ro_yo(iprf);
        %       %ro_diff(iprf)=(ro_yo(iprf) -ro_yb(iprf) )/ro_yo(iprf);
        %       %ro_diffs(iprf)=((ro_yo(iprf) -ro_yb(iprf) )/ro_yo(iprf)).^2;
        %       %% find 1km
        %   end
        %end
        if( obs{i,n}.lon(j)<= 127 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 35. &  obs{i,n}.lat(j)>= 10.)
            obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
            if(obs{i,n}.yb1(j)==-888888.000);obs{i,n}.innov(j)=-888888.;end
            obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
            if(obs{i,n}.yb2(j)==-888888.000);obs{i,n}.resid(j)=-888888.;end
        end


   end 
   %[nt, jprf]
   for jprf1=1:jprf
       iprf=iprf+1;
       for zlev=100:100:5000
           lz=(zlev-100)/100+1;
       %for zlev=200:200:5000
       %    lz=(zlev-200)/200+1;
           %iz=min(find( levs(jprf1,:)>= zlev));
           iz=max(find( abs(levs(jprf1,:)-zlev)<25.0 ));
           %if(length(iz)==0);iz=min(find( levs(jprf1,:)==0))-1;end
           if(length(iz)>0)
              if(nf<=2)
              ro_diff(lz,iprf)=(y(jprf1,iz)-yb1(jprf1,iz))/y(jprf1,iz);
              ro_diffs(lz,iprf)=((y(jprf1,iz)-yb1(jprf1,iz))/y(jprf1,iz)).^2;
              else
              ro_diff(lz,iprf)=(y(jprf1,iz)-yb2(jprf1,iz))/y(jprf1,iz);
              ro_diffs(lz,iprf)=((y(jprf1,iz)-yb2(jprf1,iz))/y(jprf1,iz)).^2;
              end
           else
             ro_diff(lz,iprf)=nan;
             ro_diffs(lz,iprf)=nan;
           end
           if(abs(ro_diff(lz,iprf)-1.0)<1.e-3)
           return
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

%end

subplot(2,1,1)
mean_diff=squeeze(nanmean(ro_diff,2));
plot(nanmean(ro_diff,2),[100:100:5000],cc,'linewidth',ll);hold on
%for zlev=500:500:5000
%    lz=(zlev-500)/500+1;
%    mean_diff_1=mean_diff(lz)+nanstd(ro_diff(lz,:));
%    mean_diff_2=mean_diff(lz)-nanstd(ro_diff(lz,:));
%    plot([mean_diff_1 mean_diff_2],[zlev zlev],cc)
%end
axis([-0.2 0.2 400 5000])
set(gca,'fontsize',12)
ylabel('Altitute (m)','fontsize',14,'fontweight','bold')
xlabel('Bias (%)','fontsize',14,'fontweight','bold')

subplot(2,1,2)
plot(sqrt(nanmean(ro_diffs,2)),[100:100:5000],cc,'linewidth',ll);hold on
axis([0.0 0.40 400 5000])
set(gca,'fontsize',12)
ylabel('Altitute (m)','fontsize',14,'fontweight','bold')
xlabel('RMS (%)','fontsize',14,'fontweight','bold')

for lz=1:size(ro_diff,1)
[lz size(ro_diff,2)-length(find(isnan(ro_diff(lz,:))==1))]
end
%ro_diff(1,find(isnan(ro_diff(1,:))==0))
clear ro_diff, ro_diffs;
end

end
subplot(2,1,1)
hleg=legend('OMB_{27}','OMB_{44}','OMA_{27}','OMA_{44}')
legend('boxoff')
set(hleg,'fontsize',10)
plot([0 0],[400 5000],'-k');
subplot(2,1,2)
hleg=legend('OMB_{27}','OMB_{44}','OMA_{27}','OMA_{44}')
legend('boxoff')
set(hleg,'fontsize',10)
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.2 5.5 10.5])
