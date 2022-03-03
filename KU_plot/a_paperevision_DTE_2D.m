% function DTE_2D_twin(expri)
%------------------------------------------
% plot vertical weighted average moist DTE between two simulations
%------------------------------------------
% close all
clear; ccc=':';
saveid=1;
%---
expri='TWIN003'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
s_date='23';  hr=0;  minu=50;  
%
year='2018'; mon='06';  
infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin/';  
% outdir=['/mnt/e/figures/expri_twin/',expri1(1:7),'/SOLA2021_revision'];
outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='CMDTE';  fignam=[expri1(8:end),'_CMDTE-cld_',];

fload=load('colormap/colormap_dte.mat');
cmap=fload.colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
 L=[0.5 2 4 6 8 10 15 20 25 35];
%  L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];

cloudtpw=0.7;
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
    hgt_extend=repmat(hgt,3,3);
    %
    
    qr = double(ncread(infile2,'QRAIN'));   
    qc = double(ncread(infile2,'QCLOUD'));
    qg = double(ncread(infile2,'QGRAUP'));  
    qs = double(ncread(infile2,'QSNOW'));
    qi = double(ncread(infile2,'QICE')); 
%     hyd = sum(qr+qc+qg+qs+qi,3);  
    
    P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
    hyd  = qr+qc+qg+qs+qi;   
    dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
    tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
    TPW=squeeze(sum(tpw,3)./9.81);

    repTPW =repmat(TPW,3,3);      
    
%     BW = hyd_extend > cloudhyd;  
    BW = repTPW > cloudtpw;  
    CC = bwconncomp(BW,8);    
    LL = labelmatrix(CC);    
    stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');
  
    centers = stats.Centroid;
    bounds=stats.BoundingBox;
%     fin=find(stats.Area>areasize & centers(:,1)>ny & centers(:,1)<2*ny+1 & centers(:,2)>nx & centers(:,2)<2*nx+1);  
    fin=find(stats.Area>areasize );      

    [~, CMDTE] = cal_DTE_2D(infile1,infile2) ;        % vertical weighted average (dPm=dP/dPall)      
     DTE_extend=repmat(CMDTE,3,3);


    %---plot---
    plotvar=DTE_extend';   
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
%     hf=figure('position',[100 45 800 680]);  
    hf=figure('position',[100 75 790 710]); 
    [~, hp]=contourf(plotvar,L2,'linestyle','none');    
    if (max(max(hgt))~=0)
     hold on; contour(hgt_extend',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',2.3); 
    end
    
      hold on; contour(repTPW',[cloudtpw cloudtpw],'color','k','linewidth',3.8);  

%     for i=1:length(fin)
%         hrec=rectangle('Position',[bounds(fin(i),2) bounds(fin(i),1) bounds(fin(i),4) bounds(fin(i),3)]);
%     set(hrec,'linewidth',2,'EdgeColor',[0.9 0.05 0.2])    
%     end
    
    set(gca,'fontsize',20,'LineWidth',2) 
    set(gca,'Xlim',[301 600],'Ylim',[301 600])
    set(gca,'Xtick',350:50:550,'Xticklabel',50:50:250,'Ytick',350:50:550,'Yticklabel',50:50:250)
    xlabel('(km)'); ylabel('(km)');
    
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap); %title(hc,'J Kg^-^1','fontsize',13);  drawnow;
    drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
    end
  end %tmi
end
