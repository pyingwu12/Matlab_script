
clear
% close all

saveid=1;

% pltensize=1000;    
% randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members
%
pltrng=[1 55];  pltint=1; 
% pltrng=[1 28];  pltint=1; 


% tor=0.35;
% intv=[1 3 5 10]; % <-interval of grid point 
% navg=[1 5 10];
% lev=1000;
% expri='Hagibis05kme02'; 

% infilename='201910101800';  %idifx=53;  %hagibis

pltime=pltrng(1):pltint:pltrng(end);
ntime=length(pltime);

load('colormap/colormap_ncl.mat'); cmap=colormap_ncl(22:4:end,:);

%
% indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir='/home/wu_py/labwind/Result_fig/';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
% titnam=[expri,'  Similarity between members'];   fignam=[expri,'_SimiTs_'];
%
%%
iint=1; iavg=10; expri='Hagibis05kme02'; lev=850;
% iint=1; iavg=10; expri='Nagasaki05km'; lev=1000; 
load([expri,'_edge',num2str(iavg),'int',num2str(iint),'lev',num2str(lev),'_t1_',num2str(ntime),'_1_SV'])

% load([expri,'_edge',num2str(iavg),'int',num2str(iint),'lev',num2str(lev),'_t1_55_1_SV'])
eval(['sval=s_value_i',num2str(iint),'a',num2str(iavg),';'])

%
hf=figure('Position',[2000 100 1200 630]);

line([50 50],[0.0001 10000],'linestyle','--','color',[0.7 0.7 0.7],'linewidth',2);hold on
line([25 25],[0.0001 10000],'linestyle','--','color',[0.7 0.7 0.7],'linewidth',2)

tint=1;
for ti=1:tint:ntime
    
plot(sval(:,ti),'color',cmap(ti,:),'linewidth',2)
hold on

% fin=find(sval(:,ti)<=0.1,1);
% line([fin fin],[0.0001 10000],'color',cmap(ti,:),'linewidth',1.5)
end

tickint=6; npltime=length(1:tint:ntime);
L1=( (1:tickint:npltime)*diff(caxis)/npltime )  +  min(caxis()) -  diff(caxis)/npltime/2;
hco=colorbar('YTick',L1,'YTickLabel',0:tint*tickint:ntime-1,'fontsize',13,'LineWidth',1.2);
title(hco,'FT')
colormap(cmap(1:tint:ntime,:))  


set(gca,'xlim',[1 1000],'fontsize',18,'linewidth',1.4,'box','on')
 set(gca,'yscale','log','xscale','log','ylim',[0.05 8000])
xlabel('Rank'); ylabel('Singlar value')

tit={['edge avg',num2str(iavg),'  grid intv',num2str(iint),'  lev',num2str(lev)];[expri,'  Singlur value']};
title(tit,'fontsize',18)

  outfile=[outdir,expri,'_SValue_eg',num2str(iavg),'int',num2str(iint),'lev',num2str(lev)];
  if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

%%
%{
close all

nint=[1 3 5 10]; % <-interval of grid point 
navg=[1 5 10];
lev=1000;

for iavg=navg
 close all

for iint=nint


load(['Hagibis05kme01_edge',num2str(iavg),'int',num2str(iint),'lev',num2str(lev),'_t1_55_1_SV'])
eval(['sval01=s_value_i',num2str(iint),'a',num2str(iavg),';'])

load(['Hagibis05kme02_edge',num2str(iavg),'int',num2str(iint),'lev',num2str(lev),'_t1_55_1_SV'])
eval(['sval02=s_value_i',num2str(iint),'a',num2str(iavg),';'])

L=10.^[-2 -1 0 1 2 3];

hf=figure('Position',[2000 100 1200 630]);

line([50 50],[1 55],'linestyle','-.','color',[0.5 0.7 0.4],'linewidth',3);hold on
line([25 25],[1 55],'linestyle','-.','color',[0.5 0.7 0.4],'linewidth',3)
%
[c,hdis]=contour(sval02',L,'linewidth',4); hold on
  clabel(c,hdis,'fontsize',13,'LabelSpacing',500)   
[c,hdis]=contour(sval01',L,'linewidth',3.5,'linestyle','--'); 
  clabel(c,hdis,'fontsize',13,'LabelSpacing',200)   
%
colorbar; set(gca,'ColorScale','log'); colormap(spring)
%
xlabel('Rank'); ylabel('FT')
set(gca,'fontsize',18,'linewidth',1.4,'ytick',1:6:55,'yticklabel',0:6:54,'box','on')
set(gca,'xscale','log')
%
tit={['edge avg',num2str(iavg),'  grid intv',num2str(iint),'  lev',num2str(lev)];'Singlur value'};
title(tit,'fontsize',18)

  outfile=[outdir,'SValue_e012_eg',num2str(iavg),'int',num2str(iint),'lev',num2str(lev)];
  if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
  
end
end
  %}