clear all
figure(1);clf
iresid=0;
iinnov=1;
nvar=5;
if(nvar<=5)
  vert=0;
else
  vert=1;
end

for nvar=2:2
    if(nvar==1);cvar='U';end
    if(nvar==2);cvar='V';end
    if(nvar==4);cvar='Qv';end
    if(nvar==3);cvar='T';end

dir='/SAS002/scyang/WRFEXPSV3/2008IOP8/covariance/e48b_check/BANGLE/';
ll='-';
cc='k';

for nf=1:36

mon=6;
dd=15;
hh=18;
nt=1;

nobs_m=0;
nobs_o=0;
jprf=0;
for n=1:nt
clear file;
file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),':00:00.',num2str(nf,'%2.2d')];
infile=[dir,file];
fid=fopen(infile,'r');
for i=1:5
    obs{i,n,nf}.type=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
    obs{i,n,nf}.var=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
    obs{i,n,nf}.nobs=fscanf(fid,'%u',1); %*d %e %e %e %e\n',4);
    obs{i,n,nf}.pres=zeros(obs{i,n}.nobs,1);
    obs{i,n,nf}.yb1=zeros(obs{i,n}.nobs,1);
    obs{i,n,nf}.yb2=zeros(obs{i,n}.nobs,1);
    obs{i,n,nf}.innov=zeros(obs{i,n}.nobs,1);
    obs{i,n,nf}.resid=zeros(obs{i,n}.nobs,1);
    if(i==5);obs{i,n,nf}.nobs=185;end
    nprf(i,1)=1;
    iprf=1;
    for j=1:obs{i,n,nf}.nobs
        %a=fscanf(fid,'%f %f %g %f %f %f\n',6);
        a=fscanf(fid,'%f %f %g %f %f %f %f\n',7);
        obs{i,n,nf}.lon(j)=a(1);
        obs{i,n,nf}.lat(j)=a(2);
        obs{i,n,nf}.pres(j)=a(3);
        obs{i,n,nf}.y(j)=a(4);
        obs{i,n,nf}.yb1(j)=a(5);
        obs{i,n,nf}.yb2(j)=a(6);
        
        obs{i,n,nf}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
        if(obs{i,n,nf}.yb1(j)==-888888.000);obs{i,n,nf}.innov(j)=-888888.;end
        obs{i,n,nf}.resid(j)= obs{i,n,nf}.y(j)-obs{i,n,nf}.yb2(j);
        if(obs{i,n,nf}.yb2(j)==-888888.000);obs{i,n,nf}.resid(j)=-888888.;end
   end 
   if(i==5 & n<=16)
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
end
end

for i=1:36
plot(obs{5,1,i}.yb1(1:50),obs{5,1,i}.pres(1:50),'r');hold on
end
plot(obs{5,1,1}.y(1:50),obs{5,1,1}.pres(1:50),'k','linewidth',2.0);hold on

axis([0.012 0.03 0 5000])
