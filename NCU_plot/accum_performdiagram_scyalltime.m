clear

 % !!! notice: remember to modify the date in function <aaccum_score3_sing>

outdir='/SAS011/pwin/201work/plot_cal/what/';   araid=0;
%---
exp={'CTR';'RDA';'ZDA';'BOTH'}; lexp={'o';'^';'s';'p'};  exptext='_ZTDalltime'; 
expnam={'CTR';'RDA';'ZDA';'BOTH'};
sth=[10 11 12];  acch=6;  s_sth=num2str(sth,'%2.2d'); s_edh=num2str(sth+acch,'%2.2d'); 
%---------------
%load('/work/pwin/data/colormap_tresh.mat');  cmap=colormap_tresh;

tresh=[5 15 30 45 60 75];  %what's more
cmap=[  0.2  0.8  0.9  
    0.4000    0.9000    0.4000;
    0.9800    0.9100    0.1400;
    1.0000    0.4900    0.0500;
    0.9300    0.1000    0.0500;
    0.6000    0.2500    0.8500 ];

edgec=cmap-0.5;  edgec(edgec<0)=0;  
%------------------------
nexp=size(exp,1);
nt  =length(tresh);   %

%--calculate--
pod=zeros(nexp,nt); sr=zeros(nexp,nt); 
for i=1:nexp
[pod(i,:) sr(i,:)]=accum_score3_sing_scyalltime(sth,acch,exp{i},tresh); 
end

%-----------------------plot----------------------------------------------------
figure('position',[100 200 600 500])  
%---plot bias lines
x=0:0.1:1;  color=[0.55 0.4 0.3];
for bi=[0.1  0.3  0.5  0.75  1.0  1.3  2.0  3.5  10]
  y=x.*bi;
  plot(x,y,'--','color',color);  hold on
  if bi>=1;  text(1/bi,1.016,num2str(bi),'color',color)
  else       text(1.005,bi+0.01,num2str(bi),'color',color)
  end
end 
%---plot y(POD) line
 %for i=0.1:0.1:0.9  
 %  line([0 1],[i i],'linestyle','-.','color',[0.7 0.7 0.7])
 %end 
%---plot TS lines
color=[0.4 0.6 0.3];
for ts=0.1:0.1:0.9        
    f=@(sr) 1./(1/ts - 1./sr + 1);  
    x=ts:0.01:1;  y=f(x);
    plot(x,y,'color',color); 
    text(0.95,f(0.95)+0.01 ,num2str(ts),'color',color)
end
%
%---plot score points---
marksize=9;
for i=1:nexp
 for j=1:nt
   %if pod(i,j)~=0 || sr(i,j)~=0      
   plot(sr(i,j),pod(i,j),lexp{i},'MarkerEdgeColor',edgec(j,:),'MarkerFaceColor',cmap(j,:),'MarkerSize',marksize);
   %end
 end
 %legend
 plot(0.05,1-i*0.05,lexp{i},'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0],'MarkerSize',marksize)
 text(0.08,1-i*0.05,expnam{i},'fontsize',12)
end
%
%----figure settiog----------------------
xlabel('Success ratio (H/F)','fontsize',14);   ylabel('Probability of detection (H/O)','fontsize',14); 
%---colorbar
hc=colorbar;   colormap(cmap);
set(hc,'position',[0.87 0.12 0.025 0.78],'YTick',1:6,'YTickLabel',tresh,'TickLength',[0 0],...
    'LineWidth',0.5,'fontsize',13)
ylabel(hc,'threshold (mm)','fontsize',12);
%---gca
set(gca,'position',[0.1 0.1 0.72 0.82],'XLim',[0 1],'YLim',[0 1],'XTick',0:0.1:1,'YTick',0.1:0.1:1,...
    'LineWidth',1,'fontsize',13) 
%---
%legend(hp,exp,'Location','NorthWest'); 
tit=['Accumulated rainfall scores'];  title(tit,'fontsize',15)
outfile=[outdir,'PerforDiag',exptext,'_area',num2str(araid)];
set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
system(['rm ',[outfile,'.pdf']]);

