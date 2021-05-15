%
% close all
clear
%----

expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp13';
expri2={'TWIN001B';'TWIN003B'};
expnam={'FLAT';'TOPO'};
Marker={'o','^'};

%---setting
stday=23;   hrs=[1 2 3];  s_min='40';
cloudhyd=0.005; %threshold of definition of cloud area (Kg/Kg)
areasize=10; %threshold of finding cloud area
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='moist DTE of each cloud area';   fignam=['cloudarea_',exptext,'_'];

nexp=size(expri1,1);
%-----
%
for ei=1:nexp  
  cloud{ei}=Diff_of_each_cloudarea(indir,expri1{ei},expri2{ei},stday,hrs,s_min,areasize,cloudhyd);
end
%--------------------
%{
%------
load('colormap/colormap_dte.mat')
cmap=colormap_dte([2 6 7 8 10 11],:);  Lmap=[1 3 5 10 30];  

figure('Position',[100 65 800 600])
Msize=9;

for ei=1:nexp
 plot_dot(cloud{ei}.size,cloud{ei}.maxzh,cloud{ei}.maxdte,cmap,Lmap,Marker{ei},Msize)
end
 
colormap(cmap); 
L1=((1:length(Lmap))*(1/(length(Lmap)+1)))+0;
colorbar('YTick',L1,'YTickLabel',Lmap,'fontsize',13,'LineWidth',1.2);   
   
set(gca,'fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','XLim',[9 6e3])
xlabel('Grid numbers (size)'); ylabel('Max Zh (intensity)');
%}
%------
%{
load('colormap/colormap_dte.mat')
cmap=colormap_dte([1 2 4 6 7 8 10 11],:);  Lmap=[40 45 50 55 60 65 70];  

figure('Position',[100 65 800 600])
Msize=9;

for ei=1:nexp
 plot_dot(cloud{ei}.size,cloud{ei}.scc,cloud{ei}.maxzh,cmap,Lmap,Marker{ei},Msize)
end
 
colormap(cmap); 
L1=((1:length(Lmap))*(1/(length(Lmap)+1)))+0;
hc=colorbar('YTick',L1,'YTickLabel',Lmap,'fontsize',13,'LineWidth',1.2);   
   
set(gca,'fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','XLim',[3 1e4])
xlabel('Grid numbers (size)'); ylabel('Max Zh (intensity)');
%}
%{
load('colormap/colormap_dte.mat')
cmap=colormap_dte([1 2 4 6 7 8 10 11],:);  Lmap=[35 40 45 50 55 60 65];  

figure('Position',[100 65 800 600])
Msize=9;

for ei=1:nexp
 plot_dot(cloud{ei}.size,cloud{ei}.maxdte,cloud{ei}.maxzh,cmap,Lmap,Marker{ei},Msize)
end
 
colormap(cmap); 
L1=((1:length(Lmap))*(1/(length(Lmap)+1)))+0;
hc=colorbar('YTick',L1,'YTickLabel',Lmap,'fontsize',13,'LineWidth',1.2);   
   
set(gca,'fontsize',16,'LineWidth',1.2) 
xlabel('Grid numbers (size)'); ylabel('Max Zh (intensity)');
set(gca,'Xscale','log','Yscale','log','XLim',[9 6e3])
%}
%%
hf=figure('Position',[100 65 800 650]);
plot(cloud{1}.size,cloud{1}.maxdte,'o','MarkerSize',8,'linewidth',2)
hold on 
plot(cloud{2}.size,cloud{2}.maxdte,'^','MarkerSize',8,'linewidth',2)
legend('FLAT','TOPO','Interpreter','none','fontsize',18,'Location','se','FontName','Monospaced');

set(gca,'fontsize',16,'LineWidth',1.2) 
set(gca,'Xscale','log','Yscale','log','XLim',[9 6e3])
xlabel('Size (grid numbers)'); ylabel('Maximum moist DTE');
title(titnam,'fontsize',18)

outfile=[outdir,'/',fignam,num2str(stday),num2str(hrs(1),'%.2d'),'_',num2str(length(hrs)),'hr_min',s_min];
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
