tick='06';
load(['e01_fcst_corr_test',tick,'_256.mat'])
load(['e02_fcst_corr_test',tick,'_40.mat'])
figure('position',[200 500 800 500]) 

nps256=size(corr256,2);
nps40=size(corr40,2);
ng=size(corr256{1},1);

for i=1:ng
   for oi=1:min(nps256,nps40)
    corr40_2(oi,i)=corr40{oi}(i);
    corr256_2(oi,i)=corr256{oi}(i);
   end   
   corr40_std(i)=std(corr40_2(:,i));
   corr256_std(i)=std(corr256_2(:,i));
end

corr40_m=mean(corr40_2,1);
corr256_m=mean(corr256_2,1);


%for j=1:oi
%plot(1:73,corr40_2(j,:),'color',[0.85 0.85 0.85]); hold on
%end

%for j=1:oi
%plot(1:73,corr256_2(j,:),'color',[0.4 0.3 0.9])
%end

errorbar(5:4:72,corr40_m(5:4:72),corr40_std(5:4:72),'k','LineWidth',2); hold on
errorbar(5:4:72,corr256_m(5:4:72),corr256_std(5:4:72),'r','LineWidth',2)

xtick=[-36/2^0.5  -12/2^0.5 -4/2^0.5  0  4/2^0.5  12/2^0.5   36/2^0.5]+((ng-1)/2+1);
set(gca,'XLim',[10 ng-9],'Xtick',xtick,'XtickLabel',[-108 -36 -12 0 12 36 108],'fontsize',13)
set(gca,'YLim',[-0.6 0.6])
xlabel('km','fontsize',14); %ylabel('','fontsize',14)


outfile=['Vr-qr_standardiveation',tick,];

      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
      system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);

