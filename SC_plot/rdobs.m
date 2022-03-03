dir='/SAS001/ailin/GPS/20080612-17/COSMIC/Bend_ang/IOP_res27/NewH/';
dd=15;
hh=12;
figure(1);clf
cols(1,1:3)=[1,0,0];
cols(2,1:3)=[0,0,1];
for it=1:1
    file=['obs_2008-06-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
    infile=[dir,file];
    fid=fopen(infile,'r')
    ieof=0;
    i=0;
    %cols=jet(8);
    %colormap(cols);
    while (ieof ==0);
      a=fscanf(fid,'%f %f %u %u %u %s',6);
      ieof=feof(fid);
      if(ieof==0)
      nobs=a(3);
      lon=a(1);
      lat=a(2);
      [c,count]=fscanf(fid,'%f %f %f %f',[4, nobs]);
      %if( abs(lon-115)< 10 & abs(lat-21)< 10)
      if( abs(lon-119)< 5 & abs(lat-24)< 5)
      i=i+1;
      subplot(2,1,1)
      %plot(c(2,:),c(1,:),'r','linewidth',2.0);hold on
      plot(c(2,:),c(1,:),'color',cols(i,:),'linewidth',2.0);hold on
      text(395,9800-500*i,['lon=',num2str(lons(i),'%6.1f'),', lat=',num2str(lats(i),'%6.1f')],'horizontalalignment','right')
      plot([280 300],[9850-500*i 9850-500*i],'color',cols(i,:),'linewidth',2.0)
      subplot(2,1,2)
      %plot(c(3,:),c(1,:),'r','linewidth',2.0);hold on
      plot(c(3,:),c(1,:),'color',cols(i,:),'linewidth',2.0);hold on
      text(0.0345,9800-500*i,['lon=',num2str(lons(i),'%6.1f'),', lat=',num2str(lats(i),'%6.1f')],'horizontalalignment','right')
      plot([0.024 0.026],[9850-500*i 9850-500*i],'color',cols(i,:),'linewidth',2.0)

      lons(i)=lon;
      lats(i)=lat;
      %else
      %subplot(2,1,1)
      %plot(c(2,:),c(1,:),'color',[0.5 0.5 0.5]);hold on
      %subplot(2,1,2)
      %plot(c(3,:),c(1,:),'color',[0.5 0.5 0.5]);hold on
      end
      end
    end
    fclose(fid)
    hh=hh+6;
    if(hh>=24);dd=dd+1;hh=hh-24;end
end
%axis([0.005 0.035 0 10.0e3])
subplot(2,1,1)
set(gca,'ylim',[0 1.e4],'fontsize',14)
ylabel('Altitude','fontsize',14)
%title('(a) REF (061300Z-061512Z)','fontsize',14)
title('(a) REF','fontsize',14)
subplot(2,1,2)
set(gca,'ylim',[0 1.e4],'fontsize',14)
ylabel('Altitude','fontsize',14)
%title('(b) Bangle (061300Z-061512Z)','fontsize',14)
title('(b) Bangle','fontsize',14)
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 6.5 10])
