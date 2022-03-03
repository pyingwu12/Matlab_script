clear;  ccc=':';
close all
%---setting
expri='ens08';  stday=21;  sths=[15 18 21 24 27 30 34 37]; acch=1;  ensize=10; 
%--
year='2018';  mon='06'; s_min='30';  
dirmem='pert'; infilenam='wrfout';   dom='01';   grids=1;
%
indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri]; outdir=['/mnt/e/figures/ens200323/',expri];
% indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%
load('colormap/colormap_ncl.mat')
col=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
%
titnam='Mean rainfall spectra';   fignam=[expri,'_accum-sp_'];
%---
lenhr=length(sths);
%---
lgnd=cell(lenhr,1);  
for ti=1:lenhr     
  sth=sths(ti);    
  lgnd{ti}=[num2str(mod(sth+9,24),'%.2d'),s_min,' JST + ',num2str(acch),'h'];    
  for mi=1:ensize
  nen=num2str(mi,'%.2d');        
    for j=1:2
      hr=(j-1)*acch+sth;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':','00'];    
      rc{j} = ncread(infile,'RAINC');
      rsh{j} = ncread(infile,'RAINSH');
      rnc{j} = ncread(infile,'RAINNC');
    end %j=1:2
    rain.ori=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
    rain.ori(rain.ori+1==1)=0;        
    %---
    if ti==1 && mi==1
      [nx, ny]=size(rain.ori);
      cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
      nk=zeros(nx,ny);
      for xi=1:nx
        for yi=1:ny
          nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
        end    
      end   
      nk2=round(nk); 
      KE.kh=zeros(max(max(nk2)),length(ensize)); 
      KE.khm=zeros(max(max(nk2)),lenhr); 
    end
    %
    %---2D fft 
    rain.fft=fft2(rain.ori);    
    %---calculate KE (power of the FFT)---
    KE.twoD = (abs(rain.fft).^2)/nx/ny ;  %2-D low level mean      
    %--shift
    KE.shi=fftshift(KE.twoD);
    %---adjust 2D KE to 1D (wave number kh)---
    for ki=1:max(max(nk2))   
      KE.kh(ki,mi)=sum(KE.shi(nk2==ki));   % sum of different kx, ky to kh bin
    end         
  end %member 
  KE.khm(:,ti)=mean(KE.kh,2);    
  disp([s_hr,' done'])
end %ti
lgnd{ti+1}='-5/3 line';
%
%---plot---
hf=figure('position',[100 45 1000 660]) ;
for ti=1:lenhr
plot(KE.khm(:,ti),'LineWidth',2.5,'Color',col(ti,:)); hold on
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
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',16)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---
tit=[expri,'  ',titnam,'  (',num2str(acch),'h)'];     
title(tit,'fontsize',18)
%---
s_sth=num2str(sths(1),'%2.2d'); s_edh=num2str(mod(sths(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_edh,'_',s_min,...
     '_',num2str(lenhr),'step_',num2str(acch),'h'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
