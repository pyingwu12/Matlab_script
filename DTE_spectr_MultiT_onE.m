%------------------------------------------
% calculate power spectra of moist different total engergy 
% plot: diff, diff+cntl, diff ratio to cntl
%------------------------------------------
close all
clear;  ccc=':';
saveid=1;
%---
expri='TWIN013';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
%day=22;  hrs=[21 22 23 24 25 26 27 28];% minu=00; % thesis
day=22;  hrs=[21 22 23 24 25 26 27 28 29];% minu=00;
% stday=23; hrs=[0 1 2];
minu=[00 30];
lev=1:33;  
%--
year='2018';  mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='CMDTE spectra';  
%
load('colormap/colormap_ncl.mat')
col0=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
col=col0(1:2:end,:);
%---
nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%
cp=1004.9;
R=287.04;
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
Pr=1000;

%---
lgnd=cell(ntime,1);   nti=0;
for ti=hrs
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;  s_date=num2str(day+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');   
  for mi=minu 
    nti=nti+1;    s_min=num2str(mi,'%2.2d'); 
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
   
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    
    PowSpe=cal_spectr(infile1,infile2,lev);
    
    spetr.diff_kh(:,nti)=PowSpe.CMDTE;
    spetr.cntl_kh(:,nti)=PowSpe.CMTE;    
    %{
     u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');   w.stag = ncread(infile1,'W');
     u.f1=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
     v.f1=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5;     
     th.f=ncread(infile1,'T')+300;  th.f1=th.f(:,:,lev);
     qv.f=ncread(infile1,'QVAPOR');  qv.f1=double(qv.f(:,:,lev)); 
     p.p=ncread(infile1,'P');  p.b = ncread(infile1,'PB');  p.f1=(p.p(:,:,lev)+p.b(:,:,lev))/100;  
     t.f1=th.f1.*(1e3./p.f1).^(-R/cp);     
     psfc.f1 = ncread(infile1,'PSFC')/100; 
    %---infile 2, based state---
     u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');    w.stag = ncread(infile2,'W');
     u.f2=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
     v.f2=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
     
     th.f=ncread(infile2,'T')+300;  th.f2=th.f(:,:,lev);
     qv.f=ncread(infile2,'QVAPOR');  qv.f2=double(qv.f(:,:,lev)); 
     p.p=ncread(infile2,'P');  p.b = ncread(infile2,'PB');  p.f2=(p.p(:,:,lev)+p.b(:,:,lev))/100;
     t.f2=th.f2.*(1e3./p.f2).^(-R/cp);     
     psfc.f2 = ncread(infile2,'PSFC')/100; 
    %---calculate different
    u.diff=u.f1-u.f2; 
    v.diff=v.f1-v.f2;
    t.diff=t.f1-t.f2;    
    qv.diff=qv.f1-qv.f2;
    psfc.diff=psfc.f1-psfc.f2;    
  %---
    if nti==1 %---calculate Kh from 2D wave numbers---  
      [nx, ny, nzi]=size(u.diff); 
      cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
      nk=zeros(nx,ny);
      for xi=1:nx
        for yi=1:ny
         nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
        end    
      end   
      nk2=round(nk); 
      KE.kh=zeros(max(max(nk2)),ntime); 
      KEp.kh=zeros(max(max(nk2)),ntime);
    end %if ti==1   
    
    psfc.fft=fft2(psfc.f2);
    psfc.perfft=fft2(psfc.diff);
  %---calculate---
    for li=1:nzi
      %---2D fft 
      u.fft=fft2(u.f2(:,:,li));   
      v.fft=fft2(v.f2(:,:,li));
      t.fft=fft2(t.f2(:,:,li));
      qv.fft=fft2(qv.f2(:,:,li));    
   %---
      u.perfft=fft2(u.diff(:,:,li));   
      v.perfft=fft2(v.diff(:,:,li));  
      t.perfft=fft2(t.diff(:,:,li));
      qv.perfft=fft2(qv.diff(:,:,li));      
    %---calculate KE (power of the FFT)---
       KE.twoD(:,:,li) = (abs(u.fft).^2 + abs(v.fft).^2 + cp/Tr*abs(t.fft).^2 +...
           Lv^2/cp/Tr*abs(qv.fft).^2 + R*Tr*abs(psfc.fft/Pr).^2)/nx/ny ;  %2-D low level mean      
       KEp.twoD(:,:,li) = (abs(u.perfft).^2 + abs(v.perfft).^2 + cp/Tr*abs(t.perfft).^2 +...
           Lv^2/cp/Tr*abs(qv.perfft).^2 + R*Tr*abs(psfc.perfft/Pr).^2)/nx/ny ;          
    end %li=lev
    %--shift
    KE.shi=fftshift(mean(KE.twoD,3));
    KEp.shi=fftshift(mean(KEp.twoD,3));   
    %---adjust 2D KE to 1D (wave number kh)---
    for ki=1:max(max(nk2))   
      KE.kh(ki,nti)=sum(KE.shi(nk2==ki));   % sum of different kx, ky to kh bin
      KEp.kh(ki,nti)=sum(KEp.shi(nk2==ki));
    end
    %}
  end %mi
  disp([s_hr,' done'])  
end %ti
vinfo = ncinfo(infile1,'U10');   nx = vinfo.Size(1); ny = vinfo.Size(2); 
lgnd{nti+1}='-5/3 line';
%%
%{
%---plot
 fignam=[expri1(8:end),'_CMDTE-spectr_',];
hf=figure('position',[100 45 955 660]) ;
%---
% for ti=1:nhr*length(minu)
% plot(KE.kh(:,ti),'LineWidth',2.5,'LineStyle','-','color',col(ti,:)); hold on
% end
% %--- -5/3 line---
% x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
% plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
% %----------------
% for ti=1:lenhr*length(minu)
% plot(KEp.kh(:,ti),'LineWidth',2,'LineStyle','--','color',col(ti,:)); hold on
% end
% legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','BestOutside')
%-------------
plotime=[1 4 7 10 11 12 13 14 15 16 17 18 19 ];
col=col0(1:2:end,:);
n=0;
for ti=plotime
n=n+1;
plot(spetr.diff_kh(:,ti),'LineWidth',3,'LineStyle','--','color',col(n,:)); hold on
lgnd2{n}=lgnd{ti};
end
%
lgnd2{n+1}='cntl13';
plot(spetr.cntl_kh(:,21),'color',[0.3 0 0],'LineWidth',3,'LineStyle','-')
lgnd2{n+2}='-5/3 line';
x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
legend(lgnd2,'Box','off','Interpreter','none','fontsize',20,'Location','BestOutside')
%
%---
xlim=[1 min(nx,ny)]; ylim=[3e-2 1e6];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber')
ylabel('J kg^-^1')
%---second axis---
ax1=gca;  set(ax1,'Position',ax1.Position-[0 0 0 0.075]) 
ax1_pos = ax1.Position;
box off
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---
tit=[expri1,'  ',titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),...
    '_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d'),'_2'];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
