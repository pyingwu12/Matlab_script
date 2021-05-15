% close all
clear;   ccc=':';
%---setting
expri='TWIN003';   %TWIN003Pr001qv062221noMP
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
s_date='23'; hr=3; minu=40; 
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
scheme='WSM6';
%---
indir='/mnt/HDD008/pwin/Experiments/expri_twin'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
% indir=['e:/wrfout/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='Zh composite';   fignam=[expri1,'_zh_'];
%
%---
load('colormap/colormap_dte.mat')
cmap=colormap_dte; Lmap=[0.5 1 1.5 2 3 5 10 15 20 30];
clen=length(cmap);
%
topo_locx=375; topo_locy=400;
g=9.81;

thresh_areasize=4;

for ti=hr   
  for mi=minu    
    %ti=hr; mi=minu;
    %---set filename---
    s_hr=num2str(ti,'%2.2d');  % start time string
    s_min=num2str(mi,'%2.2d');
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      zh_max1=cal_zh_cmpo(infile1,scheme); 
    %-------  
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
 
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE'));
%      W = ncread(infile2,'W'); 
%      ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');
     
     hgt = ncread(infile2,'HGT'); 
     
%      [nx, ny]=size(hgt);     
%     PH=double(phb+ph);  zg=double(PH)/g; 
%     for i=1:nx        
%       for j=1:ny         
%         W2(i,j)=interp1(squeeze(zg(i,j,:)),squeeze(W(i,j,:)),2000,'linear');  
%       end       
%     end       
    
    hyd=sum(qr+qc+qg+qs+qi,3);
    zh_max2=cal_zh_cmpo(infile2,scheme);
    
    MDTE = cal_DTE_2D(infile1,infile2) ; 
               
    repzh1=repmat(zh_max1,3,3);
    repzh2=repmat(zh_max2,3,3);
%     repw2=repmat(W2,3,3);
    rephyd=repmat(hyd,3,3);  
    repMDTE=repmat(MDTE,3,3);
    %-------------

%     BW=rephyd>0.02 & abs(repw2)>0.3 ;
    BW=rephyd>0.02;
%     BW=repzh2>40;
    
    %
    CC = bwconncomp(BW,8);    
    L = labelmatrix(CC);    
    stats = regionprops('table',BW,'BoundingBox','Area','Centroid',...
    'MajorAxisLength','MinorAxisLength','PixelList');
    
    centers = stats.Centroid;
    bounds=stats.BoundingBox;
    fin=find(stats.Area>thresh_areasize & centers(:,1)>300 & centers(:,1)<601 & centers(:,2)>300 & centers(:,2)<601);
   
   
    for i=1:size(fin,1)        
      conv.size(i) = stats.Area(fin(i)) ;
      conv.mdte(i) = mean(repMDTE(L==fin(i)));       
      conv.maxzh(i)= max(repzh2(L==fin(i)));
      conv.maxdte(i) = mean(   maxk(repMDTE(L==fin(i)),thresh_areasize)    ); 
      
      disx=centers(fin(i),2)-topo_locx; disy=centers(fin(i),1)-topo_locy; 
      if disx>150; disx=300-disx; end
      if disy>150; disy=300-disy; end
      conv.todis(i)= sqrt(disx^2 + disy^2);
      
      y1=floor(bounds(fin(i),1))+1; y2=floor(bounds(fin(i),1))+bounds(fin(i),3);
      x1=floor(bounds(fin(i),2))+1; x2=floor(bounds(fin(i),2))+bounds(fin(i),4);
      xyrange=bounds(fin(i),3)*bounds(fin(i),4);
      [conv.scc(i), ~, ~, ~]=cal_score(reshape(repzh1(x1:x2,y1:y2),xyrange,1),reshape(repzh2(x1:x2,y1:y2),xyrange,1),2);
%       [conv.scc(i), ~, ~, ~]=cal_score(calrangezh1(L==fin(i)),calrangezh2(L==fin(i)),2);
    end
%}
    
    
%     A=L~=0; figure('Position',[100 65 800 600]); contour(A',[1 1])
%     diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
%     radii = diameters/2;
%     viscircles([centers(fin,2),centers(fin,1)],radii(fin));
%     for i2=1:size(fin,1)        
%     aaax=centers(fin(i2),2);
%     aaay=centers(fin(i2),1);
%     text(aaax,aaay+0.5,num2str(conv.scc(i2)))
%     end

% for i=1:length(fin)
% rectangle('Position',[bounds(fin(i),2) bounds(fin(i),1) bounds(fin(i),4) bounds(fin(i),3)])
% end
    
%     figure('Position',[100 65 800 600])
%     plot(conv.size,conv.scc,'ro')
%    plot(conv.todis,conv.scc,'ro')
%%
%{
plotvar=conv.maxdte;
 figure('Position',[100 65 800 600])
Msize=9;
 for i=1:size(fin,1)
     
    for k=1:clen-2
      if (plotvar(i) > Lmap(k) && conv.scc(i)<=Lmap(k+1))
        c=cmap(k+1,:);
        hp=plot(conv.size(i),conv.maxzh(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
        set(hp,'linestyle','none');    
      end      
    end
    if plotvar(i)>Lmap(clen-1)
      c=cmap(clen,:);
      hp=plot(conv.size(i),conv.maxzh(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
      set(hp,'linestyle','none');   
    end
    if plotvar(i)<Lmap(1)
      c=cmap(1,:);
      hp=plot(conv.size(i),conv.maxzh(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
      set(hp,'linestyle','none');   
    end   
 end
 
  colormap(cmap); 
L1=((1:length(Lmap))*(1/(length(Lmap)+1)))+0;
    hc=colorbar('YTick',L1,'YTickLabel',Lmap,'fontsize',13,'LineWidth',1.2);
    
   set(gca,'Xscale','log')

%}
%%
%{
Lmap=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
   plotvar=conv.scc;
   figure('Position',[100 65 800 600])
   Msize=9;
   for i=1:size(fin,1)
     
    for k=1:clen-2
      if (plotvar(i) > Lmap(k) && conv.scc(i)<=Lmap(k+1))
        c=cmap(k+1,:);
        hp=plot(conv.size(i),conv.maxzh(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
        set(hp,'linestyle','none');    
      end      
    end
    if plotvar(i)>Lmap(clen-1)
      c=cmap(clen,:);
      hp=plot(conv.size(i),conv.maxzh(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
      set(hp,'linestyle','none');   
    end
    if plotvar(i)<Lmap(1)
      c=cmap(1,:);
      hp=plot(conv.size(i),conv.maxzh(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
      set(hp,'linestyle','none');   
    end   
   end
 
    colormap(cmap); 
   L1=((1:length(Lmap))*(1/(length(Lmap)+1)))+0;
    hc=colorbar('YTick',L1,'YTickLabel',Lmap,'fontsize',13,'LineWidth',1.2);
    
   set(gca,'Xscale','log')

%}

  end
end
%


   


    
