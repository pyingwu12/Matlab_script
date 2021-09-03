%------------------------------------------
% calculate power spectra (cntl&diff) of model variables and the spectra of diff/cntl
% PY @2021/06/27 
%------------------------------------------
% close all
clear;  ccc=':';
%---
plotid='UV';  % present option: 'W', 'UV'
%
expri='TWIN024';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
day=22;  hrs=[21 22 23 24 25 26 27]; minu=0:10:50;
% lev=1:33;  
lev=16:33;  
%--
year='2018';  mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%---
nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%
load('colormap/colormap_ncl.mat')
%
cp=1004.9;
R=287.04;
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
Pr=1000;

%---
lgnd=cell(ntime,1);   nti=0;
for ti=hrs
  hr=ti;   s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  for mi=minu 
    nti=nti+1;    s_min=num2str(mi,'%2.2d'); 
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    
    switch(plotid)
      case('W')
        w.stag1 = ncread(infile1,'W'); w.f1=(w.stag1(:,:,lev)+w.stag1(:,:,lev+1)).*0.5; 
        w.stag2 = ncread(infile2,'W'); w.f2=(w.stag2(:,:,lev)+w.stag2(:,:,lev+1)).*0.5; 
        w.diff=w.f1-w.f2;
        if nti==1
            [nx, ny, nzi]=size(w.diff); 
            cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
            nk=zeros(nx,ny);
            for xi=1:nx
                for yi=1:ny
                    nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
                end
            end
            nk2=round(nk);
        end
        for li=1:nzi
          w.fft=fft2(w.f2(:,:,li));   w.perfft=fft2(w.diff(:,:,li));  
          spetr.cntl_2D(:,:,li) = (abs(w.fft).^2 )/nx/ny ;  %2-D low level mean      
          spetr.diff_2D(:,:,li) = (abs(w.perfft).^2)/nx/ny ;  
        end
      case('UV')
         u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V'); 
        u.f1=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
        v.f1=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5;
         u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V'); 
        u.f2=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
        v.f2=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
        u.diff=u.f1-u.f2;     v.diff=v.f1-v.f2;
        if nti==1
            [nx, ny, nzi]=size(u.diff); 
            cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
            nk=zeros(nx,ny);
            for xi=1:nx
                for yi=1:ny
                    nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
                end
            end
            nk2=round(nk);
        end
        for li=1:nzi
          u.fft=fft2(u.f2(:,:,li));       v.fft=fft2(v.f2(:,:,li));
          u.perfft=fft2(u.diff(:,:,li));  v.perfft=fft2(v.diff(:,:,li));  
          spetr.cntl_2D(:,:,li) = (abs(u.fft).^2 + abs(v.fft).^2 )/nx/ny ;  %2-D low level mean      
          spetr.diff_2D(:,:,li) = (abs(u.perfft).^2 + abs(v.perfft).^2)/nx/ny ;                
        end
    end
    
%      th.f=ncread(infile1,'T')+300;  th.f1=th.f(:,:,lev);
%      t.f1=th.f1.*(1e3./p.f1).^(-R/cp);     
%      qv.f=ncread(infile1,'QVAPOR');  qv.f1=double(qv.f(:,:,lev)); 

%      th.f=ncread(infile2,'T')+300;  th.f2=th.f(:,:,lev);
%      t.f2=th.f2.*(1e3./p.f2).^(-R/cp);     
%      qv.f=ncread(infile2,'QVAPOR');  qv.f2=double(qv.f(:,:,lev)); 
    %---calculate different
