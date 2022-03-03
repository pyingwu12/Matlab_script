clear all
figure(1);clf
%threshold=[1 5 10 15 20 30 35 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 250 300];
%threshold=[1 2 6 10 15 20 30 40 50 70 90 110 130 150 200 300];
threshold0=[1 2 6 10 15 20 30 40 50 70 90 110 130 150 200];
nthres=length(threshold0);
for icase=1:4
    threshold=threshold0;
    switch icase 
    case(1)
     file1='/SAS002/zerocustom/20151210/init_2008061512/rainfall_obsAndEnsFcst_e18_2008061516to2008061616_120to120.8E_22.4to23.4N.txt';
     file2='/SAS002/zerocustom/20151210/init_2008061512/rainfall_obsAndEnsFcst_e20_2008061516to2008061616_120to120.8E_22.4to23.4N.txt';
     tit='SW (init 06/15 1200UTC)';
    case(2)
     %file1='/SAS002/zerocustom/20151210/rainfall_obsAndEnsFcst_e18_2008061516to2008061616_121to121.5E_24.75to25.15N.txt';
     %file2='/SAS002/zerocustom/20151210/rainfall_obsAndEnsFcst_e20_2008061516to2008061616_121to121.5E_24.75to25.15N.txt';
     file1='/SAS002/zerocustom/20151210/init_2008061512/rainfall_obsAndEnsFcst_e18_2008061600to2008061612_121to121.5E_24.75to25.15N.txt';
     file2='/SAS002/zerocustom/20151210/init_2008061512/rainfall_obsAndEnsFcst_e20_2008061600to2008061612_121to121.5E_24.75to25.15N.txt';
     tit='TPE (init 06/15 1200UTC)';
    case(3)
     %file1='/SAS002/zerocustom/20151210/rainfall_obsAndEnsFcst_e18_2008061518to2008061616_120to120.8E_22.4to23.4N.txt';
     %file2='/SAS002/zerocustom/20151210/rainfall_obsAndEnsFcst_e20_2008061518to2008061616_120to120.8E_22.4to23.4N.txt';
     file1='/SAS002/zerocustom/20151210/init_2008061518/rainfall_obsAndEnsFcst_e18_2008061518to2008061616_120to120.8E_22.4to23.4N.txt';
     file2='/SAS002/zerocustom/20151210/init_2008061518/rainfall_obsAndEnsFcst_e20_2008061518to2008061616_120to120.8E_22.4to23.4N.txt';
     tit='SW (init 06/15 1800UTC)';
     %threhold=22*threshold0/24;
    case(4)
     %file1='/SAS002/zerocustom/20151210/rainfall_obsAndEnsFcst_e18_2008061518to2008061616_121to121.5E_24.75to25.15N.txt';
     %file2='/SAS002/zerocustom/20151210/rainfall_obsAndEnsFcst_e20_2008061518to2008061616_121to121.5E_24.75to25.15N.txt';
     file1='/SAS002/zerocustom/20151210/init_2008061518/rainfall_obsAndEnsFcst_e18_2008061600to2008061612_121to121.5E_24.75to25.15N.txt';
     file2='/SAS002/zerocustom/20151210/init_2008061518/rainfall_obsAndEnsFcst_e20_2008061600to2008061612_121to121.5E_24.75to25.15N.txt';
     tit='TPE (init 06/15 1800UTC)';
    end
    BS=zeros(nthres,2);
    obsnum=zeros(nthres,2);
    for i=1:2
        eval(['fid=fopen(file',num2str(i),')'])
        mydata=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n');
        n=length(mydata{1});
        for is=1:nthres
            BS(is,i)=0.0;
            for j=1:n
                for k=1:36
                    x(k)=mydata{3+k}(j);
                end
                y=mydata{3}(j);
                p=length(find(x>=threshold(is)))/36.0;
                if( y>=threshold(is))
                   obsnum(is,i)=obsnum(is,i)+1;
                   BS(is,i)=BS(is,i)+(p-1.0).^2;
                else
                   BS(is,i)=BS(is,i)+(p-0.0).^2;
                end
            end
            BS(is,i)=BS(is,i)/n;
        end
        fclose(fid);
        obsnum(:,1)
    end
    subplot(2,2,icase)
    plot(BS(:,1),'-b.');hold on
    plot(BS(:,2),'-r.');hold on
    set(gca,'xlim',[1 nthres],'xtick',[1:nthres],'xticklabel',num2str(threshold(1:end)'))
    legend('D01S','D02DL')
    legend('boxoff')
  
    ylabel('Brier Score','fontsize',14)
    switch(icase)
    case(1)
        xlabel('threshold (mm/24h)','fontsize',14)
        title(['(a)',tit],'fontsize',14,'fontweight','bold')
    case(3)
        xlabel('threshold (mm/22h)','fontsize',14)
        title(['(c)',tit],'fontsize',14,'fontweight','bold')
    case(2)
        xlabel('threshold (mm/12h)','fontsize',14)
        title(['(b)',tit],'fontsize',14,'fontweight','bold')
    case(4)
        xlabel('threshold (mm/12h)','fontsize',14)
        title(['(d)',tit],'fontsize',14,'fontweight','bold')
    end
end

set(gcf,'paperorientation','landscape','paperposition',[0.25 0.5 10.5 7.5]);
