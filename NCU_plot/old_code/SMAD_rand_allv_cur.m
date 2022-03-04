
clear
hr=0;  minu='00'; 

%---set---
outdir=['/SAS011/pwin/201work/plot_cal/largens/largens'];
addpath('/SAS011/pwin/201work/plot_cal')

%----
varinam=['ABSerr random 40mem'];    filenam=['Corr-smad_'];
%
 s_sub='12'; randtimes=40+1;
%-----------------
point='A';
load(['smad',s_sub,'_',point,'.mat'])
[errsort(1,:) b]=sort(err(:,2),'descend'); smallerr(1)=find(b==randtimes);  %Vr-u
[errsort(2,:) b]=sort(err(:,1),'descend'); smallerr(2)=find(b==randtimes);  %Vr-v
[errsort(3,:) b]=sort(err(:,3),'descend'); smallerr(3)=find(b==randtimes);  %Vr-qv
[errsort(4,:) b]=sort(err(:,4),'descend'); smallerr(4)=find(b==randtimes);  %Vr-qr
[errsort(5,:) b]=sort(err(:,7),'descend'); smallerr(5)=find(b==randtimes);  %Zh-u
[errsort(6,:) b]=sort(err(:,6),'descend'); smallerr(6)=find(b==randtimes);  %Zh-v
[errsort(7,:) b]=sort(err(:,8),'descend'); smallerr(7)=find(b==randtimes);  %Zh-qv
[errsort(8,:) b]=sort(err(:,9),'descend'); smallerr(8)=find(b==randtimes);  %Zh-qr

point='B';
load(['smad',s_sub,'_',point,'.mat'])
[errsortB(1,:) b]=sort(err(:,2),'descend'); smallerrB(1)=find(b==randtimes);  %Vr-u
[errsortB(2,:) b]=sort(err(:,1),'descend'); smallerrB(2)=find(b==randtimes);  %Vr-v
[errsortB(3,:) b]=sort(err(:,3),'descend'); smallerrB(3)=find(b==randtimes);  %Vr-qv
[errsortB(4,:) b]=sort(err(:,4),'descend'); smallerrB(4)=find(b==randtimes);  %Vr-qr
[errsortB(5,:) b]=sort(err(:,7),'descend'); smallerrB(5)=find(b==randtimes);  %Zh-u
[errsortB(6,:) b]=sort(err(:,6),'descend'); smallerrB(6)=find(b==randtimes);  %Zh-v
[errsortB(7,:) b]=sort(err(:,8),'descend'); smallerrB(7)=find(b==randtimes);  %Zh-qv
[errsortB(8,:) b]=sort(err(:,9),'descend'); smallerrB(8)=find(b==randtimes);  %Zh-qr

%
%-----------------

cline=[0.1 0.1 0.7; 0.1 0.7 0.1; 0.6 0.1 0.1; 0.1 0.1 0.1];
figure('position',[100 100 900 600])
 
  for i=1:4;    
    plot(errsort(i,:),'s-','color',cline(i,:),'LineWidth',1.3,'Markersize',8); hold on;  
    plot(errsort(i+4,:),'^-','color',cline(i,:),'LineWidth',1.3,'Markersize',8);
  end
  for i=1:4; 
    plot(smallerr(i),errsort(i,(smallerr(i))),'s','color',cline(i,:), 'Markersize',9 , 'MarkerFaceColor',cline(i,:));
    plot(smallerr(i+4),errsort(i+4,(smallerr(i+4))),'^','color',cline(i,:), 'Markersize',9 , 'MarkerFaceColor',cline(i,:));
  end
  
%----
cline=[0.2 0.2 0.8; 0.2 0.8 0.2; 0.9 0.2 0.2; 0.3 0.3 0.3];

  for i=1:4;
    plot(errsortB(i,:),'s--','color',cline(i,:),'LineWidth',1.3,'Markersize',8); hold on;
    plot(errsortB(i+4,:),'^--','color',cline(i,:),'LineWidth',1.3,'Markersize',8);
  end
  for i=1:4;
    plot(smallerrB(i),errsortB(i,(smallerrB(i))),'s','color',cline(i,:), 'Markersize',9 , 'MarkerFaceColor',cline(i,:));
    plot(smallerrB(i+4),errsortB(i+4,(smallerrB(i+4))),'^','color',cline(i,:), 'Markersize',9 , 'MarkerFaceColor',cline(i,:));
  end

  for i=0.1:0.1:0.9
   line([0 0.2],[i i],'color','k','LineWidth',1);
   line([randtimes+0.8 randtimes+1],[i i],'color','k','LineWidth',1);
  end

  label={'CORR(Vr,U)';'CORR(Zh,U)';'CORR(Vr,V)';'CORR(Zh,V)'; ...
                'CORR(Vr,Qv)';'CORR(Zh,Qv)';'CORR(Vr,Qr)';'CORR(Zh,Qr)'};

%  label={'CORR(Vr,U)';'CORR(Vr,V)';'CORR(Vr,Qv)';'CORR(Vr,Qr)'; ...
%                'CORR(Zh,U)';'CORR(Zh,V)';'CORR(Zh,Qv)';'CORR(Zh,Qr)'};
  legend(label);  ylabel('SMAD','fontsize',13)
  set(gca,'Xlim',[0 randtimes+1],'Ylim',[0 0.7],'XTick',[1.5:1:20.5],'Xticklabel',[ ],'Ticklength',[0 0],'LineWidth',1,'fontsize',14)

   s_hr=num2str(hr,'%.2d');
   tit=['SMADs ',s_sub,'grid'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_sub',s_sub,'_curve'];
    %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    %system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    %system(['rm ',[outfile,'.pdf']]);

%}
