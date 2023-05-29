%----------------------
% plot spectra of difference total QV between two experiments
%----------------------
clear;  ccc=':';
close all
%---setting
expri='TWIN003';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
stday=22;  hrs=[21 22 23 24 25 26 27 28 29]; 
%--
year='2018';  mon='06'; s_min='00';  
infilenam='wrfout';   dom='01';   grids=1;
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin/';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%
titnam='PW diff. spectra';   fignam=[expri1(8:end),'_TPWqvdiff-sp_'];
%
load('../colormap/colormap_ncl.mat')
col0=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
col=col0(1:3:end,:);
%---
lenhr=length(hrs);
%---
lgnd=cell(lenhr,1);
for ti=1:lenhr
  hr=hrs(ti);
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  lgnd{ti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST'];    
  %---infile1 (perturbed state)---
  infile=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
  qv = ncread(infile,'QVAPOR');qv=double(qv); 
  p = ncread(infile,'P');p=double(p);   pb = ncread(infile,'PB');pb=double(pb);  
  hgt = ncread(infile,'HGT');
  %---
  [nz]=size(qv,3);
  P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
  tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
  TPW1=squeeze(sum(tpw,3)./9.81);
  %
  %---infile 2 (based state)---
  infile=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
  qv = ncread(infile,'QVAPOR');qv=double(qv); 
  p = ncread(infile,'P');p=double(p);   pb = ncread(infile,'PB');pb=double(pb);  
  %---
  P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
  tpw= dP.*( (qv(:,:,2:nz,:)+qv(:,:,1:nz-1,:)).*0.5 ) ;
  TPW2=squeeze(sum(tpw,3)./9.81);
  %---difference---
  diff_qv=TPW1-TPW2;
  %---
  if ti==1
    [nx, ny]=size(diff_qv);
    cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
    nk=zeros(nx,ny);
    for xi=1:nx
      for yi=1:ny
       nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
      end    
    end   
    nk2=round(nk); 
    KE.kh=zeros(max(max(nk2)),length(hrs)); 
    KEp.kh=zeros(max(max(nk2)),length(hrs));
  end
  
  %---2D fft
  qvfft=fft2(TPW2);
  diffqv.fft=fft2(diff_qv);    
  %---calculate KE (power of the FFT)---
  KE.twoD = (abs(qvfft).^2)/nx/ny ;  %2-D    
  KEp.twoD = (abs(diffqv.fft).^2)/nx/ny ;  %2-D    
  %--shift
  KE.shi=fftshift(KE.twoD);
  KEp.shi=fftshift(KEp.twoD);
  %---adjust 2D KE to 1D (wave number kh)---
  for ki=1:max(max(nk2))   
    KE.kh(ki,ti)=sum(KE.shi(nk2==ki));
    KEp.kh(ki,ti)=sum(KEp.shi(nk2==ki));   % sum of different kx, ky to kh bin
  end 
  disp([s_hr,' done'])
end %ti
lgnd{ti+1}='-5/3 line';
%
%---plot
hf=figure('position',[100 45 950 660]) ;
%---based state
for ti=1:lenhr
plot(KE.kh(:,ti),'LineWidth',2.5,'LineStyle','-','color',col(ti,:)); hold on
end
%--- -5/3 line---
x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
%---difference----
for ti=1:lenhr
plot(KEp.kh(:,ti),'LineWidth',2,'LineStyle','--','color',col(ti,:)); hold on
end
%----------------
legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','BestOutside')
%---
xlim=[1 min(nx,ny)]; ylim=[1e-2 1e6];
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
tit=[expri1,'  ',titnam];     
title(tit,'fontsize',18)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_edh,'_',s_min,'_',num2str(lenhr),'step'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
