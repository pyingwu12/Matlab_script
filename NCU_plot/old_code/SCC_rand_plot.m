
clear
hr=0;  minu='00';   vonam='Zh';  vmnam='QVAPOR';

%---set---
outdir=['/SAS011/pwin/201work/plot_cal/largens/largens'];
addpath('/work/pwin/data/colorbar/')

cmap=[ 117  33  10;
       199  85  66;
       217 154 159;
       220 220 220;
       150 150 150; 
       65 65 65]./255;

L=[0.4 0.5 0.6 0.7 0.8];

%----
varinam=['SCC random 40mem'];    filenam=['Corr-SCCrand_'];
%
point='B'; s_sub='12'; randtimes=20+1;
%-----------------

%sccall=zeros(8,20);
sccall=zeros(8,randtimes);
%load(['scc-rand_Vr-v_',s_sub,point,'.mat']); sccall(1,:)=sort(scc);
load(['scc21_Vr-v_',s_sub,point,'.mat']); [sccall(1,:) b]=sort(scc);  scc21(1)=find(b==21);
%load(['scc-rand_Zh-v_',s_sub,point,'.mat']); sccall(2,:)=sort(scc);
load(['scc21_Zh-v_',s_sub,point,'.mat']); [sccall(2,:) b]=sort(scc);  scc21(2)=find(b==21);  
%load(['scc-rand_Vr-u_',s_sub,point,'.mat']); sccall(3,:)=sort(scc);
load(['scc21_Vr-u_',s_sub,point,'.mat']); [sccall(3,:) b]=sort(scc);  scc21(3)=find(b==21);
%load(['scc-rand_Zh-u_',s_sub,point,'.mat']); sccall(4,:)=sort(scc);
load(['scc21_Zh-u_',s_sub,point,'.mat']); [sccall(4,:) b]=sort(scc);  scc21(4)=find(b==21);
%load(['scc-rand_Vr-qr_',s_sub,point,'.mat']); sccall(5,:)=sort(scc);
load(['scc21_Vr-qr_',s_sub,point,'.mat']); [sccall(5,:) b]=sort(scc);  scc21(5)=find(b==21);
%load(['scc-rand_Zh-qr_',s_sub,point,'.mat']); sccall(6,:)=sort(scc);
load(['scc21_Zh-qr_',s_sub,point,'.mat']); [sccall(6,:) b]=sort(scc);  scc21(6)=find(b==21);
%load(['scc-rand_Vr-qv_',s_sub,point,'.mat']); sccall(7,:)=sort(scc);
load(['scc21_Vr-qv_',s_sub,point,'.mat']); [sccall(7,:) b]=sort(scc);  scc21(7)=find(b==21);
%load(['scc-rand_Zh-qv_',s_sub,point,'.mat']); sccall(8,:)=sort(scc);
load(['scc21_Zh-qv_',s_sub,point,'.mat']); [sccall(8,:) b]=sort(scc);  scc21(8)=find(b==21);

%-----------------
figure('position',[100 100 750 500])

  imagesc(sccall); hold on
  hc=colorbar;    cm=colormap(cmap);  
  caxis([0.2 0.8]); set(hc,'fontsize',13,'LineWidth',0.8);
  %hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);

  ticklabel={'CORR.(Vr,V)';'CORR.(Zh,V)';'CORR.(Vr,U)';'CORR.(Zh,U)'; ...
                'CORR.(Vr,Qr)';'CORR.(Zh,Qr)';'CORR.(Vr,Qv)';'CORR.(Zh,Qv)'};

  set(gca,'YTickLabel',ticklabel,'fontsize',13,'XTick',[1.5:1:20.5],'Xticklabel',[ ],'Ticklength',[0 0],'LineWidth',1)

  hold on
  for i=1:8
   if mod(i,2)==0;
    line([0 randtimes+0.5],[i+0.5 i+0.5],'color',[1 1 1],'LineWidth',0.8,'LineStyle','--')
   end
   line([scc21(i)-0.5 scc21(i)-0.5 scc21(i)+0.5 scc21(i)+0.5 scc21(i)-0.5],[i-0.5 i+0.5 i+0.5 i-0.5 i-0.5],'color',[1 1 1],'LineWidth',1.6)
   %line([scc21(i)+0.5 scc21(i)+0.5],[i-0.5 i+0.5],'color',[1 1 1])
  end

   s_hr=num2str(hr,'%.2d');
   %tit=['Point ',point,'  ',varinam,'  ',s_hr,'z (',s_sub,'*3 km)'];
   tit=['Point ',point,'  SCC'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_sub',s_sub,'_point',point];
  %  set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
  %  system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
  %  system(['rm ',[outfile,'.pdf']]);


