
clear
hr=0;  minu='00'; 

%---set---
outdir=['/SAS011/pwin/201work/plot_cal/largens/largens'];
addpath('/work/pwin/data/colorbar/')
addpath('/SAS011/pwin/201work/plot_cal')

cmap=[ 117  33  10;  199  85  66;  217 154 159;  220 220 220;  150 150 150;  65 65 65]./255;
cmap=flipud(cmap);
%cmap=[ 220 220 220; 150 150 150;  65 65 65;  217 154 159;  199  85  66;  117  33  10 ]./255;
%L=[0.4 0.5 0.6 0.7 0.8];

%----
varinam=['ABSerr random 40mem'];    filenam=['Corr-smad_'];
%
point='A'; s_sub='12'; randtimes=20+1;
%-----------------

load(['smad12_',point,'.mat'])
errsot=zeros(8,randtimes);
%[errsort(1,:) b]=sort(err(:,2),'descend'); smallerr(1)=find(b==21);  %Vr-u
%[errsort(2,:) b]=sort(err(:,1),'descend'); smallerr(2)=find(b==21);  %Vr-v
%[errsort(3,:) b]=sort(err(:,3),'descend'); smallerr(3)=find(b==21);  %Vr-qv
%[errsort(4,:) b]=sort(err(:,4),'descend'); smallerr(4)=find(b==21);  %Vr-qr
%[errsort(5,:) b]=sort(err(:,6),'descend'); smallerr(5)=find(b==21);  %Zh-u
%[errsort(6,:) b]=sort(err(:,5),'descend'); smallerr(6)=find(b==21);  %Zh-v
%[errsort(7,:) b]=sort(err(:,7),'descend'); smallerr(7)=find(b==21);  %Zh-qv
%[errsort(8,:) b]=sort(err(:,8),'descend'); smallerr(8)=find(b==21);  %Zh-qr

errsort(1,:)=err(:,2); smallerr(1)=21;  %Vr-u
errsort(2,:)=err(:,1); smallerr(2)=21;  %Vr-u
errsort(3,:)=err(:,3); smallerr(3)=21;  %Vr-u
errsort(4,:)=err(:,4); smallerr(4)=21;  %Vr-u
errsort(5,:)=err(:,5); smallerr(5)=21;  %Vr-u
errsort(6,:)=err(:,6); smallerr(6)=21;  %Vr-u
errsort(7,:)=err(:,7); smallerr(7)=21;  %Vr-u
errsort(8,:)=err(:,8); smallerr(8)=21;  %Vr-u

%
%-----------------
figure('position',[100 100 750 500])

  imagesc(errsort); hold on
  hc=colorbar;    cm=colormap(cmap);  
  caxis([0.15 0.45]); set(hc,'fontsize',13,'LineWidth',0.8,'YTick',[0.2 0.25 0.3 0.35 0.4]);
  %hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);

  %ticklabel={'CORR(Vr,U)';'CORR(Zh,U)';'CORR(Vr,V)';'CORR(Zh,V)'; ...
  %              'CORR(Vr,Qv)';'CORR(Zh,Qv)';'CORR(Vr,Qr)';'CORR(Zh,Qr)'};
  ticklabel={'CORR(Vr,U)';'CORR(Vr,V)';'CORR(Vr,Qv)';'CORR(Vr,Qr)'; ...
                'CORR(Zh,U)';'CORR(Zh,V)';'CORR(Zh,Qv)';'CORR(Zh,Qr)'};

  set(gca,'YTickLabel',ticklabel,'fontsize',13,'XTick',[1.5:1:20.5],'Xticklabel',[ ],'Ticklength',[0 0],'LineWidth',1)

  hold on
  for i=1:8
   if mod(i,4)==0
    line([0 randtimes+0.5],[i+0.5 i+0.5],'color',[1 1 1],'LineWidth',0.8,'LineStyle','--')
   end
   line([smallerr(i)-0.5 smallerr(i)-0.5 smallerr(i)+0.5 smallerr(i)+0.5 smallerr(i)-0.5],[i-0.5 i+0.5 i+0.5 i-0.5 i-0.5],'color',[1 1 1],'LineWidth',1.6)
  end

   s_hr=num2str(hr,'%.2d');
   %tit=['Point ',point,'  ',varinam,'  ',s_hr,'z (',s_sub,'*3 km)'];
   tit=['Point ',point,'  SMAD'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_sub',s_sub,'_point',point];
  %  set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
  %  system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
  %  system(['rm ',[outfile,'.pdf']]);

%}
