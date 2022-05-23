% close all
clear;   ccc='-';
saveid=1; % save figure (1) or not (0)
%---setting
expri='TWIN003B';  day=23;  hr=8;  minu=10;   
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
% scheme='Gaddard'; %!!!!!!!!!!!!!!!
scheme='WSM6';
%---
% indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/temp1019'];
indir=['E:expri_twin/',expri];   outdir=['E:\figures',expri(1:7)];
%---
titnam='Zh composite';   fignam=[expri,'_zh_'];
%
load('colormap/colormap_zh.mat')
cmap=colormap_zh; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 3 6 10 15 20 25 30 35 40 45 50 55 60 65 70];

%  cmap=[  1.0000    1.0000    1.0000;
%          0.7000    0.9500    1.0000;
%          0.4800    0.8000    0.9500;
%          0.9800    0.9500    0.3000;
%          1.0000    0.6500    0.0500;
%          1.0000    0.2000    0.1000;
%          0.8500    0.1372         0;
%          0.9000    0.6000    0.9000];    
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[1 10 20 30 40 50 60];
%---

for ti=hr   
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu    
    s_min=num2str(mi,'%2.2d');
    %----infile------    
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    zh_max=cal_zh_cmpo(infile,scheme);         
    hgt = ncread(infile,'HGT');  
    %
%---plot----------
    plotvar=zh_max';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
%     hf=figure('position',[100 45 800 680]);  
    hf=figure('position',[100 45 800 670]); 
    [c, hp]=contourf(plotvar,L2,'linestyle','none');
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.25 0.25 0.25],'linestyle','--','linewidth',2.8); 
    end
    %
    set(gca,'fontsize',20,'LineWidth',1.5) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
%     tit={expri,[titnam,'  ',mon,s_date,'  ',s_hr,s_min,' UTC']}; 
%     title(tit,'fontsize',18,'Interpreter','none')
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit=[s_hrj,s_min,' LT']; 
    title(tit,'fontsize',28,'Interpreter','none')    
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',16,'LineWidth',1.5);
    colormap(cmap); title(hc,'dBZ','fontsize',16);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end    
    %---        
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])    
%      system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end
  end
end
