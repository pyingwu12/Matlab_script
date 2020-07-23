%function KE_spectral(expri,lev,stdate,sth,lenh)
clear;  
ccc=':';
close all
%---setting
expri1='twin02';    expri2='test94';
lev=1:17;   grids=1;
year='2018'; mon='06';  stdate=21;  sth=21;  lenh=12;
s_min='00';  dom='01';  infilenam='wrfout';  
%
indir='/mnt/HDD003/pwin/Experiments/expri_test/';
outdir='/mnt/e/figures/expri191009/';

col_ncl_WBGYR254;
col=color_map([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:)/255;
%
titnam='KE spectral';   fignam=[expri1,'-',expri2,'_KE'];
%%
%----
for ti=1:lenh 
   hr=sth+ti-1;
   hrday=fix(hr/24);  hr=hr-24*hrday;
   s_date=num2str(stdate+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
   legh{ti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST'];
   %---infile1 
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
   u.stag = ncread(infile1,'U'); u.stag=double(u.stag);
   v.stag = ncread(infile1,'V'); v.stag=double(v.stag);
   u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
   v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
   %---infile 2---
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
   u.stag = ncread(infile2,'U');  u.stag=double(u.stag);
   v.stag = ncread(infile2,'V');  v.stag=double(v.stag);
   u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
   v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
   %---difference---
   u.diff=u.f1-u.f2;   v.diff=v.f1-v.f2;

   if ti==1
   %---calculate Kh from 2D wave numbers---
     [nx, ny, nzi]=size(u.diff); 
     cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
     nk=zeros(nx,ny);
     for xi=1:nx
      for yi=1:ny
       nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
      end    
     end   
     nk2=round(nk); 
     KE.kh=zeros(max(max(nk2)),lenh); 
     KEp.kh=zeros(max(max(nk2)),lenh);
   end %if ti==1 
 
   %---calculate---
   for li=1:nzi
     %---2D fft 
     u.fft=fft2(u.f2(:,:,li));    v.fft=fft2(v.f2(:,:,li));
     u.perfft=fft2(u.diff(:,:,li));   v.perfft=fft2(v.diff(:,:,li));      
     %---calculate KE (power of the FFT)---
     KE.twoD(:,:,li) = (abs(u.fft).^2+abs(v.fft).^2)/nx/ny ;  %2-D low level mean      
     KEp.twoD(:,:,li) = (abs(u.perfft).^2+abs(v.perfft).^2)/nx/ny ;     
   end %li=lev
   %--shift
   KE.shi=fftshift(mean(KE.twoD,3));
   KEp.shi=fftshift(mean(KEp.twoD,3));   
   %---adjust 2D KE to 1D (wave number kh)---
   for ki=1:max(max(nk2))   
     KE.kh(ki,ti)=sum(KE.shi(nk2==ki));   % sum of different kx, ky to kh bin
     KEp.kh(ki,ti)=sum(KEp.shi(nk2==ki));
   end

   %disp([s_hr,' done'])
end %ti
%%
%close all
%---plot
hf=figure('position',[100 45 950 660]) ;
%h=plot(KE.khm,'LineWidth',1.55); hold on
%col=get(h,'Color');
for ti=1:lenh
plot(KE.kh(:,ti),'LineWidth',2.5,'Color',col(ti,:)); hold on
end
for ti=1:lenh
plot(KEp.kh(:,ti),'LineWidth',1.6,'LineStyle','--','Color',col(ti,:))
end
legend(legh,'Location','BestOutside','box','off')
%--- -3/5 line---
x53=-5:0.1:4; y53=7.35+(-5/3*x53);
plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
%----------------
xlabel('wavenumber','fontsize',16)
%
xlim=[1 min(nx,ny)]; ylim=[1e-2 1e7];
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',15)
set(gca,'Ylim',ylim)

ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
tit=[expri1,'  ',titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)

%---
outfile=[outdir,fignam,num2str(sth),s_min,...
    '_',num2str(lenh),'h_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
%set(hf,'PaperPositionMode','auto') 
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);



