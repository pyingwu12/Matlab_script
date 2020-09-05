clear;  ccc=':';
close all
%---setting
expri='TWIN001B';  stday=21;  hrs=[15 18 21 24 27 30 34 37];  lev=1:17;  
%--
year='2018';  mon='06'; s_min='30';  
infilenam='wrfout';   dom='01';   grids=1;
%
% indir=['/mnt/HDD009/pwin/Experiments/expri_single/',expri]; outdir=['/mnt/e/figures/expri_single/',expri];
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%
load('colormap/colormap_ncl.mat')
col0=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
col=col0(1:2:end,:);
%
titnam='KE spectra';   fignam=[expri,'_KE-sp_'];
%---
lenhr=length(hrs);
%
%----
lgnd=cell(lenhr,1);
for ti=1:lenhr
  hr=hrs(ti);
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  lgnd{ti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST'];
  %--- 
  infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];  
  u.stag = ncread(infile,'U'); u.stag=double(u.stag);
  v.stag = ncread(infile,'V'); v.stag=double(v.stag);
  %---
  u.unstag=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
  v.unstag=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5;
  %---
  if ti==1
  %---calculate Kh from 2D wave numbers---
    [nx, ny, nzi]=size(u.unstag); 
    cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
    nk=zeros(nx,ny);
    for xi=1:nx
      for yi=1:ny
       nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
      end    
    end   
    nk2=round(nk); 
    KE.kh=zeros(max(max(nk2)),length(hrs)); 
  end %if ti==1
   
  %---calculate---
  for li=1:nzi
    %---2D fft 
    u.fft=fft2(u.unstag(:,:,li));    v.fft=fft2(v.unstag(:,:,li));
    %---calculate KE (power of the FFT)---
    KE.twoD(:,:,li) = (abs(u.fft).^2+abs(v.fft).^2)/nx/ny ;  %2-D fft      
  end %li=lev
  %--shift
  KE.shi=fftshift(mean(KE.twoD,3)); %take level mean and shift
  %---adjust 2D KE to 1D (wave number kh)---
  for ki=1:max(max(nk2))   
    KE.kh(ki,ti)=sum(KE.shi(nk2==ki));   % sum of different kx, ky to kh bin
  end   
  disp([s_hr,' done'])
end %ti
lgnd{ti+1}='-5/3 line';
%
%---plot
hf=figure('position',[100 45 950 660]) ;
for ti=1:lenhr
plot(KE.kh(:,ti),'LineWidth',2.5,'Color',col(ti,:)); hold on
end
%--- -5/3 line---
x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
%----------------
legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','BestOutside')
%---
xlim=[1 min(nx,ny)]; ylim=[1e-2 1e7];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber')
%---second axis---
ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---
tit=[expri,'  ',titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_edh,s_min,...
    '_',num2str(lenhr),'step_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
