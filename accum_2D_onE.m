% close all
clear
%---setting
expri='TWIN003B';  stday=23;  sth=0;  acch=1; 
%---
year='2018'; mon='06';  s_minu='20';  
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];  outdir=['/mnt/e/figures/expri_test/',expri];
%  indir=['/mnt/HDD003/pwin/Experiments/expri_single/',expri]; outdir=['/mnt/e/figures/expri_single/',expri];
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='Accumulated Rainfall';   fignam=[expri,'_accum_'];
%
load('colormap/colormap_rain.mat')
cmap=colormap_rain; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[  0.1   2   4   6  10  15  20  25  30  40  50  60  70  80 100 120];

%---
for ti=sth
  s_sth=num2str(ti,'%2.2d');
  for ai=acch
    s_edh=num2str(mod(ti+ai,24),'%2.2d'); 
    for j=1:2
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;
      s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');
      %------read netcdf data--------
      infile = [indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',s_minu,':00'];
      rall{j} = ncread(infile,'RAINC');
      rall{j} = rall{j} + ncread(infile,'RAINSH');
      rall{j} = rall{j} + ncread(infile,'RAINNC');
%       rc{j} = ncread(infile,'RAINC');
%       rsh{j} = ncread(infile,'RAINSH');
%       rnc{j} = ncread(infile,'RAINNC');
    end %j=1:2
    rain=double(rall{2}-rall{1});
%     rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
    rain(rain+1==1)=NaN;
    hgt = ncread(infile,'HGT');  
    %
    %---plot--- 
    plotvar=rain';
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
    tit={expri;[titnam,'  ',s_sth,s_minu,'-',s_edh,s_minu,' UTC']};
    title(tit,'fontsize',18)

    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap);  title(hc,'mm','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---

    outfile=[outdir,'/',fignam,'d',dom,'_',mon,num2str(stday),'_',s_sth,s_minu,'_',num2str(ai),'h'];
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);

  end %acch
end %ti