% close all
clear
saveid=0; % save figure (1) or not (0)
%---setting
expri='TWIN001Pr001qv062221';  day=23;  sth=0;  acch=10; 
filt_len=50;  dx=1; dy=1;
%---
year='2018'; mon='06';  s_min='00';  
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];  outdir=['/mnt/e/figures/expri_test/',expri];
%  indir=['/mnt/HDD003/pwin/Experiments/expri_single/',expri]; outdir=['/mnt/e/figures/expri_single/',expri];
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='Filtered Accumulated Rainfall';   fignam=[expri,'_accum_'];
%
load('colormap/colormap_rain.mat')
cmap=colormap_rain; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[  1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];

%---
for ti=sth
  s_sth=num2str(ti,'%2.2d');
  for ai=acch
    s_edh=num2str(mod(ti+ai,24),'%2.2d'); 
    for j=1:2
      hr=(j-1)*ai+ti;  s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
      %------read netcdf data--------
      infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_min,':00'];
      rall{j} = ncread(infile,'RAINC');
      rall{j} = rall{j} + ncread(infile,'RAINSH');
      rall{j} = rall{j} + ncread(infile,'RAINNC');
    end %j=1:2
    rain=double(rall{2}-rall{1});
    rain(rain+1==1)=0;
    hgt = ncread(infile,'HGT');  
    rainfilt=low_pass_filter(rain,filt_len,dx,dy); 
    %
    %---plot--- 
    plotvar=rainfilt';
    pmin=(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
    %
    hf=figure('position',[100 45 800 680]);
    [c, hp]=contourf(plotvar,L2,'linestyle','none');
    if (max(max(hgt))~=0)
    hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    %
    set(gca,'fontsize',18,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={[expri,'  ',s_sth,s_min,'-',s_edh,s_min,' UTC'];[titnam,'  WL=',num2str(filt_len)]};
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

    outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(day),'_',s_sth,'_',num2str(ai),'h_L',num2str(filt_len)];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end

  end %acch
end %ti
