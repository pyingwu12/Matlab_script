%------------------------------------------
% calculate power spectra of moist different total engergy 
%------------------------------------------

% close all
clear;  ccc=':';


 expri1={'TWIN201Pr001qv062221';'TWIN003Pr001qv062221'}; 
 expri2={'TWIN201B';'TWIN003B'}; 
 exptext='FALTOPO';

%  expri1={'TWIN003Pr001qv062221';'TWIN003Pr0001qv062221'}; 
%  expri2={'TWIN003B';'TWIN003B'}; 
%  exptext='TOPO';

%  expri1={'TWIN201Pr001qv062221';'TWIN201Pr0001qv062221'}; 
%  expri2={'TWIN201B';'TWIN201B'}; 
% exptext='FLAT';

saveid=1;
%---
plotid='CMDTE'; % CMDTE, LH, KE3D, etc.

% expri='TWIN013';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
%day=22;  hrs=[21 22 23 24 25 26 27 28];% minu=00; % thesis
day=22;  hrs=[21 22 23 24 25 26 27 28 29];% minu=00;
% stday=23; hrs=[0 1 2];
minu=[00 30];
lev=1:33;  
%--
year='2018';  mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam=[plotid,' ratio'];   fignam=[plotid,'-spectr-ratio_',exptext,'_'];
%
load('colormap/colormap_ncl.mat')
col0=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
col=col0(1:2:end,:);
%---
nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%
nexp=size(expri1,1); 

%%
%---
lgnd=cell(ntime,1);  
for ei=1:nexp
    nti=0;
  for ti=hrs
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;  s_date=num2str(day+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');   
    for mi=minu 
      nti=nti+1;    s_min=num2str(mi,'%2.2d'); 
      if ei==1;  lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];  end
   
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    
      PowSpe=cal_spectr(infile1,infile2,lev);
     
      if strcmp(plotid,'CMDTE')==1
       eval(['spetr.diff_kh(:,nti,ei)=PowSpe.',plotid,';'])
       eval('spetr.cntl_kh(:,nti,ei)=PowSpe.CMTE;')
      else
       eval(['spetr.diff_kh(:,nti,ei)=PowSpe.diff',plotid,';'])
       eval(['spetr.cntl_kh(:,nti,ei)=PowSpe.',plotid,';'])
      end    
      
    end %mi
    disp([s_hr,' done'])  
  end %ti
end
vinfo = ncinfo(infile1,'U10');   nx = vinfo.Size(1); ny = vinfo.Size(2); 

%% ratio to cntl
%
linexp={'-';'--'};
ratio=spetr.diff_kh./spetr.cntl_kh;
col=col0;
% col=col0([1:2:29,30],:);
%---plot
hf=figure('position',[100 45 930 660]) ;
%---
plotime=1:2:ntime;
for ei=1:nexp
for ti=plotime
plot(ratio(:,ti,ei),'LineWidth',2.5,'LineStyle',linexp{ei},'color',col(ti,:)); hold on
end
end
lgnd{end}='2 times';
line([1 min(nx,ny)],[2 2],'color','k','linewidth',2.2,'linestyle','--')
legend(lgnd{plotime},'Box','off','Interpreter','none','fontsize',13,'Location','BestOutside')
%-------------
xlim=[1 min(nx,ny)]; ylim=[1e-7 1e1];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber')
%---second axis---
ax1=gca; 
set(ax1,'Position',ax1.Position-[0 0 0 0.1])
ax1_pos = ax1.Position; 
box off
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---

tit={[expri1{1},' and ',expri1{2}];[titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean']};     
title(tit,'fontsize',16)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),...
    '_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}