function Rain_2D_Filt_twin(expri)

close all
% clear; 
ccc=':';
saveid=1; % save figure (1) or not (0)
%---setting
% expri='TWIN020';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  

filt_len=0;  dx=1; dy=1;

stday=22;  sth=22;   s_minu='00';   acch=12; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin/JAS_R2';
%outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
% indir='D:expri_twin';  
%---
titnam='Accumulated Rainfall';   fignam=[expri1,'_rain-twin2_'];
%fignam=[expri1(8:end),'_rain-twin_'];

%
load('colormap/colormap_rain.mat')
cmap=colormap_rain([1 2 4 6 7 8 10 12 13 15 17],:);
L=[0.5 5 10 15 20 30 45 60 80 100];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;

% cmap=colormap_rain; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[  0.5   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];

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
   
    hgt = ncread(infile2,'HGT');  
    
    if filt_len~=0
      rain_f1=low_pass_filter(rain1,filt_len,dx,dy); 
      rain_f2=low_pass_filter(rain2,filt_len,dx,dy); 
    else 
        rain_f1=rain1; rain_f2=rain2;
    end
    rain_f1(rain_f1+1==1)=NaN;
    rain_f2(rain_f2+1==1)=NaN;
    
    rainf1_ext=repmat(rain_f1,3,3);
    rainf2_ext=repmat(rain_f2,3,3);
    hgt_ext=repmat(hgt,3,3);
    %%
    %---plot--- 
    plotvar=rainf2_ext';
    pmin=(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
    %
    hf=figure('position',[100 45 800 700]);
    [~, hp]=contourf(plotvar,L2,'linestyle','none');
    
    hold on
    contour(rainf1_ext',[5 5],'color',[0.15 0.15 0.15],'linestyle','-','linewidth',2.95);    

    if (max(max(hgt))~=0)
%      contour(hgt',[100 500 900],'color',[0.65 0.65 0.65],'linestyle','--','linewidth',2.5); 
     contour(hgt_ext',[100 500 900],'color',[0.6 0.6 0.6],'linestyle','-.','linewidth',3.2);  %JAS_R2
    end
    %
    set(gca,'fontsize',25,'LineWidth',2,'XLim',[301 600],'ylim',[301 600]) 

    set(gca,'Xtick',350:100:600,'Ytick',350:100:600,'Xticklabel',50:100:300,'Yticklabel',50:100:300)
    xlabel('(km)'); ylabel('(km)');
    
    tit={expri;[titnam,'  ',s_sthj,s_minu,'-',s_edhj,s_minu,' LT']};
    title(tit,'fontsize',18)

    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap);  title(hc,'mm','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---

    outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_minu,'_',num2str(ai),'h'];
    if filt_len~=0; outfile=[outfile,'_L',num2str(filt_len)]; end
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end

  end %acch
end %ti
