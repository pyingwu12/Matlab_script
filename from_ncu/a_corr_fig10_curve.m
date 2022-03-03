load 'corr40_da.mat'
load 'corr256_da.mat'
figure('position',[200 500 800 500]) 

nps256=size(corr256da,2);
nps40=size(corr40da,2);
ng=size(corr256da{1},1);

for i=1:ng
   for oi=1:min(nps256,nps40)
    corr40_2(oi,i)=corr40da{oi}(i);
    corr256_2(oi,i)=corr256da{oi}(i);
   end   
   corr40_std(i)=std(corr40_2(:,i));
   corr256_std(i)=std(corr256_2(:,i));
end

corr40_m=mean(corr40_2,1);
corr256_m=mean(corr256_2,1);

errorbar(5:4:72,corr40_m(5:4:72),corr40_std(5:4:72),'k','LineWidth',2); hold on
errorbar(5:4:72,corr256_m(5:4:72),corr256_std(5:4:72),'r','LineWidth',2)

xtick=[-36/2^0.5  -12/2^0.5 -4/2^0.5  0  4/2^0.5  12/2^0.5   36/2^0.5]+((ng-1)/2+1);
set(gca,'XLim',[1 ng],'Xtick',xtick,'XtickLabel',[-108 -36 -12 0 12 36 108],'fontsize',13)
set(gca,'YLim',[-0.8 0.8])
xlabel('km','fontsize',14); ylabel('Error correlation','fontsize',14)
