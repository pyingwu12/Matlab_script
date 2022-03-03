clear all
addpath('/work/scyang/matlab/map/m_map/')

figure(1);clf
iresid=1;
iinnov=0;
nvar=1;
nt=12;
if(nvar<=5)
  vert=0;
else
  vert=1;
end
fdir='/SAS002/SAS001_Backup/scyang/WRFEXPSV3/2008IOP8/e48b/da_out/wrfanal_d01_2008-06-13_00_00_00';
xlon=getnc(fdir,'XLONG',[1 -1 -1],[1 -1 -1])';
ylat=getnc(fdir,'XLAT',[1 -1 -1],[1 -1 -1])';
mask=getnc(fdir,'LANDMASK',[1 -1 -1],[1 -1 -1])';% (1:land)
%% mask==0:ocean, 1: land

dir='/SAS002/SAS001_Backup/scyang/WRFEXPSV3/2008IOP8/e48b/innov_bangle/';
mon=6;
dd=14;
hh=00;
iflag=0;
nobs_m=0;
nobs_o=0;
jprf=0;
bad=0;
lon_bad=0.0;
lat_bad=0.0;
for n=1:nt
clear file;
file=['model2obs_2008-06-',num2str(dd),'_',num2str(hh,'%2.2d'),'_00_00'];
infile=[dir,file];
fid=fopen(infile,'r');
for i=1:1
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
        a=fscanf(fid,'%f %f %g %f %f %f\n',7);
        obs{i,n}.lon(j)=a(1);
        obs{i,n}.lat(j)=a(2);
        obs{i,n}.pres(j)=a(3);
        obs{i,n}.y(j)=a(4);
        obs{i,n}.yb1(j)=a(5);
        obs{i,n}.yb2(j)=a(6);
        obs{i,n}.err(j)=a(7);
        if( abs(obs{i,n}.y(j)-obs{i,n}.yb1(j))> 0.1*obs{i,n}.err(j)*obs{i,n}.y(j)) 
            if(abs( obs{i,n}.lon(j)-lon_bad)>1.e-3 & abs( obs{i,n}.lat(j)-lat_bad)>1.e-3)
            bad=bad+1;
            lonbad(bad)=obs{i,n}.lon(j);
            latbad(bad)=obs{i,n}.lat(j);
            lon_bad=lonbad(bad);
            lat_bad=latbad(bad);
            end
        end
        
        obs{i,n}.innov(j)= obs{i,n}.y(j)-obs{i,n}.yb1(j);
        if(obs{i,n}.yb1(j)==-888888.000);obs{i,n}.innov(j)=-888888.;end
        obs{i,n}.resid(j)= obs{i,n}.y(j)-obs{i,n}.yb2(j);
        if(obs{i,n}.yb2(j)==-888888.000);obs{i,n}.resid(j)=-888888.;end

        if( obs{i,n}.lon(j)<= 122 &  obs{i,n}.lon(j)>= 105 &  obs{i,n}.lat(j)<= 25. &  obs{i,n}.lat(j)>= 15.)
            nobs_m=nobs_m+1;
            pres_m(nobs_m)=obs{i,n}.pres(j);
            y_m(nobs_m)=obs{i,n}.y(j);
            %if(pres_m(nobs_m)<200)
            %   [obs{i,n}.lon(j) obs{i,n}.lat(j)]
            %   [pres_m(nobs_m),n,j]
            %end
        else
            nobs_o=nobs_o+1;
            pres_o(nobs_o)=obs{i,n}.pres(j);
            y_o(nobs_o)=obs{i,n}.y(j);
        end
   end 

   if(i==1 )
   zi=100:100:5000;
   nz=length(zi);
   iprf=1;
   clear y yb x;
   jprf=jprf+1;
   y(iprf)=obs{i,n}.y(1);
   yb(iprf)=obs{i,n}.yb1(1);
   x(iprf)=obs{i,n}.pres(1);
   %if(n==1)
      lats(jprf)=obs{i,n}.lat(1);
      lons(jprf)=obs{i,n}.lon(1);
      flag(jprf)=0;
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

          if (abs(obs{i,n}.yb1(j)-obs{i,n}.y(j))>0.1*obs{i,n}.y(j)*obs{i,n}.err(j) & obs{i,n}.pres(j) <1.e3)
              iflag=iflag+1;
              lon_flag(iflag)=lons(jprf);
              lat_flag(iflag)=lats(jprf);
              flag(jprf)=1;
             infile
             [lats(jprf),lons(jprf)]
          %else
          %    flag(jprf)=0;
          end
       else
          if(iprf>3)
          yi(jprf,1:nz)=interp1(x,y,zi);
          ybi(jprf,1:nz)=interp1(x,yb,zi);
          else
            yi(jprf,1:nz)=NaN;
            ybi(jprf,1:nz)=NaN;
          end
          jprf=jprf+1;
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
          if (abs(obs{i,n}.yb1(j)-obs{i,n}.y(j))>0.1*obs{i,n}.y(j)*obs{i,n}.err(j) & obs{i,n}.pres(j) <1.e3)
              flag(jprf)=1;
             infile
              iflag=iflag+1;
              lon_flag(iflag)=lons(jprf);
              lat_flag(iflag)=lats(jprf);
             [lats(jprf),lons(jprf)]
          %else
          %    flag(jprf)=0;
          end
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

ii=0;
jj=0;

