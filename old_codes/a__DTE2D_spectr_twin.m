%----------------------
% plot spectra of difference total QV between two experiments
%----------------------
clear;  ccc=':';
close all
%---setting
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
stday=23;   %hrs=[0 1 2];  minu=[00 20 40];
hrs=[0:10];  minu=[00];
%--
year='2018';  mon='06'; 
infilenam='wrfout';   dom='01';   grids=1;
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin/';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%
titnam='MDTE spectra';   fignam=[expri1(8:end),'_2DTE-sp_'];
%
load('colormap/colormap_ncl.mat')
col0=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
col=col0(1:2:end,:);
%---
lenhr=length(hrs);
%---
lgnd=cell(lenhr*length(minu),1);   nti=0;
for ti=1:lenhr
  hr=hrs(ti);
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  
  for mi=minu 
    nti=nti+1;
    s_min=num2str(mi,'%2.2d'); 
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' JST'];     
    %---infile1 (perturbed state)---
    infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
    %---infile 2 (based state)---
    infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   

    MDTE=cal_DTE_2D(infile1,infile2);    
  
    %---
    if nti==1
      [nx, ny]=size(MDTE);
      cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
      nk=zeros(nx,ny);
      for xi=1:nx
        for yi=1:ny
         nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
        end    
      end   
      nk2=round(nk); 
      KEp.kh=zeros(max(max(nk2)),length(hrs));
    end
  
    %---2D fft
    dte.fft=fft2(MDTE);    
    %---calculate KE (power of the FFT)---
    KEp.twoD = (abs(dte.fft).^2)/nx/ny ;  %2-D    
    %--shift
    KEp.shi=fftshift(KEp.twoD);
    %---adjust 2D spectra to 1D (wave number kh)---
    for ki=1:max(max(nk2))   
      KEp.kh(ki,nti)=sum(KEp.shi(nk2==ki));   % sum of different kx, ky to kh bin
    end   
    
  end %minu
  disp([s_hr,' done'])
end  %ti
lgnd{nti+1}='-5/3 line';
%%
%---plot
hf=figure('position',[100 45 950 660]);
%----------------
for ti=1:lenhr*length(minu)
plot(KEp.kh(:,ti),'LineWidth',2.5,'LineStyle','-','color',col(ti,:)); hold on
end
%--- -5/3 line---
x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
%
legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','BestOutside')
%---
xlim=[1 min(nx,ny)]; ylim=[1e-8 1e6];
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
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(lenhr),'hrs',num2str(length(minu)),'min'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
