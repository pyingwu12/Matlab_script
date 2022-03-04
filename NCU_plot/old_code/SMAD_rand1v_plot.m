
clear
hr=0;  minu='00'; 

%---set---
outdir=['/SAS011/pwin/201work/plot_cal/largens/largens'];
addpath('/work/pwin/data/colorbar/')
addpath('/SAS011/pwin/201work/plot_cal')

%cmap=[ 117  33  10;
%       199  85  66;
%       217 154 159;
%       220 220 220;
%       150 150 150; 
%       65 65 65]./255;
%cmap=flipud(cmap);
cmap=[ 220 220 220; 150 150 150;  65 65 65;  217 154 159;  199  85  66;  117  33  10 ]./255;
%L=[0.4 0.5 0.6 0.7 0.8];

%----
varinam=['ABSerr random 40mem'];    filenam=['Corr-smad_'];
%
point='B'; s_sub='12'; randtimes=20+1;
%-----------------

%abserrall=zeros(8,20);
abserrall=zeros(8,randtimes);
nam='smad';
load([nam,'_Vr-u_',s_sub,point,'.mat']); [abserrall(1,:) b]=sort(abserr,'descend');  abserr21(1)=find(b==21);
load([nam,'_Zh-u_',s_sub,point,'.mat']); [abserrall(2,:) b]=sort(abserr,'descend');  abserr21(2)=find(b==21);  
load([nam,'_Vr-v_',s_sub,point,'.mat']); [abserrall(3,:) b]=sort(abserr,'descend');  abserr21(3)=find(b==21);
load([nam,'_Zh-v_',s_sub,point,'.mat']); [abserrall(4,:) b]=sort(abserr,'descend');  abserr21(4)=find(b==21);
load([nam,'_Vr-qv_',s_sub,point,'.mat']); [abserrall(5,:) b]=sort(abserr,'descend');  abserr21(5)=find(b==21);
load([nam,'_Zh-qv_',s_sub,point,'.mat']); [abserrall(6,:) b]=sort(abserr,'descend');  abserr21(6)=find(b==21);
load([nam,'_Vr-qr_',s_sub,point,'.mat']); [abserrall(7,:) b]=sort(abserr,'descend');  abserr21(7)=find(b==21);
load([nam,'_Zh-qr_',s_sub,point,'.mat']); [abserrall(8,:) b]=sort(abserr,'descend');  abserr21(8)=find(b==21);
%
%-----------------
figure('position',[100 100 750 500])

  imagesc(abserrall); hold on
  hc=colorbar;    cm=colormap(cmap);  
  caxis([0.15 0.45]); set(hc,'fontsize',13,'LineWidth',0.8,'YTick',[0.2 0.25 0.3 0.35 0.4]);
  %hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);

  ticklabel={'CORR.(Vr,U)';'CORR.(Zh,U)';'CORR.(Vr,V)';'CORR.(Zh,V)'; ...
                'CORR.(Vr,Qv)';'CORR.(Zh,Qv)';'CORR.(Vr,Qr)';'CORR.(Zh,Qr)'};

  set(gca,'YTickLabel',ticklabel,'fontsize',13,'XTick',[1.5:1:20.5],'Xticklabel',[ ],'Ticklength',[0 0],'LineWidth',1)

  hold on
  for i=1:8
   if mod(i,2)==0
    line([0 randtimes+0.5],[i+0.5 i+0.5],'color',[1 1 1],'LineWidth',0.8,'LineStyle','--')
   end
   line([abserr21(i)-0.5 abserr21(i)-0.5 abserr21(i)+0.5 abserr21(i)+0.5 abserr21(i)-0.5],[i-0.5 i+0.5 i+0.5 i-0.5 i-0.5],'color',[1 1 1],'LineWidth',1.6)
  end

   s_hr=num2str(hr,'%.2d');
   %tit=['Point ',point,'  ',varinam,'  ',s_hr,'z (',s_sub,'*3 km)'];
   tit=['Point ',point,'  sMAD'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_sub',s_sub,'_point',point];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);

%}
