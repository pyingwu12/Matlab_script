%------------------------------------------
% calculate power spectra of different terms in moist different total engergy 
%------------------------------------------
% close all
clear;  ccc=':';
%---
expri='TWIN001';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
day=22;  hrs=[22 26];% minu=00;
minu=[00];
lev=1:33;  
%--
year='2018';  mon='06';
infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='error spectra';   fignam=[expri1(8:end),'_MDTE_',];
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
  hr=hrs(ti);   s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  
  for mi=minu 
    nti=nti+1;
    s_min=num2str(mi,'%2.2d'); 
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
    %---infile 1, perturbed state---
      infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    
    PowSpe=cal_spectr(infile1,infile2,lev);
    
    diffSH(nti,:)=PowSpe.diffSH;
    diffKE(nti,:)=PowSpe.diffKE;
    diffLH(nti,:)=PowSpe.diffLH;
    
    vinfo = ncinfo(infile1,'U10');
    nx = vinfo.Size(1); ny = vinfo.Size(2); 
    
  end %mi
  disp([s_hr,' done'])  
end %ti
lgnd{nti+1}='-5/3 line';
%%
%
%---plot
% hf=figure('position',[100 45 950 660]) ;
hf=figure('position',[100 500 880 580]) ;

%----------------
for ti=1:2
  plot(diffSH(ti,:),'LineWidth',2,'color',[0.929,0.694,0.125]); hold on
  plot(diffKE(ti,:),'LineWidth',2,'color',[ 0.3,0.745,0.933]); 
  plot(diffLH(ti,:),'LineWidth',2,'color',[0.494,0.184,0.556]); hold on
end
%---
xlim=[1 min(nx,ny)]; ylim=[3e-3 1e4];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber')
ylabel('J kg^-^1')
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
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(day),'_',s_sth,s_edh,'_',num2str(lenhr),'hrs',num2str(length(minu)),'min_lev'...
    ,num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d'),'_2'];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
%%
%{
col=col0;
%---plot
hf=figure('position',[100 45 930 660]) ;
%---
for ti=1:lenhr*length(minu)
plot(KE.kh(:,ti),'LineWidth',2.5,'LineStyle','-','color',col(ti,:)); hold on
end
%--- -5/3 line---
x53=-5:0.1:4;  y53=7.35+(-5/3*x53);
plot(10.^x53,10.^y53,'k','linewidth',2.2,'linestyle','--');
%----------------
for ti=1:lenhr*length(minu)
plot(KEp.kh(:,ti),'LineWidth',2,'LineStyle','--','color',col(ti,:)); hold on
end
legend(lgnd,'Box','off','Interpreter','none','fontsize',13,'Location','BestOutside')
%-------------
xlim=[1 min(nx,ny)]; ylim=[3e-2 1e6];
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
outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(lenhr),'hrs',num2str(length(minu)),'min_lev'...
    ,num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
