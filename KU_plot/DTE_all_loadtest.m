

% close all
clear

cloudhyd=0.003;
% 
hrs=[21 22 23 24 25 26 27];  minu=0:10:50; 
  nhr=length(hrs);  nminu=length(minu);
  s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');  
  outfile_tick=[num2str(cloudhyd),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
  
load(['matfile/DTE_quantify/cgr_',outfile_tick,'.mat'])
load(['matfile/DTE_quantify/maxcld_',outfile_tick,'.mat'])
load(['matfile/DTE_quantify/CMDTE_',outfile_tick,'.mat'])
load(['matfile/DTE_quantify/DiKE3D_',outfile_tick,'.mat'])
load(['matfile/DTE_quantify/DiSH_',outfile_tick,'.mat'])
load(['matfile/DTE_quantify/DiLH_',outfile_tick,'.mat'])
%
nexp=size(CMDTE_m,2);
ntime=size(CMDTE_m,1);

expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
expri2={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'};     
expnam={'FLAT';
        'V05H05';'V10H05';'V20H05';
        'V05H075';'V10H075';'V20H075';
        'V05H10';'V10H10';'V20H10';
        'V05H20';'V10H20';'V20H20'};    
cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7;
    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7;
    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7;
    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7];

expmark={'s';'o';'^';'p';
             'o';'^';'p';
             'o';'^';'p';
             'o';'^';'p'};     
ploterms={'CMDTE';'DiKE3D';'DiSH';'DiLH'};
%
%%
%---test plot Ts-error---
%{
loadfile=load('colormap/colormap_ncl.mat'); 
cmap0=loadfile.colormap_ncl(15:26:end-10,:); 
cmap=cmap0(1:8,:); cmap(1,:)=[0.9 0.9 0.9];
L=[0 0.1 0.5 1 5 10 20];
% L=[0 5 10 20 30 50 70];

% cmap0=loadfile.colormap_ncl(15:22:end,:);
% cmap=cmap0(1:11,:);
% cmap(1,:)=[0.9 0.9 0.9];
% L=[0 0.1 0.5 1 3 5 8 12 16 20];

% cexp=[0.1 0.1 0.1; 
%       0.32 0.8  0.95; 0    0.45 0.74; 0.01 0.11 0.63; 
%       0.96 0.6  0.79; 0.78 0.19 0.67; 0.47 0.05 0.45;  
%       0.95 0.8  0.13; 0.85 0.43 0.10; 0.70 0.08 0.18;
%       0.65 0.85 0.35; 0.38 0.6  0.13; 0.01 0.48 0.15
%       ];   
% cmap=[1 1 1;  0.9 0.9 0.9; 0.8 0.8 0.8; 0.7 0.7 0.7; 0.5 0.5 0.5; 0.3 0.3 0.3; 
%     0.1 0.1 0.1;   1 0.9 0.9;   1 0.8 0.8];
% L=[0 0.1 0.5 1 3 5 10 15];
%
tint=1; nti=0; ntii=0;
for ti=hrs 
  hr=ti;  
  nti=nti+1;
  if mod(nti,tint)==0 
    ntii=ntii+1;
    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
  end   
end

ratio1 = 0;  ratio2 = 0.5;
area1= 1;  area2= 10;
%--
plotexp=[1 3 9]; exptext='1303';

% for ploti=1:size(ploterms,1)-1
for ploti=2
    
  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,'_',exptext,'_'];
  eval(['DiffE_m=',ploterm,'_m;'])
  
  %---
  hf=figure('Position',[100 65 900 600]);    
  set(gca,'position',[0.1300 0.1100 0.71 0.8150])  
  
  %---plot colored curves---
  for ei=plotexp
    plot(1:ntime,DiffE_m(:,ei),'linewidth',12,'color',cexp(ei,:))
    plot_col_line(1:ntime,DiffE_m(:,ei),cgr(:,ei),cmap,L,6)
  end

  %---find 2 points and calculate slope (or quantatitive error)---
  for ei=plotexp
%     p1=find(cgr(:,ei)>ratio1,1);   
%     p2=find(cgr(:,ei)>ratio2,1);
    
%     p1=find(max_cldarea(:,ei)>area1,1); if p1==1; p1=2; end
%     p2=find(max_cldarea(:,ei)>area2,1);  
%     
%     plot(p1,DiffE_m(p1,ei),expmark{ei},'MarkerEdgeColor',cexp(ei,:),'MarkerFaceColor',cexp(ei,:),'MarkerSize',10,'linewidth',2)   
%     plot(p1,DiffE_m(p1,ei),expmark{ei},'MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',10,'linewidth',1)
%     plot(p2,DiffE_m(p2,ei),expmark{ei},'MarkerEdgeColor',cexp(ei,:),'MarkerFaceColor',cexp(ei,:),'MarkerSize',10,'linewidth',2)   
%     plot(p2,DiffE_m(p2,ei),expmark{ei},'MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',10,'linewidth',1)
    
%     line([p1 p2],[DiffE_m(p1,ei) DiffE_m(p2,ei)],'color',cexp(ei,:),'linewidth',3,'Linestyle','-.'); hold on  
%     slope(ei)= (log10(DiffE_m(p2,ei)) - log10(DiffE_m(p1,ei)) )/ (p2-p1) ;
%     error(ei)= (log10(DiffE_m(p2,ei)) - log10(DiffE_m(p1,ei)) ) ;
  end 
  
  %----
  set(gca,'yscale','log','fontsize',16,'LineWidth',1.2,'box','on')
   set(gca,'Xlim',[0 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
%    set(gca,'Ylim',[1e-4  2e1])
  xlabel('Local time');   ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')

%---colorbar---
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',16,'LineWidth',1.3);
  colormap(cmap); 
   ylabel(hc,'Ratio of cloud grids (%)','fontsize',18)  
  set(hc,'position',[0.87 0.160 0.018 0.7150]);
  
% %---legend
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  nei=0;
  for ei=plotexp  
    nei=nei+1;
    plot(xlimit(1)+1 , 10^(log10(ylimit(2))-0.4*nei) ,expmark{ei},'MarkerSize',10,'MarkerFaceColor',cexp(ei,:),'MarkerEdgeColor',cexp(ei,:),'linewidth',1.5);
%     text(xlimit(1)+1.8 , 10^(log10(ylimit(2))-0.4*nei) ,[expnam{ei},' (',num2str(slope(ei)),')'],'fontsize',18,'FontName','Monospaced','Interpreter','none','color',cexp(ei,:)); 
    text(xlimit(1)+1.8 , 10^(log10(ylimit(2))-0.4*nei) ,expnam{ei},'fontsize',18,'FontName','Monospaced','Interpreter','none','color',cexp(ei,:)); 
  end
  drawnow  
end
%}
%%
%--- test plot x-axis of max cloud area and cgr---
%{
% hrs=[22 23 24 25 26];  minu=0:10:50;  
%---set time legend (not all times are looped above)---
nti=0;
for ti=hrs 
  hr=ti;
  for tmi=minu
    nti=nti+1;  s_min=num2str(tmi,'%.2d');
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];
  end
end
%
loadfile=load('colormap/colormap_ncl.mat');  %col=loadfile.colormap_ncl(15:8:end,:);
col=loadfile.colormap_ncl(8:6:end,:);

plotexp=[1 8 9 10]; exptext='h1000';

% for ploti=1:size(ploterms,1)-1
for ploti=1

  ploterm=ploterms{ploti}; titnam=ploterm;  
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 900 600]);
  %---plot points---

  for ei=plotexp
    for nti=1:length(hrs)*length(minu) 
