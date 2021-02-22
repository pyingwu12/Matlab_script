%------------------------------------------
% calculate vertical weighted average difference total engergy (DTE) of two experiments
%------------------------------------------
close all
clear;  ccc=':';
%---
expri='TWIN003';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='23';  hr=0;  minu=[10 20 30 40 50]; 
zhid=100; % for zhid~=0, plot contour of zh composite; %
%for zhid=100, plot hydrometeor=criteria
%
year='2018'; mon='06';  
dirmem='pert'; infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='moist DTE';  fignam=[expri1(8:end),'_moDTEcloud_',];
if zhid~=0; fignam=[fignam,'zh_'];  end
%
load('colormap/colormap_dte.mat')
cmap=colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=0.001*[0.1 0.5 1 1.5 2 2.5 3 3.5 4 4.5];
% L=[0.001 0.003 0.005 0.007 0.009 0.01 0.02 0.03 0.04 0.05];
L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
%   L=[0.5 2 4 6 8 10 15 20 25 30];
%
cloudhyd=0.005;
areasize=10;

for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile2,'HGT');
    %
    zh_max=cal_zh_cmpo(infile2,'WSM6');  % zh of perturbed state    
    MDTE = cal_DTE_2D(infile1,infile2) ;  % vertical weighted average (dPm=dP/dPall)      
    
    [nx ,ny]=size(hgt);
    repzh1=repmat(zh_max,3,3);
    qr = double(ncread(infile2,'QRAIN'));   
    qc = double(ncread(infile2,'QCLOUD'));
    qg = double(ncread(infile2,'QGRAUP'));  
    qs = double(ncread(infile2,'QSNOW'));
    qi = double(ncread(infile2,'QICE')); 
    hyd = sum(qr+qc+qg+qs+qi,3); 
    rephyd=repmat(hyd,3,3);  
    
    BW = rephyd > cloudhyd;  
    CC = bwconncomp(BW,8);    
    LL = labelmatrix(CC);    
    stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');
  
    centers = stats.Centroid;
    bounds=stats.BoundingBox;
%     fin=find(stats.Area>areasize & centers(:,1)>ny & centers(:,1)<2*ny+1 & centers(:,2)>nx & centers(:,2)<2*nx+1);  
    fin=find(stats.Area>areasize );  

    
    %%
    %---plot---
    plotvar=repmat(MDTE',3,3);   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
%     hf=figure('position',[100 45 800 680]);  
    hf=figure('position',[100 45 800 700]); 
    [c, hp]=contourf(plotvar,L2,'linestyle','none');    
    if (max(max(hgt))~=0)
     hold on; contour(repmat(hgt',3,3),[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    if zhid==100
      hold on; contour(rephyd',[cloudhyd cloudhyd],'color',[0.1 0.1 0.1],'linewidth',2.2); 
    elseif zhid~=0 
      hold on; contour(zh_max',[zhid zhid],'color',[0.1 0.1 0.1],'linewidth',2.2); 
    end   

    hold on
    for i=1:length(fin)
%     hrec=rectangle('Position',[bounds(fin(i),2)-nx bounds(fin(i),1)-ny bounds(fin(i),4) bounds(fin(i),3)]);
        hrec=rectangle('Position',[bounds(fin(i),2) bounds(fin(i),1) bounds(fin(i),4) bounds(fin(i),3)]);
    set(hrec,'linewidth',1.3,'EdgeColor',[0.9 0.05 0.2])    
    end
    
    %
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'xlim',[nx+1 nx+nx],'ylim',[ny+1 ny+ny]) 
    set(gca,'Xtick',nx+50:50:nx+nx,'Xticklabel',50:50:nx,'Ytick',ny+50:50:ny+ny,'Yticklabel',50:50:ny)

    xlabel('(km)'); ylabel('(km)');
    %s_hrj=num2str(mod(ti+9,24),'%2.2d'); 
%     tit={[expri1,'  ',s_hr,s_min,' UTC'],titnam};     
%     title(tit,'fontsize',18)
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST']}; 
    title(tit,'fontsize',20,'Interpreter','none')

    %---colorbar---
    fi=find(L>pmin);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap);     drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi(1)-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
  end %tmi
end