function Rain_2D_twin(expri)
% close all
% clear; 
ccc=':';
saveid=1; % save figure (1) or not (0)
%---setting
% expri='TWIN013';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  

stday=22;  sth=[22];   s_minu='00';   acch=12; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin/Rainfall';
%outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%---
titnam='Accumulated Rainfall';   fignam=[expri1,'_rain-twin_'];
%fignam=[expri1(8:end),'_rain-twin_'];
%
load('colormap/colormap_rain.mat')
cmap=colormap_rain; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[  0.1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];

%---
for ti=sth
  s_sthj=num2str(mod(ti+9,24),'%2.2d');   s_sth=num2str(ti,'%2.2d');
  for ai=acch
    s_edhj=num2str(mod(ti+ai+9,24),'%2.2d'); 
    
    
    for j=1:2
      hr=(j-1)*ai+ti;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
      %------read netcdf data--------
      infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_minu,ccc,'00'];
      rall{j} = ncread(infile1,'RAINC');
      rall{j} = rall{j} + ncread(infile1,'RAINSH');
      rall{j} = rall{j} + ncread(infile1,'RAINNC');
    end %j=1:2
    rain1=double(rall{2}-rall{1});
    rain1(rain1+1==1)=NaN;
    
    clear rall
    for j=1:2
      hr=(j-1)*ai+ti;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
      %------read netcdf data--------
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_minu,ccc,'00'];
      rall{j} = ncread(infile2,'RAINC');
      rall{j} = rall{j} + ncread(infile2,'RAINSH');
      rall{j} = rall{j} + ncread(infile2,'RAINNC');
    end %j=1:2
    rain2=double(rall{2}-rall{1});
    rain2(rain2+1==1)=NaN;
    hgt = ncread(infile2,'HGT');  
    %%
    %---plot--- 
    plotvar=rain2';
    pmin=(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
    %
    hf=figure('position',[100 45 800 680]);
    [~, hp]=contourf(plotvar,L2,'linestyle','none');
    
    hold on
    contour(rain1',[10 10],'color',[0.1 0.1 0.1],'linestyle','-','linewidth',3)

    if (max(max(hgt))~=0)
     contour(hgt',[100 500 900],'color',[0.65 0.65 0.65],'linestyle','--','linewidth',2.5); 
    end
    %
    set(gca,'fontsize',20,'LineWidth',1.2,'Xtick',50:50:250,'Ytick',50:50:250) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    
    tit={expri;[titnam,'  ',s_sthj,s_minu,'-',s_edhj,s_minu,' LT']};
    title(tit,'fontsize',18)

    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.2);
    colormap(cmap);  title(hc,'mm','fontsize',15);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---

    outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_minu,'_',num2str(ai),'h'];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end

  end %acch
end %ti