%      marker_size =10 + cgr(nti,ei) * 15/25;
      marker_size =13;
%       plot(max_cldarea(nti,ei),DiffE_m(nti,ei),expmark{ei},'MarkerSize',marker_size,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2)
      plot(cgr(nti,ei),DiffE_m(nti,ei),expmark{ei},'MarkerSize',marker_size,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2)
      hold on
    end
  end  
  
  %---colorbar for time legend----
  nti=length(hrs)*length(minu); tickint=2;
  L1=( (1:tickint:nti)*diff(caxis)/nti )  +  min(caxis()) -  diff(caxis)/nti/2;
  n=0; for i=1:tickint:nti; n=n+1; llll{n}=lgnd{i}; end
  colorbar('YTick',L1,'YTickLabel',llll,'fontsize',13,'LineWidth',1.2);
  colormap(col(1:nti,:))

  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
%    set(gca,'Yscale','log','fontsize',16,'LineWidth',1.2) 

  xlabel('Ratio (%)'); 
%     xlabel('Size (km)'); 

  ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
  %    set(gca,'Ylim',[1e-4 1e1])
%   set(gca,'Xlim',[5e-3 8e1],'Ylim',[1e-4 2e1])

%   %---plot legent for experiments---
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  nei=0;
  for ei=plotexp  
    nei=nei+1;
    plot(10^(log10(xlimit(1))+0.2) , 10^(log10(ylimit(2))-0.4*nei) ,expmark{ei},'MarkerSize',13,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
    text(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.4*nei) ,expnam{ei},'fontsize',18,'FontName','Monospaced','Interpreter','none'); 
  end
 
