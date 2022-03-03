% close all
clear;   ccc=':';
%---setting
expri='TWIN003B';  
stday=22;   hrs=[23 24];  minu=0:10:50;  
rangx=1:150; rangy=26:175;

% stday=23;   hrs=[1 2];  minu=0:10:50;  
% rangx=151:300; rangy=76:225;

% rangx=1:300; rangy=1:300;  
subdomid=['x',num2str(rangx(1)),num2str(rangx(end)),'y',num2str(rangy(1)),num2str(rangy(end))];
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='W mean';   fignam=[expri,'_Wmean-prof_'];
%
g=9.81;
ntime=length(hrs)*length(minu);
%
zgi=10:50:9500;   ytick=1000:1000:zgi(end);
%
load('colormap/colormap_ncl.mat'); col=colormap_ncl(25:floor(254/ntime)-1:end,:);

%---
nti=0;
for ti=hrs
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');     s_hr=num2str(hr,'%2.2d'); 
  for mi=minu    
    nti=nti+1;  
    s_min=num2str(mi,'%2.2d');
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
    %---
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    hgt = ncread(infile,'HGT');   
    w = double(ncread(infile,'W'));   
    %---    
    PH=phb+ph;   zg=double(PH)/g;      
    for i=rangx
      for j=rangy      
        w_iso(i,j,:)=interp1(squeeze(zg(i,j,:)),squeeze(w(i,j,:)),zgi,'linear');
      end
    end         
    %---
    for k=1:length(zgi)
      ww=w_iso(:,:,k);        
      w_p(k,nti) = mean(ww(ww>0));
      w_n(k,nti) = mean(ww(ww<0));        
    end
   %
  end %mi
  disp([s_hr,s_min,' done'])
end %ti

%%
%---plot---
hf=figure('position',[45 350 800 650]);
    
for ti=1:ntime
  plot(w_p(:,ti),zgi,'color',col(ti,:),'linewidth',3);     hold on  
end
for ti=1:ntime
  plot(w_n(:,ti),zgi,'color',col(ti,:),'linewidth',3)
end

legend(lgnd,'box','off','fontsize',18,'location','eastoutside')

set(gca,'fontsize',18,'LineWidth',1.2)    
set(gca,'Ytick',ytick,'Yticklabel',ytick./1000) 
% set(gca,'Xlim',[-0.15 0.15])   
% set(gca,'Xlim',[-0.45 0.45])  
xlabel('W (m/s)');    ylabel('Height (km)')
    
tit={[expri,'  ',titnam,];['(x:',num2str(rangx(1)),'-',num2str(rangx(end)),', y:',num2str(rangy(1)),'-',num2str(rangy(end)),')']}; 
title(tit,'fontsize',18)
%
s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(length(hrs)),...
    'h',num2str(length(minu)),'m',num2str(minu(end)),'_',subdomid];
%  print(hf,'-dpng',[outfile,'.png']) 
%  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
 