for i=1:size(yi,1)
    igrid=find( abs(lons(i)-xlon)<5.e-1 & abs(lats(i)-ylat)<5e-1);
    if(length(igrid)>1)
        [dum,ic]=max(abs(lons(i)-xlon(igrid))+abs(lats(i)-ylat(igrid)));
        jgrid=igrid(ic);
    else
        jgrid=igrid(1);
    end
    if( mask(jgrid)==0)
        ii=ii+1;
        valid(ii)=i;
    else
        jj=jj+1;
        invalid(jj)=i;
    end

    %for j=1:bad
    %    if(abs( lons(i)-lonbad(j))<1.e-3 & abs( lats(i)-latbad(j))<1.e-3) 
    %       ii=ii+1;
    %       valid(ii)=i;

    %   end
    %end
end
%valid=find( lons<= 122.5 &  lons>= 105 & lats<= 30. & lats>= 12.5);
%invalid=find( lons> 122.5 |  lons< 105 | lats> 30. | lats< 12.5);   
%valid=find(flag==0);
%invalid=find(flag==0);
%subplot(2,1,1)
yi1=nan*zeros(length(zi),1);
yi2=nan*zeros(length(zi),1);
ybi1=nan*zeros(length(zi),1);
ybi2=nan*zeros(length(zi),1);
for iz=1:length(zi)
    %if( sum(1-isnan(yi(valid,iz)))>2)
    yi1(iz)=nanmean(yi(valid,iz));
    %else
    %yi1(iz)=nan;
    %end
    %if( sum(1-isnan(yi(invalid,iz)))>2)
    yi2(iz)=nanmean(yi(invalid,iz));
    %else
    %yi2(iz)=nan;
    %end

    %if( sum(1-isnan(ybi(valid,iz)))>2)
    ybi1(iz)=nanmean(ybi(valid,iz));
    %else
    %ybi1(iz)=nan;
    %end
    %if( sum(1-isnan(ybi(invalid,iz)))>2)
    ybi2(iz)=nanmean(ybi(invalid,iz));
    %else
    %ybi2(iz)=nan;
    %end
end
subplot(2,1,1)
for i=fix(5*length(valid)/8)+1: 3*length(valid)/4
    %plot(nanmean(yi(valid(:),:),1),zi,'r');hold on
    figure(i);clf
    plot(yi(valid(i),:),zi,'r');hold on
    plot(ybi(valid(i),:),zi,'b');hold on
    axis([0 0.05 0 5000])
end

%   compute the std of ybi
%for i=1:length(valid)
    %plot(nanmean(ybi(valid(:),:),1),zi,'b');hold on
%end

%    std1=nanstd(ybi(valid(:),:),1); 
%    for i=1:length(zi)
%        plot([nanmean(ybi(valid(:),i),1)-std1(i) nanmean(ybi(valid(:),i),1)+std1(i)],[zi(i) zi(i)],'-bx');hold on
%    end    
set(gca,'xlim',[0. 0.08],'ylim',[0 2000]);
subplot(2,1,2)
for i=1:length(invalid)
    %plot(nanmean(yi(invalid(:),:),1),zi,'r');hold on
    plot(yi(invalid(i),:),zi,'r');hold on
end
for i=1:length(invalid)
    %plot(nanmean(ybi(invalid(:),:)),zi,'b');hold on
    plot(ybi(invalid(i),:),zi,'b');hold on
end
%    std1=nanstd(ybi(invalid(:),:),1); 
%    for i=1:length(invalid)
%        plot([nanmean(ybi(invalid(:),i),1)-std1(i) nanmean(ybi(invalid(:),i),1)+std1(i)],[zi(i) zi(i)],'-bx');hold on
%    end    
set(gca,'xlim',[0. 0.08],'ylim',[0 2000]);
return
figure(3)
for i=1:length(zi)
    errprf(i)=10.0-0.9*1.e-3*zi(i);
end
for i=1:size(yi,1)
    obserr(i,:)=0.01*errprf(1,:).*yi(i,:);
end
diffs_ocean=yi(valid(:),:)-ybi(valid(:),:);
diffs_land=yi(invalid(:),:)-ybi(invalid(:),:);
diff_ocean=nanmean(diffs_ocean,1)
diff_land=nanmean(diffs_land,1)

diff_ocean_rms=sqrt(nanmean((diffs_ocean.^2),1));
diff_land_rms=sqrt(nanmean((diffs_land.^2),1));

subplot(2,1,1)
plot(diff_ocean,zi,'b');hold on
plot(diff_land,zi,'r');
plot(diff_ocean_rms,zi,'--b');
plot(diff_land_rms,zi,'--r');

subplot(2,1,2)
%diff_ocean=nanmean( diffs_ocean./obserr(valid,:),1 );
%diff_land=nanmean( diffs_land./obserr(invalid,:) ,1);
diff_ocean=nanmean( diffs_ocean./yi(valid,:),1 );
diff_land=nanmean( diffs_land./yi(invalid,:) ,1);

diff=nanmean( (yi-ybi)./obserr,1);
diff_ocean_rms=sqrt(nanmean(diffs_ocean.^2,1))./nanmean(yi(valid,:),1) ;
diff_land_rms=sqrt(nanmean(diffs_land.^2,1))./nanmean(yi(invalid,:),1) ;
%diff_ocean_rms=sqrt(nanmean(diffs_ocean.^2,1))./nanmean(obserr(valid,:),1) ;
%diff_land_rms=sqrt(nanmean(diffs_land.^2,1))./nanmean(obserr(invalid,:),1) ;
diff_rms=sqrt(diff.^2/size(yi,1) );
plot(diff_ocean,zi,'--b');hold on
plot(diff_land,zi,'--r');
plot(diff_ocean_rms,zi,'-b');
plot(diff_land_rms,zi,'-r');
%plot(diff,zi,'-k');
%plot(diff_rms,zi,'--k');
axis([-1 1 0 5000.0])
