% function zh_2D_twin(expri,s_date,hr,minu)
close all
clear;   
ccc=':';
%---setting
expri='TWIN020';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
s_date='22'; hr=23;  minu=[0]; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
% scheme='Gaddard'; %!!!!!!!!!!!!!!!
scheme='WSM6';
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%---
titnam='Zh composite';   fignam=[expri1(8:end),'_zh-twin_'];
%
load('colormap/colormap_zh.mat')
cmap=colormap_zh; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 3 6 10 15 20 25 30 35 40 45 50 55 60 65 70];
%---
%
for ti=hr   
  for mi=minu    
    %ti=hr; mi=minu;
    %---set filename---
    s_hr=num2str(ti,'%2.2d');  % start time string
    s_min=num2str(mi,'%2.2d');
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    zh_max1=cal_zh_cmpo(infile1,scheme);         
    hgt = ncread(infile1,'HGT');  
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    zh_max2=cal_zh_cmpo(infile2,scheme);   
    %
%---plot----------
    plotvar=zh_max2';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
%     hf=figure('position',[100 45 800 680]);  
    hf=figure('position',[100 45 800 700]); 
    [c, hp]=contourf(plotvar,L2,'linestyle','none');
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.5 0.5 0.5],'linestyle','--','linewidth',2.5); 
    end
    hold on
    contour(zh_max1',[25 25],'color',[0.1 0.1 0.1],'linestyle','-','linewidth',3)
    %
    set(gca,'fontsize',18,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
%     tit={expri1,[titnam,'  ',mon,s_date,'  ',s_hr,s_min,' UTC']}; 
%     title(tit,'fontsize',18,'Interpreter','none')

    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST']}; 
    title(tit,'fontsize',20,'Interpreter','none')

    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
    colormap(cmap); title(hc,'dBZ','fontsize',14);  drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end    
    %---    
    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%    
  end
end
