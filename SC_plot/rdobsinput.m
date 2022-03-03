figure(1);clf
clear all
dir='/SAS002/SAS001_Backup/ailin/GPS/20080612-17/COSMIC/Bend_ang/IOP_res27/NewH/';
file='obs_2008-06-13_00_00_00';
nt=1;
dd=15;hh=00;
i=1;
n1=0;
n2=0;
for nt=1:12
    file(13:14)=num2str(dd,'%2.2d');
    file(16:17)=num2str(hh,'%2.2d');
    infile=[dir,file];
    fid=fopen(infile,'r');
    st=0;
    while (st == 0 )
       obs{i,nt}.lon=fscanf(fid,'%f',1);
       obs{i,nt}.lat=fscanf(fid,'%f',1);
       obs{i,nt}.nobs=fscanf(fid,'%u',1);
       obs{i,nt}.nvar=fscanf(fid,'%u',1);
       obs{i,nt}.nlev=fscanf(fid,'%u',1);
       obs{i,nt}.note=fscanf(fid,'%s',1);
       lnn=zeros(obs{i,nt}.nobs,1);
       x=zeros(obs{i,nt}.nobs,1);
       for j=1:obs{i,nt}.nobs
           dum=fscanf(fid,'%f %f %f %f\n',4);
           obs{i,nt}.z(j)=dum(1);
           obs{i,nt}.ref(j)=dum(2);
           obs{i,nt}.bnd(j)=dum(3);
           obs{i,nt}.a(j)=dum(4);
           lnn(j)=log(obs{i,nt}.ref(j)*1.e-6+1.0d0);
           x(j)=(6365000.0+obs{i,nt}.z(j))*(obs{i,nt}.ref(j)*1.e-6+1.0d0);
       end
       dlnndz=(lnn(2:obs{i,nt}.nobs)-lnn(1:obs{i,nt}.nobs-1))./(x(2:obs{i,nt}.nobs)-x(1:obs{i,nt}.nobs-1));
       zm=0.5*(obs{i,nt}.z(2:obs{i,nt}.nobs)+obs{i,nt}.z(1:obs{i,nt}.nobs-1));
       index=find(zm<=10000);
       nsize=length(index);
       n1=n2+1; n2=n1+nsize-1;
       xx(n1:n2)=1.e-3*(zm(index)-5000);
       yy(n1:n2)=1.e7*dlnndz(index);
       %xm=0.5*(x(2:end)+x(1:end-1));
       %plot(dlnndz,zm,'-k.','linewidth',0.5); hold on
       plot(lnn,obs{i,nt}.z,'k.','linewidth',0.5); hold on
       return
       %plot(obs{i,nt}.ref,obs{i,nt}.z,'k.','linewidth',0.5); hold on
       clear lnn dlnndz zm x;
       clear obs{i,nt}.z obs{i,nt}.ref;
       st=feof(fid);
       i=i+1;
    end

    set(gca,'Xlim',[0 5000]);
    fclose(fid);
    hh=hh+6;
    if(hh>=24)
       dd=dd+1;
       hh=hh-24;
    end 
end

       return
%plot(xx,yy,'k.');hold on
[yyr,a]=multireg(xx',yy',5);
%plot(xx,yyr,'r.');
SSR=sum((yy'-yyr).^2);
SST=sum((mean(yy')-yy).^2);
rr=(SST-SSR)/SST
plot(1.e-7*yyr,1.e3*xx+5000.0,'r.');
axis([-20e-8 5e-8 0 10000])
