%------------------------------------------
% calculate power spectra of different terms in moist different total engergy 
%------------------------------------------
% close all
clear;  ccc=':';
%---
% expri1={'TWIN201Pr001qv062221'; 'TWIN021Pr001qv062221'; 'TWIN020Pr001qv062221'};
% expri2={'TWIN201B';'TWIN021B';'TWIN020B'};    
% expnam={'FLAT';'V05';'V20'};
% cexp=[87 198 229; 230 84 80; 239 144 185]/255; 
% exptext='FLATV05V20';

% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221'; 'TWIN020Pr001qv062221'};
% expri2={'TWIN201B';'TWIN003B';'TWIN013B';'TWIN021B';'TWIN020B'};    
% expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
% cexp=[87 198 229; 242 135 0; 146 200 101; 230 84 80; 239 144 185]/255; 
% exptext='diffTOPO';

expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN030Pr001qv062221'; 'TWIN031Pr001qv062221';'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN030B'; 'TWIN031B'; 'TWIN042B'; 'TWIN043B'}; 
exptext='U00NS5';
expnam={'FLAT';'TOPO';'NS5_FLAT';'NS5_TOPO';'U00_FLAT';'U00_TOPO'};
% cexp=[0  50  90; 220 77 11; 0 163 209; 236 121 33; 147 195 233; 239 157 112]/255; 
cexp=[87 198 229; 242 155 0;       44 125 190;  232 66 44;  95 85 147; 168 63 63]/255; 


% expri1={'TWIN042Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN042B'; 'TWIN043B'}; 
% exptext='U00';
% expnam={'U00_FLAT';'U00_TOPO'};
% cexp=[147 195 233; 239 157 112]/255; 

plotid='CMDTE'; %KE, SH, LH

day=22;  hrs=22:30;  minu=00:10:50;

cldtpw=0.7;
cgrthresh=[0.05 1 11];
lev=1:17;  

%--
year='2018';  mon='06';
infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';

if strcmp(plotid,'CMDTE')==1
   titnam=[plotid,' spectra'];   fignam=[plotid,'spectr_',exptext,'_'];
else
   titnam=['Di',plotid,' spectra'];   fignam=['Di',plotid,'spectr_',exptext,'_'];
end

%---
nexp=size(expri1,1);  nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%---
%%
%---
% lgnd=cell(lenhr*length(minu),1);  
for ei=1:nexp
  nti=0; ntii=1;
  
  for ti=hrs
    hr=ti; s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    for mi=minu 
      s_min=num2str(mi,'%2.2d'); 
      nti=nti+1;    
      
      %---infile 1, perturbed state---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2, based state---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];     
      
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE'));      
      P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
      hyd  = qr+qc+qg+qs+qi;   
      dP=P(:,:,1:end-1)-P(:,:,2:end);
      tpw= dP.*( (hyd(:,:,2:end)+hyd(:,:,1:end-1)).*0.5 ) ;
      TPW=squeeze(sum(tpw,3)./9.81);   
      cgr = length(TPW(TPW>cldtpw)) / (size(TPW,1)*size(TPW,2))*100 ;   
        
      thresh=cgrthresh(ntii);
      
      if cgr>thresh
                    
      PowSpe=cal_spectr(infile1,infile2,lev);     
      
      if strcmp(plotid,'CMDTE')==1
        eval(['DiffE(ntii,:,ei)=PowSpe.',plotid,';'])
      else
        eval(['DiffE(ntii,:,ei)=PowSpe.diff',plotid,';'])
      end
      
      ntii=ntii+1;
      disp([s_hr,s_min,' done']); 
      
      end
    
      vinfo = ncinfo(infile1,'U10');   nx = vinfo.Size(1); ny = vinfo.Size(2); 
    
      if ntii==length(cgrthresh)+1; break; end
    end %mi    
    if ntii==length(cgrthresh)+1; break; end
  end %ti
  disp([expri1{ei},' done'])  
end %ei

%%
%
%---plot
hf=figure('position',[100 45 880 660]) ;
% hf=figure('position',[100 500 880 580]) ;

%----------------
linest={':';'--';'-'};
% for ei=1:nexp
for ei=[1 3 5 2 4 6]
 for i=1:length(cgrthresh)
   h(ei)=plot(DiffE(i,:,ei)','LineWidth',3.5,'color',cexp(ei,:),'linestyle',linest{i}); hold on
 end
end

legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'Location','sw','FontName','Consolas')
%---
xlim=[1 min(nx,ny)]; ylim=[1e-3 3e4];
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

text(3,3e5,['cgr= ',num2str(cgrthresh)])
%---
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d'); 
outfile=[outdir,'/',fignam,num2str(length(cgrthresh)),'cgr','_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];

print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