end
%}
%%
%---for all expri, plot x-axis of max cloud area---
%
outdir='/mnt/e/figures/expri_twin';

plotexp=1:13; exptext='all';
% for ploti=1:size(ploterms,1)-1
for ploti=[1]

  ploterm=ploterms{ploti}; titnam=ploterm;    eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 1100 600]);
  for ei=plotexp
    if ei==1; lin_wid=5; else; lin_wid=4;  end
%     plot(max_cldarea(13:end-3,ei),DiffE_m(13:end-3,ei),'+-','linewidth',lin_wid,'color',cexp(ei,:),'Markersize',15); hold on
    plot(max_cldarea(13:end-3,ei),DiffE_m(13:end-3,ei),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
  end  
  
  legend(expnam,'location','bestout','fontsize',22)
  
  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
  xlabel('Size (km)'); 

  ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
  %
  outfile=[outdir,'/',ploterm,'_x-area'];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']); 
end
%%
%---for all expri, plot x-axis of cloud grid ratio---
%
outdir='/mnt/e/figures/expri_twin';

plotexp=1:13; exptext='all';
% for ploti=1:size(ploterms,1)-1

for ploti=[1 ]

  ploterm=ploterms{ploti}; titnam=ploterm;    eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 1100 600]);
  for ei=plotexp
    if ei==1; lin_wid=5; else; lin_wid=4;  end
    plot(cgr(13:end-3,ei),DiffE_m(13:end-3,ei),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
  end  
    legend(expnam,'location','bestout','fontsize',22)  
  
  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
  xlabel('Ratio (%)'); 

  ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
%   set(gca,'Ylim',[1e-4 1e1])
  set(gca,'Xlim',[5e-3 8e1],'Ylim',[1e-3 2e1])

  outfile=[outdir,'/',ploterm,'_x-ratio_'];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']); 
end
%}
%%
%---plot different criteria for pick p2 as x-axis---
%{
 outdir='/mnt/e/figures/expri_twin';
 
cexp=[0.1 0.1 0.1; 
      0.32 0.8  0.95; 0    0.45 0.74; 0.01 0.11 0.63; 
      0.96 0.6  0.79; 0.78 0.19 0.67; 0.47 0.05 0.45;  
      0.95 0.8  0.13; 0.85 0.43 0.10; 0.70 0.08 0.18;
      0.65 0.85 0.35; 0.38 0.6  0.13; 0.01 0.48 0.15
      ];   

%--cloud grid ratio
%  s_critera='ratio'; s_unit='%';
% x_axis = [0 0.1 0.5 1 2 5 10 15];  con_int=cgr(13:end,:);

%---max cloud area
 s_critera='area'; s_unit='km';
x_axis= [1 5 10 20 40 60];  con_int=max_cldarea(13:end,:);

% for ploti=1:size(ploterms,1)-1
for ploti=1:4
    clear slop abs_err
  ploterm=ploterms{ploti};
  eval(['DiffE_m=',ploterm,'_m(13:end,:);'])
  
  %---find 2 points and calculate slope (or quantatitive error)---
  for ei=1:nexp
   for pi=1:length(x_axis)-1  
%     p1=find(con_int(:,ei)>x_axis(pi),1);
    p1=find(con_int(:,ei)>x_axis(1),1);
    p2=find(con_int(:,ei)>x_axis(pi+1),1);
    slop(ei,pi)= ( log10(DiffE_m(p2,ei))-log10(DiffE_m(p1,ei)) ) / (  log10(con_int(p2,ei))-log10(con_int(p1,ei))  );   
    abs_err(ei,pi)= DiffE_m(p2,ei);   
   end  
  end 
  
  hf=figure('Position',[100 65 900 600]);    
  for ei=nexp:-1:1
    if ei==1; lin_wid=5; else; lin_wid=4;  end
    plot(slop(ei,:),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
  end    
  set(gca,'linewidth',2,'fontsize',20)
  set(gca,'xlim',[0 length(x_axis)],'xtick',1:length(x_axis)-1,'xticklabel',x_axis(2:end))
  ylabel('slope');  xlabel(['Criteria (',s_critera,', ',s_unit,')'])  
 title([ploterm,'  (slope)'],'fontsize',25)
 
%   outfile=[outdir,'/',ploterm,'_slope_',s_critera];
%   print(hf,'-dpng',[outfile,'.png'])
%   system(['convert -trim ',outfile,'.png ',outfile,'.png']);

  %---
  hf=figure('Position',[100 65 900 600]);    
  for ei=nexp:-1:1
    if ei==1; lin_wid=5; else; lin_wid=4;  end
    plot(abs_err(ei,:),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
  end    
  set(gca,'linewidth',2,'fontsize',20)
  set(gca,'yscale','log')
  set(gca,'xlim',[0 length(x_axis)],'xtick',1:length(x_axis)-1,'xticklabel',x_axis(2:end))
  ylabel('Error (J kg^-^1)');   xlabel(['Criteria (',s_critera,', ',s_unit,')'])  
  title([ploterm,'  (abs. error value)'],'fontsize',25)
  
%   outfile=[outdir,'/',ploterm,'_abserr_',s_critera];
%   print(hf,'-dpng',[outfile,'.png'])
%   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
   
end
%}
%%
%---calculate error slope imagesc colored---
%{
% close all
load('colormap/colormap_hot20.mat');   cmap=colormap_hot20([1 2 4 6 8 10 12 13 17 20],:);

ratio1 = 0;  ratio2 = 0.5;
area1=1;     area2=10;

cgr2=cgr(13:end,:);
max_cldarea2=max_cldarea(13:end,:);

for ploti=1
  ploterm=ploterms{ploti};    eval(['DiffE_m=',ploterm,'_m(13:end,:);'])
  for ei=1:nexp   
    p1=find(max_cldarea2(:,ei)>area1,1);     p2=find(max_cldarea2(:,ei)>area2,1);      
    slop(ei,ploti)= ( log10(DiffE_m(p2,ei))-log10(DiffE_m(p1,ei)) ) / (  log10(max_cldarea2(p2,ei))-log10(max_cldarea2(p1,ei))  );
%     p1=find(cgr2(:,ei)>ratio1,1);     p2=find(cgr2(:,ei)>ratio2,1);
%     slop(ei,ploti)= ( log10(DiffE_m(p2,ei))-log10(DiffE_m(p1,ei)) ) / (  log10(cgr2(p2,ei))-log10(cgr2(p1,ei))  );
  end 
%------
  n=1;
  for h=1:4
    for v=1:3
      n=n+1;      
      error_quan(h,v)= slop(n,ploti) ;
    end
  end
  relative_err=error_quan./slop(1,ploti)*100;
  
  %----------
  hf=figure('Position',[100 300 650 600]);
  imagesc(relative_err)
  hc=colorbar('linewidth',1.5,'fontsize',16,'Ytick',10:10:90);
  colormap(cmap);  caxis([0 100])
  title(hc,'%','fontsize',20)
  %---text--
  for h=1:size(error_quan,1)
    for v=1:size(error_quan,2)
      if relative_err(h,v)>50; textcol='k';  else;  textcol='w'; end       
      text(v,h,num2str(error_quan(h,v),'%.4f'),'HorizontalAlignment','center','color',textcol,'fontsize',20,'FontWeight','bold')
    end
  end
  %  
  set(gca,'linewidth',2,'fontsize',20)
  set(gca,'xtick',[1 2 3],'xticklabel',{'V05','V10','V20'},'ytick',[1 2 3 4],'yticklabel',{'H05','H075','H10','H20'})
  title(ploterm,'fontsize',25)  
  
end
%}
%%
%---plot error growth (slope) based on cld area or ratio for all experiments
%---x-aixs: cloud area size, y-axis: slope(error/area diff.)
%{

cexp=[0.1 0.1 0.1; 
      0.32 0.8  0.95; 0    0.45 0.74; 0.01 0.11 0.63; 
      0.96 0.6  0.79; 0.78 0.19 0.67; 0.47 0.05 0.45;  
      0.95 0.8  0.13; 0.85 0.43 0.10; 0.70 0.08 0.18;
      0.65 0.85 0.35; 0.38 0.6  0.13; 0.01 0.48 0.15
      ];   
  
% hrs=[22 23 24 25 26];  minu=0:10:50;  
%---set time legend (not all times are looped above)---

%--cloud grid ratio
%  s_critera='ratio'; s_unit='%';
% x_axis = [0 0.1 0.3 0.5 1 3 5 10 15];  con_int=cgr;

%---max cloud area
 s_critera='area'; s_unit='km';
x_axis= 0:5:60;  con_int=max_cldarea;

% for ploti=1:size(ploterms,1)-1
for ploti=1
    clear x_p1 slop
  
  ploterm=ploterms{ploti}; titnam=ploterm;  eval(['DiffE_m=',ploterm,'_m;'])
  
  for ei=1:nexp-3
%    for pi=1:length(x_axis)-1  
    nti=0;
    for ti=1:3:ntime-3
        nti=nti+1;
%     p1=find(con_int(:,ei)>x_axis(pi),1);
%     p2=find(con_int(:,ei)>x_axis(pi+1),1);
%     slop(ei,pi)= ( log10(DiffE_m(p2,ei))-log10(DiffE_m(p1,ei)) ) / (  log10(con_int(p2,ei))-log10(con_int(p1,ei))  ); 
%     x_p1(ei,pi) = con_int(p2,ei);
      if con_int(ti,ei)==0
        slop(ei,nti)=NaN;
        x_p1(ei,nti)=NaN;
      else
%           ti
        slop(ei,nti)= ( log10(DiffE_m(ti+3,ei))-log10(DiffE_m(ti,ei)) ) / (  log10(con_int(ti+3,ei))-log10(con_int(ti,ei))  );
        x_p1(ei,nti) = con_int(ti+3,ei);
      end
    end  
  end 
  
  hf=figure('Position',[100 65 900 600]);
  for ei=nexp-3:-1:1
    if ei==1; lin_wid=5; else; lin_wid=4;  end
    plot(x_p1(ei,:),slop(ei,:),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
%     plot(x_p1(ei,:),slop(ei,:),'linewidth',lin_wid,'color',cexp(ei,:)); hold on
  end
  set(gca,'linewidth',2,'fontsize',20)
  set(gca,'xlim',[1 max(x_p1(1,:))+10],'ylim',[-0.3 4])
  ylabel('slope');  xlabel([s_critera,' (',s_unit,')'])  
 title([ploterm,'  (slope)'],'fontsize',25)
  
end
%}
%%
%--- calculate slop and save
%{
% close all
load('colormap/colormap_hot20.mat');   cmap=colormap_hot20([1 2 4 6 8 10 12 13 17 20],:);

ratio1 = 0;  ratio2 = 0.5;
area1=1;     area2=10;

cgr2=cgr(13:end,:);
max_cldarea2=max_cldarea(13:end,:);

for ploti=1:4
  ploterm=ploterms{ploti};    eval(['DiffE_m=',ploterm,'_m(13:end,:);'])
  for ei=1:nexp   
    p1=find(max_cldarea2(:,ei)>area1,1);     p2=find(max_cldarea2(:,ei)>area2,1);      
    slop_area(ploti,ei)= ( log10(DiffE_m(p2,ei))-log10(DiffE_m(p1,ei)) ) / (  log10(max_cldarea2(p2,ei))-log10(max_cldarea2(p1,ei))  );
      abserr_area(ploti,ei)= DiffE_m(p2,ei) ;
    p1=find(cgr2(:,ei)>ratio1,1);     p2=find(cgr2(:,ei)>ratio2,1);
    slop_ratio(ploti,ei)= ( log10(DiffE_m(p2,ei))-log10(DiffE_m(p1,ei)) ) / (  log10(cgr2(p2,ei))-log10(cgr2(p1,ei))  );
      abserr_ratio(ploti,ei)= DiffE_m(p2,ei) ;
  end 
end

FLAT_r_ratio=abserr_ratio./repmat(abserr_ratio(:,1),1,13);
FLAT_r_area=abserr_area./repmat(abserr_area(:,1),1,13);
%}
