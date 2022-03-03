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
iresid=1;
iinnov=0;
nvar=4;
if(nvar<=5)
  vert=0;
else
  vert=1;
end

ct{1}='m';
ct{2}='g';
ct{3}='b';
ct{4}='r';
subtit{1}='(a)';
subtit{2}='(b)';
subtit{3}='(c)';
subtit{4}='(d)';
unit{1}='(m/s)';
unit{2}='(m/s)';
unit{3}='(K)';
unit{4}='(10^{3} g/kg)';
dir='/SAS002/SAS001_Backup/scyang/WRFEXPSV3/2008IOP8/e48b/innov_bangle20km/';
dir_ens='/SAS002/SAS001_Backup/scyang/WRFEXPSV3/2008IOP8/e48b/innov_ens/';

nvar=1;

for nf=1:1
mon=6;
dd=15;
hh=00;
nt=8;
for n=1:nt*1
    clear file;
    file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),':00:00'];
    infile=[dir,file];
    fid=fopen(infile,'r');
    for i=1:4
        obs{i,n}.type=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
        obs{i,n}.var=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
        obs{i,n}.nobs=fscanf(fid,'%u',1); %*d %e %e %e %e\n',4);
        obs{i,n}.pres=zeros(obs{i,n}.nobs,1);
        obs{i,n}.yb1=zeros(obs{i,n}.nobs,1);
        obs{i,n}.yb2=zeros(obs{i,n}.nobs,1);
        obs{i,n}.innov=zeros(obs{i,n}.nobs,1);
        obs{i,n}.resid=zeros(obs{i,n}.nobs,1);
        for j=1:obs{i,n}.nobs
            %a=fscanf(fid,'%f %f %g %f %f %f\n',6);
            a=fscanf(fid,'%f %f %g %f %f %f %f\n',7);
            obs{i,n}.lon(j)=a(1);
            obs{i,n}.lat(j)=a(2);
            obs{i,n}.pres(j)=a(3);
            obs{i,n}.y(j)=a(4);
            obs{i,n}.yb1(j)=a(5);
            obs{i,n}.yb2(j)=a(6);
            obs{i,n}.err(j)=a(7);
            if(i==4)
               obs{i,n}.yb1(j)=obs{i,n}.yb1(j)*1.e3;
               obs{i,n}.yb2(j)=obs{i,n}.yb2(j)*1.e3;
               obs{i,n}.err(j)=1.0;
            end
            obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
            if(obs{i,n}.yb1(j)==-888888.000);obs{i,n}.innov(j)=-888888.;end
            obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
            if(obs{i,n}.yb2(j)==-888888.000);obs{i,n}.resid(j)=-888888.;end
         end %j
     end %i
     fclose(fid);

     % ensemble files
     k_valid=0;
     for k=1:36
         file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),':00:00.',num2str(k,'%2.2d')];
         infile=[dir_ens,file];
         fid=fopen(infile,'r');
         if(fid>=0)
            k_valid=k_valid+1;
            for i=1:4
                ens{i,n}.type=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
                ens{i,n}.var=fscanf(fid,'%s',1) ;%*d %e %e %e %e\n',4);
                ens{i,n}.nobs=fscanf(fid,'%u',1); %*d %e %e %e %e\n',4);
                if(k==1)
                   ens{i,n}.pres=zeros(ens{i,n}.nobs,34);
                   ens{i,n}.yb1=zeros(ens{i,n}.nobs,34);
                   ens{i,n}.yb2=zeros(ens{i,n}.nobs,34);
                   ens{i,n}.spread=zeros(ens{i,n}.nobs,2);
                end
                for j=1:ens{i,n}.nobs
                    %a=fscanf(fid,'%f %f %g %f %f %f\n',6);
                    a=fscanf(fid,'%f %f %g %f %f %f %f\n',7);
                    ens{i,n}.lon(j)=a(1);
                    ens{i,n}.lat(j)=a(2);
                    ens{i,n}.pres(j,k_valid)=a(3);
                    ens{i,n}.y(j,k_valid)=a(4);
                    ens{i,n}.yb1(j,k_valid)=a(5);
                    ens{i,n}.yb2(j,k_valid)=a(6);
                    if(i==4)
                       ens{i,n}.yb1(j,k_valid)=ens{i,n}.yb1(j,k_valid)*1.e3;
                       ens{i,n}.yb2(j,k_valid)=ens{i,n}.yb2(j,k_valid)*1.e3;
                    end
               end %j
            end %i
            fclose(fid);
         end %if_loop
     end %k_loop
    for i=1:4
        for j=1:ens{i,n}.nobs
            ens{i,n}.spread(j,1)=var(ens{i,n}.yb1(j,:));
            ens{i,n}.spread(j,2)=var(ens{i,n}.yb2(j,:));
        end
    end


    hh=hh+6;
    if(hh>=24)
       hh=hh-24;
       dd=dd+1;
    end

    end %n

    if(vert==1)
       z=0:100:5000;
    else
       %z=[50,100,200,300,500,600,700,850,950,1000]; % center of the layers
       %zz(1)=20;
       %for ii=2:length(z)
       %    zz(ii)=0.5*(z(ii-1)+z(ii));
       %end
       %zz(length(z)+1)=1050;
       zz=[25,75, 150, 250, 350, 450, 550, 650, 750,850,950,1050];
       z=[  50, 100, 200, 300, 400, 500, 600,700, 800,900,1000];
    end
    
    xmin=[-2, -2, -2, -2];
    xmax=[ 7,  7,  5, 3];
    for nvar=1:4
        if(nvar==1);cvar='U';end
        if(nvar==2);cvar='V';end
        if(nvar==3);cvar='T';end
        if(nvar==4);cvar='Qv';end
        innov=zeros(length(z),2);
        resid=zeros(length(z),2);
        spread=zeros(length(z),2);
        obserr=zeros(length(z),1);
        ncount=zeros(length(z),1);
        for n=1:nt
            for j=1:obs{nvar,n}.nobs 
                %if( obs{nvar,n}.lon(j)<= 125 &  obs{nvar,n}.lon(j)>= 105 &  obs{nvar,n}.lat(j)<= 30. &  obs{nvar,n}.lat(j)>= 5.)
                if(vert==1)
                   nz=max(find(z<=obs{nvar,n}.pres(j)));
                else
                   nz=max(find(zz<=1.e-2*obs{nvar,n}.pres(j)));
                end
        
                if(nz>0 & nz<=length(z))
                   innov(nz,1)=innov(nz,1)+obs{nvar,n}.innov(j); 
                   innov(nz,2)=innov(nz,2)+obs{nvar,n}.innov(j).^2; 
                   resid(nz,1)=resid(nz,1)+obs{nvar,n}.resid(j); 
                   resid(nz,2)=resid(nz,2)+obs{nvar,n}.resid(j).^2; 
                   spread(nz,1)=spread(nz,1)+ens{nvar,n}.spread(j,1);
                   spread(nz,2)=spread(nz,2)+ens{nvar,n}.spread(j,2);
                   obserr(nz,1)=obserr(nz,1)+obs{nvar,n}.err(j).^2;
                   ncount(nz)= ncount(nz)+1;
                end
            end
            eval(['ncount',num2str(nvar),'=ncount;'])
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
            %y0=3;
            %plot([0 0],[0 5],'color',[0.5 0.5 0.5]);
            %set(gca,'ylim',[0 5-y0],'xlim',[-0.022 0.022])
        else
            if(iinnov==0)
               subplot(2,2,nvar)
               plot(innov(:,1)./ncount(:),-z,'k','linewidth',1.0,'linestyle','-.');hold on
               plot(sqrt(innov(:,2)./ncount(:)),-z,'k','linewidth',2.0);hold on
               plot(sqrt(1.15)*sqrt(spread(:,1)./ncount(:))+sqrt(obserr(:,1)./ncount(:)),-z,'k','linewidth',1.0,'linestyle','--');hold on
            elseif(iresid==0)
               plot(resid(:,1,n)./ncount(:,n),-z,'k','linestyle','--');hold on
               plot(sqrt(resid(:,2,n)./ncount(:,n)),-z,'k','linestyle','-','linewidth',2.0);hold on
            end
            set(gca,'ylim',[-1010 -40],'xlim',[xmin(nvar) xmax(nvar)],'ytick',[-1000:100:-100,-50],...
            'yticklabel',{'1000','900','800','700','600','500','400','300','200','100','50'})
            plot([0 0],[-1000 50],'color',[0.5 0.5 0.5]);
        end
        xlabel(['Error ',unit{nvar}],'fontsize',12)
        ylabel('Pressure (hPa)','fontsize',12)
        title([subtit{nvar},' ',cvar],'fontweight','bold','fontsize',14)
        
        eval(['ncount=ncount',num2str(nvar),';'])
        for k=1:length(z)
            text(xmax(nvar),-z(k),num2str(ncount((k))),'horizontalalignment','right','fontsize',8,...
            'verticalalignment','middle');
        end
    end %nvar
        
%        if(nf==1)
%           x1=3.5; x2=6.5;
%           xl=x1+0.075*(x2-x1);
%           y2=-720;
%           dy=20;
%           plot([xl xl+0.15*(x2-x1)],[y2-y0 y2-y0],'-k')
%           plot([xl xl+0.15*(x2-x1)],[y2-dy-y0 y2-dy-y0],'r')
%           plot([xl xl+0.15*(x2-x1)],[y2-2*dy-y0 y2-2*dy-y0],'-b')
%           text(xl+0.16*(x2-x1),y2-0.05*dy-y0,'CNTL','horizontalalignment','left')
%           text(xl+0.16*(x2-x1),y2-1.05*dy-y0,'REF','horizontalalignment','left')
%           text(xl+0.16*(x2-x1),y2-2.05*dy-y0,'BANGLE','horizontalalignment','left')
%           set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 5 10])
%        end
%
end %nf
set(gcf,'paperorientation','portrait','paperposition',[0.5 .75 10 7])
