%------------------------------------------
% plot vertical weighted average moist DTE between two simulations
%------------------------------------------
close all
clear;  ccc=':';
%---
ctr_int=[25 75];
expri='TWIN003'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
% expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];  
s_date='23';  hr=2;  minu=[30];  

cloudhyd=0.005;

%
year='2018'; mon='06';  
infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin/';  
outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
titnam='MDTE';  %fignam=[expri1(8:end),'_rangecirle_MDTE-hyd5_',];
 fignam=[expri1(8:end),'_rangecirle-maxdte_',];

fload=load('colormap/colormap_dte.mat');
cmap=fload.colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
 L=[0.5 2 4 6 8 10 15 20 25 35];
%  L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
% L=[0.005 0.01 0.05 0.1 0.3 0.5 1 2 3 4 ];
 %
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');    
    %---infile 1---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     %
     hgt = double(ncread(infile2,'HGT'));   
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     hyd = sum(qr+qc+qg+qs+qi,3); 
      
  %---decide sub-domain to find max cloud area---
    if contains(expri1,'TWIN001')
       subx1=200; subx2=300; suby1=100; suby2=200;
    else    
       subx1=25; subx2=125; suby1=75; suby2=175;
    end      
      
  %---find max cloud area in the sub-domain and its center---
    [nx, ny]=size(hyd); 
    rephyd=repmat(hyd,3,3);      
    BW = rephyd > cloudhyd;  
    stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');     
    if isempty(stats)~=1
      centers = stats.Centroid;      
      fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1);     
      if isempty(stats.Area(fin))~=1    
        [maxcldsize, maxcldid]=max(stats.Area(fin));      
        centers_fin=centers(fin,:);      
        cenx=centers_fin(maxcldid,2)-nx;
        ceny=centers_fin(maxcldid,1)-ny; 
%           disp(nti)
      end
    end
    [MDTE,~] = cal_DTE_2D(infile1,infile2) ; 
    
    %--- if there is no any cloud area over the whole domain and the sub-domain, find max DTE----
    if isempty(stats)==1 || isempty(stats.Area(fin))==1  
%       [maxval, maxloc]=max(hyd(subx1+1:subx2,suby1+1:suby2));  [~, ceny0]=max(maxval);  cenx0=maxloc(ceny0);       
      [maxval, maxloc]=max(MDTE(subx1+1:subx2,suby1+1:suby2));  [~, ceny0]=max(maxval);  cenx0=maxloc(ceny0); 
      cenx=subx1+cenx0-1; 
      ceny=suby1+ceny0-1; 
%         disp(nti)
    end
  %---calculate distance from the center of the selected cloud area----------
      [yi, xi]=meshgrid(1:ny,1:nx);
      yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
      yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
      xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
      xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
      dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5; 
      

    %---plot---
    plotvar=MDTE';   
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
    %
%     hf=figure('position',[100 45 800 680]);  
    hf=figure('position',[100 75 800 700]); 
    [~, hp]=contourf(plotvar,L2,'linestyle','none');    
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8); 
    end
    
      hold on; contour(hyd',[0.005 0.005],'color',[0.1 0.1 0.1],'linewidth',2.5);     
    
    [c,hdis]=contour(dis2topo',ctr_int,'r','linewidth',3,'LabelSpacing',500);
    clabel(c,hdis,ctr_int,'fontsize',15)    
    
    %
    set(gca,'fontsize',16,'LineWidth',1.2)
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---colorbar---
    fi=find(L>pmin,1);
    L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
    colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
    colormap(cmap);     drawnow;
    hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
    for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
    end
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
    

  end %tmi
end
