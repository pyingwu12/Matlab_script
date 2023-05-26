
thi=15; 
ti=19;

idifx=100;

  spd= squeeze(spd10_ens0(idifx:end-idifx,idifx:end-idifx,ti,:));
%%
pro_1000=zeros(nx-idifx*2+1,ny-idifx*2+1);
ensize=1000;
   for i=1:nx-idifx*2+1
      for j=1:ny-idifx*2+1
        pro_1000(i,j)=length(find(spd(i,j,:)>=thi));
      end
   end
   pro_1000=pro_1000/ensize;
%%
    
ensizes=[10 30 50 100 250 500 750 900 950];
pro_se=zeros(1,length(ensizes));
for inum=1:length(ensizes)

     ensize=ensizes(inum);
     
   pro=zeros(nx-idifx*2+1,ny-idifx*2+1);   
   for i=1:nx-idifx*2+1
      for j=1:ny-idifx*2+1
        pro(i,j)=length(find(spd(i,j,1:ensize)>=thi));
      end
   end
    pro=pro/ensize;
    pro_se(inum)=sum( sum( abs(pro-pro_1000) ,1),2)/(nx-idifx*2+1)/(ny-idifx*2+1);
   disp([num2str(ensize),'done']) 
end
%
hf=figure('Position',[100 100 900 600]);
plot(ensizes,pro_se*100,'linewidth',3,'marker','.','markersize',30)
% set(gca,'fontsize',16,'linewidth',1.2,'xtick',1:length(ensizes)-1,'xticklabel',ensizes(2:end))
set(gca,'fontsize',16,'linewidth',1.2,'xlim',[3 1000])

xlabel('Number of members')
title('Differences from the 1000-members results','fontsize',18)

outfile=[outdir,'/SmplErrWindProb_1km_1200_v3'];
   
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);