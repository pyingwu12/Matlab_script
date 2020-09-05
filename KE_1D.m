clear;  ccc=':';
close all
%---setting
expri='ens02';   member=1:10;    lev=15;   yi=100;  xi=100; mmi=5;
%year='2007'; mon='06'; date='01';
year='2018'; mon='06'; date='22';  hr=1;  minu='00';  dom='01';
%year='2008'; mon='06'; date='16';  hr=2;  minu='00';  dom='02';
dirmem='pert'; infilenam='wrfout';  

indir=['/HDD003/pwin/Experiments/expri_ens200323/',expri];
%indir=['E:/wrfout/expri_ens200323/',expri];
%indir='E:/wrfout/largens';
%outdir='E:/figures/ens200323';
outdir='/mnt/e/figures/ens200323';


ti=hr;
s_hr=num2str(ti,'%.2d');  % start time string
nmi=0;
for mi=member
nmi=nmi+1;
nen=num2str(mi,'%.2d');
infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,ccc,minu,ccc,'00'];

%------read netcdf data--------
u.stag = ncread(infile,'U');u.stag=double(u.stag);
v.stag = ncread(infile,'V');v.stag=double(v.stag);
%---
uunstag(:,nmi)=(u.stag(1:end-1,yi,lev)+u.stag(2:end,yi,lev))*0.5;
vunstag(:,nmi)=(v.stag(:,yi,lev)+v.stag(:,yi+1,lev))*0.5;
%uunstag(:,nmi)=(u.stag(xi,:,lev)+u.stag(xi+1,:,lev))*0.5;
%vunstag(:,nmi)=(v.stag(xi,1:end-1,lev)+v.stag(xi,2:end,lev))*0.5;
end

umean=mean(uunstag,2);
vmean=mean(vunstag,2);
nx=length(umean);
%
upert=uunstag-repmat(umean,1,length(member));
vpert=vunstag-repmat(vmean,1,length(member));


%-----------------------
%%
figure('position',[100 100 800 500])
subplot(3,1,1)
h1=plot(uunstag(:,mmi),'LIneWidth',2);
title('u','fontsize',13)
[yL]=get(gca,'Ylim');
set(gca,'LineWidth',1.2,'fontsize',12)
%set(gca,'YLim',[min(uunstag(:,mmi)) max(uunstag(:,mmi)) ])
subplot(3,1,2)
plot(upert(:,mmi),'LIneWidth',2)
title('u pert','fontsize',13)
set(gca,'LineWidth',1.2,'fontsize',12)
subplot(3,1,3)
plot(umean,'LIneWidth',2)
title('u mean','fontsize',13)
set(gca,'YLim',yL,'LineWidth',1.2,'fontsize',12)
print('-dpng',[outdir,'/U_1D.png']) 
 system(['convert -trim ',[outdir,'/U_1D'],'.png ',[outdir,'/U_1D'],'.png']);
%%
%-----------
%
ufft=fft(uunstag(:,mmi));
vfft=fft(vunstag(:,mmi));
%
upfft=fft(upert(:,mmi));
vpfft=fft(vpert(:,mmi));

figure('position',[100 100 600 500])
h=plot(abs(ufft)/nx,'LineWidth',2); hold on
col=get(h,'color');
plot(abs(upfft)/nx,'LineWidth',2,'color',col,'Linestyle','--')
%
title('u-fft power spectrum','fontsize',13)
set(gca,'XLim',[1 nx/2-1],'XScale','log','YScale','log','LineWidth',1.2,'fontsize',12)
%
outfile=[outdir,'/fft_U1D_nx'];
print('-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);

%-------
%{

KEu=abs(ufft1).^2;
KEv=abs(vfft1).^2;
KE=(KEu+KEv);
%KEmean=mean(KE,2);

KEup=abs(upfft1).^2;
KEvp=real(vpfft1).^2+imag(vpfft1).^2;
KEp=(KEup+KEvp);
%KEpmean=mean(KEp,2);


figure
subplot(2,2,1)
plot(KEu)
title('KE u')
set(gca,'XLim',[1 nx/2-1],'YLim',[1 1e6],'YScale', 'log','XScale', 'log')
%set(gca,'YScale', 'log','XScale', 'log')

subplot(2,2,2)
plot(KEv)
title('KE v')
set(gca,'XLim',[1 nx/2-1],'YLim',[1 1e6],'YScale', 'log','XScale', 'log')
%set(gca,'YScale', 'log','XScale', 'log')

subplot(2,2,3)
plot(KEup)
title("KE u' ")
set(gca,'XLim',[1 nx/2-1],'YLim',[1 1e6],'YScale', 'log','XScale', 'log')
%set(gca,'YScale', 'log','XScale', 'log')

subplot(2,2,4)
plot(KEvp)
title("KE v' ")
set(gca,'XLim',[1 nx/2-1],'YLim',[1 1e6],'YScale', 'log','XScale', 'log')
%set(gca,'YScale', 'log','XScale', 'log')
figure
plot(KE); hold on
plot(KEp)
set(gca,'XLim',[1 nx/2-1],'YLim',[1 1e6],'YScale', 'log','XScale', 'log')
%set(gca,'YScale', 'log','XScale', 'log')
%}
