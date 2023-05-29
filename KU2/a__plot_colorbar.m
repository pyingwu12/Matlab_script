% plot horizontal clolorbar


%-------------
% fignam='zh_colorbar_h'; unit='dBZ';
% load('colormap/colormap_zh.mat')
% cmap=colormap_zh; cmap(1,:)=[1 1 1];
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[1 3 6 10 15 20 25 30 35 40 45 50 55 60 65 70];

%-------------
fignam='rain_colorbar_h'; unit='mm';
load('colormap/colormap_rain.mat')
cmap=colormap_rain; 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[  0.1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];

%--------------
% fignam='DTE_colorbar_h'; unit='J kg^-^1';
% load('colormap/colormap_dte.mat')
% cmap=colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[0.5 2 4 6 8 10 15 20 25 35];

%-------------
% fignam='Time_colorbar_h'; unit='Local time';
% load('colormap/colormap_ncl.mat');  cmap=colormap_ncl(15:8:end,:);
%
% hrs=[23 24 25 26 27];  minu=0:10:50;
% nti=0;
%   for ti=hrs 
%     hr=ti; 
%     for tmi=minu
%       nti=nti+1;
%       s_min=num2str(tmi,'%.2d');
%       lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min]; 
%     end
%   end
% nti=length(hrs)*length(minu); tickint=2;
  
%---
% fignam='Zh_new_colorbar_h'; unit='dBZ';
%  cmap=[  1.0000    1.0000    1.0000;
%          0.7000    0.9500    1.0000;
%          0.4800    0.8000    0.9500;
%          0.9800    0.9500    0.3000;
%          1.0000    0.6500    0.0500;
%          1.0000    0.2000    0.1000;
%          0.8500    0.1372         0;
%          0.9000    0.6000    0.9000];
% L=[1 10 20 30 40 50 60];

%
outdir='/mnt/e/figures'; 
%---   
hf=figure('position',[100 200 1300 700]);
set(gca,'position',[0.13 0.3 0.775 0.8])
%


% L1=( (1:tickint:nti)*diff(caxis)/nti )  +  min(caxis()) -  diff(caxis)/nti/2;
% n=0; for i=1:tickint:nti; n=n+1; llll{n}=lgnd{i}; end
% hc=colorbar('SouthOutside');
% set(hc,'position',[0.13 0.1296 0.775 0.025],'YTick',L1,'YTickLabel',llll,'fontsize',15,'LineWidth',1.2);
% colormap(cmap)
% ylabel(hc,unit,'fontsize',15); 
%}
%
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
hc=colorbar('SouthOutside');
set(hc,'position',[0.13 0.1296 0.775 0.025],'YTick',L1,'YTickLabel',L,'fontsize',20,'LineWidth',2);
colormap(cmap); 
%---
ylabel(hc,unit,'fontsize',25); 
%title(hc,unit,'fontsize',20);  
%---  
outfile=[outdir,'/',fignam];
print(hf,'-dpng',[outfile,'.png'])    
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