%     t.diff=t.f1-t.f2;    
%     qv.diff=qv.f1-qv.f2;
%   %---calculate---
%     for li=1:nzi
%       %---2D fft     
% %       t.fft=fft2(t.f2(:,:,li));
% %       qv.fft=fft2(qv.f2(:,:,li));    
% %       t.perfft=fft2(t.diff(:,:,li));
% %       qv.perfft=fft2(qv.diff(:,:,li));      
%     %---calculate KE (power of the FFT)---
% %        KE.twoD(:,:,li) = (abs(u.fft).^2 + abs(v.fft).^2 + cp/Tr*abs(t.fft).^2 +...
% %            Lv^2/cp/Tr*abs(qv.fft).^2 + R*Tr*abs(psfc.fft/Pr).^2)/nx/ny ;  %2-D low level mean      
% %        KEp.twoD(:,:,li) = (abs(u.perfft).^2 + abs(v.perfft).^2 + cp/Tr*abs(t.perfft).^2 +...
% %            Lv^2/cp/Tr*abs(qv.perfft).^2 + R*Tr*abs(psfc.perfft/Pr).^2)/nx/ny ;  
%     end %li=lev    
    %--shift
    spetr.cntl_shi=fftshift(mean(spetr.cntl_2D,3));
    spetr.diff_shi=fftshift(mean(spetr.diff_2D,3));   
    %---adjust 2D KE to 1D (wave number kh)---
    for ki=1:max(max(nk2))   
      spetr.cntl_kh(ki,nti)=sum(spetr.cntl_shi(nk2==ki));   % sum of different kx, ky to kh bin
      spetr.diff_kh(ki,nti)=sum(spetr.diff_shi(nk2==ki));
    end
  end %mi
  disp([s_hr,' done'])  
end %ti
% lgnd{nti+1}='-5/3 line';
plotime=[2 7 13 16 17 18 19 20 21 22 23 25 31 37 42];
col2=colormap_ncl(25:floor(length(colormap_ncl)/length(plotime))-1:end,:);
%%
%---Spectra of cntl and error at specfic times decided by <plotime>---
%
titnam=[plotid,' spectra'];   fignam=[expri1(8:end),'_',plotid,'-spectr_',];
hf=figure('position',[100 55 940 660]) ;
n=0;
for ti=plotime
  n=n+1;
plot(spetr.cntl_kh(:,ti),'LineWidth',3,'LineStyle','-','color',col2(n,:)); hold on
end
n=0;
for ti=plotime
  n=n+1;
  plot(spetr.diff_kh(:,ti),'LineWidth',2.5,'LineStyle','--','color',col2(n,:)); hold on
  lgnd2{n}=lgnd{ti};
end
legend(lgnd2,'Box','off','Interpreter','none','fontsize',15,'Location','BestOutside')
%-------------
xlim=[1 min(nx,ny)]; 
switch(plotid)
  case('W')
    ylim=[1e-5 2e3];
  case('UV')
    ylim=[1e-5 2e5];
end
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber'); ylabel('J kg^-^1')
%---second axis---
ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  %ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
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
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
%%
%---ratio of difference to cntl run at specfic times decided by <plotime>---
%
titnam=[plotid,' error %'];   fignam=[expri1(8:end),'_',plotid,'-r_',];
hf=figure('position',[100 55 940 660]) ;
n=0;
for ti=plotime
  n=n+1;
  plot(spetr.diff_kh(:,ti)./spetr.cntl_kh(:,ti),'LineWidth',3,'LineStyle','-','color',col2(n,:)); hold on
  lgnd2{n}=lgnd{ti};
end
legend(lgnd2,'Box','off','Interpreter','none','fontsize',15,'Location','BestOutside')
%-------------
xlim=[1 min(nx,ny)]; ylim=[7e-6 2];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber'); ylabel('%')
%---second axis---
ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  %ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
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
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
%%
%---Spectra of cntl and error at all times---
%{
col=colormap_ncl(25:floor(length(colormap_ncl)/ntime)-1:end,:);
%---
hf=figure('position',[100 45 930 660]) ;
%---
for ti=1:ntime
plot(spetr.cntl_kh(:,ti),'LineWidth',2.5,'LineStyle','-','color',col(ti,:)); hold on
end
%--- -5/3 line---
% x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
% plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
%----------------
for ti=1:ntime
    plot(spetr.diff_kh(:,ti),'LineWidth',2,'LineStyle','--','color',col(ti,:)); hold on
end

legend(lgnd,'Box','off','Interpreter','none','fontsize',13,'Location','BestOutside')
%-------------
xlim=[1 min(nx,ny)]; ylim=[1e-5 1e4];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber')
%---second axis---
ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  %ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---
tit=[expri1,'  ',titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),...
    '_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
