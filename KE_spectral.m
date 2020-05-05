clear;  ccc=':';
close all
%---setting
expri='ens05';      lev=1:17; 
year='2018'; mon='06';  stdate=21;  sth=21;  lenh=8;
minu='00';  dom='01';  member=1:20; 
dirmem='pert'; infilenam='wrfout';  
%
indir=['/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir='/mnt/e/figures/ens200323';
%
titnam='KE spectral';   fignam=[expri,'_KE-sptrl_'];
%%
%----
for ti=1:lenh 
   hr=sth+ti-1;
   hrday=fix(hr/24);  hr=hr-24*hrday;
   s_date=num2str(stdate+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
   legh{ti}=[s_hr,minu,' UTC'];
   %---ensemble mean
   infile=[indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
   u.stag = ncread(infile,'U');u.stag=double(u.stag);
   v.stag = ncread(infile,'V');v.stag=double(v.stag);
   %---
   u.mean=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
   v.mean=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
   if ti==1
   %---calculate Kh from 2D wave numbers---
   [nx, ny, nzi]=size(u.mean); 
   cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
   nk=zeros(nx,ny);
   for xi=1:nx
     for yi=1:ny
      nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
     end    
   end   
   nk2=round(nk); 
   KE.khm=zeros(max(max(nk2)),lenh); 
   KEp.khm=zeros(max(max(nk2)),lenh);
   end %if ti==1
   KE.kh=zeros(max(max(nk2)),length(member)); 
   KEp.kh=zeros(max(max(nk2)),length(member));
   %---members---   
   for mi=member
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
      %------read netcdf data--------
      u.stag = ncread(infile,'U'); u.stag=double(u.stag);
      v.stag = ncread(infile,'V'); v.stag=double(v.stag);
      %---
      u.unstag=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
      v.unstag=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5;
      %---perturbation---
      u.pert=u.unstag - u.mean;
      v.pert=v.unstag - v.mean;
      %
      %---calculate---
      for li=1:nzi
      %---2D fft 
      u.fft=fft2(u.unstag(:,:,li));    v.fft=fft2(v.unstag(:,:,li));
      u.perfft=fft2(u.pert(:,:,li));   v.perfft=fft2(v.pert(:,:,li));      
      %---calculate KE (power of the FFT)---
      KE.twoD(:,:,li) = (abs(u.fft).^2+abs(v.fft).^2)/nx/ny ;  %2-D low level mean      
      KEp.twoD(:,:,li) = (abs(u.perfft).^2+abs(v.perfft).^2)/nx/ny ;     
      end %li=lev
      %--shift
      KE.shi=fftshift(mean(KE.twoD,3));
      KEp.shi=fftshift(mean(KEp.twoD,3));   
      %---adjust 2D KE to 1D (wave number kh)---
      for ki=1:max(max(nk2))   
        KE.kh(ki,mi)=sum(KE.shi(nk2==ki));   % sum of different kx, ky to kh bin
        KEp.kh(ki,mi)=sum(KEp.shi(nk2==ki));
      end
   end %member
   KE.khm(:,ti)=mean(KE.kh,2);
   KEp.khm(:,ti)=mean(KEp.kh,2);

end %ti
%%
%---plot
hf=figure('position',[100 100 950 600]) ;
h=plot(KE.khm,'LineWidth',1.55); hold on
col=get(h,'Color');
for ti=1:lenh
plot(KEp.khm(:,ti),'LineWidth',1.5,'LineStyle','--','Color',col{ti})
end
legend(legh,'Location','BestOutside')
%plot(KEp.khm,'LineWidth',1.5,'LineStyle','--','Color',col)

xlabel('k_h','fontsize',16)
set(gca,'YScale','log','XScale','log','XLim',[1 150],'Linewidth',1.2,'fontsize',15)
set(gca,'Ylim',[1e-2 1e5])
%---
tit=[expri,'  ',titnam,'  lev'...
    ,num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)
outfile=[outdir,'/',fignam,num2str(sth),minu,...
    '_',num2str(lenh),'h_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
%set(hf,'PaperPositionMode','auto') 
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

