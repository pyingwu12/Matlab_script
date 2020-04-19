clear;  ccc=':';
close all
%---setting
expri='ens02';   member=3;    lev=20;  % !! 1 member, 1 level
year='2018'; mon='06'; date='22';  hr=0;  minu='00';  dom='01';
dirmem='pert'; infilenam='wrfout';  
%
indir=['/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir='/mnt/e/figures/ens200323';
%
titnam='KE spectral';   fignam=[expri,'_KE-sptrl_'];

%----
mi=member; ti=hr;
s_hr=num2str(ti,'%.2d');  % start time string
nen=num2str(mi,'%.2d');
%---ensemble mean
infile=[indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,minu,ccc,'00'];
 u.stag = ncread(infile,'U');u.stag=double(u.stag);
 v.stag = ncread(infile,'V');v.stag=double(v.stag);
%---
 u.mean=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
 v.mean=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
%---a member---
infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,minu,ccc,'00'];
%------read netcdf data--------
 u.stag = ncread(infile,'U'); u.stag=double(u.stag);
 v.stag = ncread(infile,'V'); v.stag=double(v.stag);
%---
 u.unstag=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
 v.unstag=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5;
%---perturbation---
u.pert=u.unstag - u.mean;
v.pert=v.unstag - v.mean;
   
%---calculating---
[nx, ny]=size(u.unstag); 
%---2D fft 
u.fft=fft2(u.unstag(:,:));    v.fft=fft2(v.unstag(:,:));
u.perfft=fft2(u.pert(:,:));   v.perfft=fft2(v.pert(:,:));      
%---calculate KE (power of the FFT)---
KE.twoD = (abs(u.fft).^2+abs(v.fft).^2)/nx/ny ;  %2-D low level mean      
KEp.twoD = (abs(u.perfft).^2+abs(v.perfft).^2)/nx/ny ;     
%
KE.shi=fftshift(KE.twoD);
KEp.shi=fftshift(KEp.twoD);
%----
cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
nk=zeros(nx,ny);
for xi=1:nx
  for yi=1:ny
    nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
  end    
end   
nk2=round(nk);  
%---adjust 2D KE to 1D (wave number kh)---
KE.kh=zeros(max(max(nk2)),1); 
KEp.kh=zeros(max(max(nk2)),1);
for ki=1:max(max(nk2))   
  KE.kh(ki)=sum(KE.shi(nk2==ki));   % sum of different kx, ky to kh bin
  KEp.kh(ki)=sum(KEp.shi(nk2==ki));
end

%---plot
hf=figure('position',[100 100 800 600]) ;
h=plot(KE.kh,'LineWidth',1.55); hold on
col=get(h,'Color');
plot(KEp.kh,'LineWidth',1.5,'LineStyle','--','Color',col)

xlabel('k_h','fontsize',16)
set(gca,'YScale','log','XScale','log','XLim',[1 125],'Linewidth',1.2,'fontsize',15)
%---
tit=[expri,'  ',titnam,'  ',s_hr,'00UTC, mem',nen,', lev',num2str(lev,'%.2d')];     
title(tit,'fontsize',18)
outfile=[outdir,'/',fignam,s_hr,'_lev',num2str(lev,'%.2d'),'_m',nen];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