%%
%
 fignam=[expri1(8:end),'_CMDTE-spectr_',];
col=col0;
% col=col0([1:2:29,30],:);
%---plot
hf=figure('position',[100 45 930 660]) ;
%---
for ti=1:ntime
plot(spetr.cntl_kh(:,ti),'LineWidth',2.5,'LineStyle','-','color',col(ti,:)); hold on
end
%--- -5/3 line---
x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
%----------------
for ti=1:ntime
plot(spetr.diff_kh(:,ti),'LineWidth',2,'LineStyle','--','color',col(ti,:)); hold on
end
legend(lgnd,'Box','off','Interpreter','none','fontsize',13,'Location','BestOutside')
%-------------
xlim=[1 min(nx,ny)]; ylim=[3e-2 1e6];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber')
%---second axis---
ax1=gca; 
set(ax1,'Position',ax1.Position-[0 0 0 0.075])
ax1_pos = ax1.Position; 
box off
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---
tit=[expri1,'  ',titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),...
    '_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
%% diff ratio to cntl
% 
fignam=[expri1(8:end),'_CMDTE-spectr-ratio_',];
ratio=spetr.diff_kh./spetr.cntl_kh;
col=col0;
% col=col0([1:2:29,30],:);
%---plot
hf=figure('position',[100 45 930 660]) ;
%---
for ti=1:ntime
plot(ratio(:,ti),'LineWidth',2.5,'LineStyle','-','color',col(ti,:)); hold on
end
lgnd{end}='2 times';
line([1 min(nx,ny)],[2 2],'color','k','linewidth',2.2,'linestyle','--')
legend(lgnd,'Box','off','Interpreter','none','fontsize',13,'Location','BestOutside')
%-------------
xlim=[1 min(nx,ny)]; ylim=[1e-7 5];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber')
%---second axis---
ax1=gca; 
set(ax1,'Position',ax1.Position-[0 0 0 0.075])
ax1_pos = ax1.Position; 
box off
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---
tit=[expri1,'  ratio  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),...
    '_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end