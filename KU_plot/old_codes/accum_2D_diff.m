close all
clear; ccc=':';
%---setting
expri='TWIN001';
expri1=[expri,'Pr001qv062221'];   expri2=[expri,'B'];  
stday=23;  sth=0;  acch=10; 
%---
year='2018'; mon='06';  s_min='00';  
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD008/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%---
titnam='Rainfall difference';   fignam=[expri1(8:end),'_accum-diff_'];
%
load('colormap/colormap_br3.mat')
cmap=colormap_br3(2:14,:);  cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-90 -70 -50 -30 -10 -2 2 10 30 50 70 90];

%---
for ti=sth
  s_sth=num2str(ti,'%2.2d');
  for ai=acch
    s_edh=num2str(mod(ti+ai,24),'%2.2d'); 
    for j=1:2
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read infile1--------
      infile=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
      rall1{j} = ncread(infile,'RAINC');
      rall1{j} = rall1{j} + ncread(infile,'RAINSH');
      rall1{j} = rall1{j} + ncread(infile,'RAINNC');
      %------read infile2--------
      infile=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
      rall2{j} = ncread(infile,'RAINC');
      rall2{j} = rall2{j} + ncread(infile,'RAINSH');
      rall2{j} = rall2{j} + ncread(infile,'RAINNC');
    end %j=1:2
    rain1=double(rall1{2}-rall1{1});   rain1(rain1+1==1)=NaN;
    rain2=double(rall2{2}-rall2{1});   rain2(rain2+1==1)=NaN;    
    hgt = ncread(infile,'HGT');  
    %
    rain_diff=rain1-rain2;    
    
    %---plot--- 
    plotvar=rain_diff';
    pmin=(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
    %
    hf=figure('position',[100 45 800 680]);
    [c, hp]=contourf(plotvar,L2,'linestyle','none');
    if (max(max(hgt))~=0)
    hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',16,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={expri;[titnam,'  ',s_sth,s_min,'-',s_edh,s_min,' UTC']};
    title(tit,'fontsize',18)

    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap);  title(hc,'mm','fontsize',13);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---

    outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,'_',num2str(ai),'h'];
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);

  end %acch
end %ti
