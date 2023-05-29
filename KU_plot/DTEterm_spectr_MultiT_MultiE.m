%------------------------------------------
% calculate power spectra of different terms in moist different total engergy 
%------------------------------------------
% close all
clear;  ccc=':';
%---
% expri1={'TWIN001Pr001qv062221'; 'TWIN013Pr001qv062221';'TWIN003Pr001qv062221'};
% expri2={'TWIN001B';'TWIN013B';'TWIN003B'};    
% % expnam={ 'FLAT';'H500';'H750';'H1000'};
% cexp =[     0.0784    0.0784    0.0784;    
%     0.9216    0.6863    0.1255;
%     0.8627    0.3333    0.0980;
%     0.6275    0.0784    0.1765];
% exptext='e0313';


expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
exptext='U00NS5';
% expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
cexp=[0  50  90; 220 77 11; 0 163 209; 236 121 33; 147 195 233; 239 157 112]/255; 


day=22;  hrs=[21]; minu=10:10:50;
lev=1:10;  
plotid='LH'; %KE, SH, LH
%--
year='2018';  mon='06';
infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin/';
titnam=['Di',plotid,' spectra'];   fignam=['Di',plotid,'-spectr_',exptext,'_'];
%---
nexp=size(expri1,1);  nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%---
%%
%---
% lgnd=cell(lenhr*length(minu),1);  
for ei=1:nexp
  nti=0;
  for ti=hrs
  hr=ti; s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    for mi=minu 
      s_min=num2str(mi,'%2.2d'); 
      nti=nti+1;    
      lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
      %---infile 1, perturbed state---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2, based state---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    
      PowSpe=cal_spectr(infile1,infile2,lev);
    
      eval(['DiffE(nti,:,ei)=PowSpe.diff',plotid,';'])
    
      vinfo = ncinfo(infile1,'U10');   nx = vinfo.Size(1); ny = vinfo.Size(2); 
    
    end %mi
    disp([s_hr,' done'])  
  end %ti
  disp([expri1{ei},' done'])  
end %ei

%%
%---plot
hf=figure('position',[100 45 950 660]) ;
% hf=figure('position',[100 500 880 580]) ;

%----------------
for ei=1:nexp
  plot(DiffE(:,:,ei)','LineWidth',2,'color',cexp(ei,:)); hold on
end
%---
xlim=[1 min(nx,ny)]; ylim=[3e-4 1e4];
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
tit=[titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',18)
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),...
    '_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];

% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%
