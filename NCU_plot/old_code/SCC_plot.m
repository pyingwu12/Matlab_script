
clear
hr=0;  minu='00';   vonam='Vr';  vmnam='V';

%---set---
outdir=['/SAS011/pwin/201work/plot_cal/largens/largens'];
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')

cmap=[ 117  33  10;
       199  85  66;
       217 154 159;
       225 225 225;
       150 150 150; 
       50 50 50]./255;

L=[0.4 0.5 0.6 0.7 0.8];


%---
if strcmp(vmnam(1),'Q')==1;  s_vm=vmnam(1:2);  else  s_vm=vmnam; end
corrvari=[vonam,',',lower(s_vm)];
%
varinam=['SCC of Corr.(',corrvari,')'];    filenam=['Corr-SCC_'];
%
sub=12;
%sub2=sub*2+1;
plon=[118.4 121.8]; plat=[20.5 24.65];
%-----------------

%load(['2corr-SCC_',vonam,'-',lower(s_vm),'_4-24-23_12.mat'])
load(['corr-SCC_',vonam,'-',lower(s_vm),'_4-24-23.mat'])
scc1=scc; lon1=lon; lat1=lat;
n=length(scc1);
%load(['corr-SCC_',vonam,'-',lower(s_vm),'_4-05-73.mat'])
%scc1=scc; lon1=lon; lat1=lat;
%n=length(scc1);
%load(['2corr-SCC_',vonam,'-',lower(s_vm),'_3-24-23_12.mat'])
load(['corr-SCC_',vonam,'-',lower(s_vm),'_3-24-23.mat'])
scc1(n+1:n+length(scc))=scc; 
lon1(n+1:n+length(scc))=lon; lat1(n+1:n+length(scc))=lat;
n=length(scc1);
%load(['corr-SCC_',vonam,'-',lower(s_vm),'_4-05-73.mat'])
%scc1(n+1:n+length(scc))=scc; 
%lon1(n+1:n+length(scc))=lon; lat1(n+1:n+length(scc))=lat;
%n=length(scc1);
%load(['corr-SCC_',vonam,'-',lower(s_vm),'_4-24-23.mat'])
%scc1(n+1:n+length(scc))=scc; 
%lon1(n+1:n+length(scc))=lon; lat1(n+1:n+length(scc))=lat;
%n=length(scc1);


%-----------------
figure('position',[100 100 600 500])

m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')

clen=length(cmap);
Var=scc1;
  for i=1:n
    for k=1:clen-2;
      if (Var(i) > L(k) && Var(i)<=L(k+1))
        c=cmap(k+1,:);
        hp=m_plot(lon1(i),lat1(i),'s','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',9); hold on
        set(hp,'linestyle','none');
      end
    end
    if Var(i)>L(clen-1)
       c=cmap(clen,:);
       hp=m_plot(lon1(i),lat1(i),'s','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',9); hold on
       set(hp,'linestyle','none');
    end
    if Var(i)<L(1)
       c=cmap(1,:);
       hp=m_plot(lon1(i),lat1(i),'s','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',9); hold on
       set(hp,'linestyle','none');
    end
  end
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:45);
  m_gshhs_h('color','k','LineWidth',0.8);
  %m_coast('color','k');
  cm=colormap(cmap);    caxis([L(1) L(length(L))]);
  hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);


   s_hr=num2str(hr,'%.2d');
   tit=[varinam,'  ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',vonam,'-',lower(s_vm),'_sub',num2str(sub)];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);







