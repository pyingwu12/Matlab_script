% calculate slope of DTE over time between cloud grids between 0.1% and 5%
% P.Y. Wu @ 2021.03.31

close all; clear;  ccc=':';


expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'
        };

expri2={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'
        };  
    
hydlim1=0.1;   s_hydlim1='01';
hydlim2=5;     s_hydlim2='5';
%-----
outdir='/mnt/e/figures/expri_twin';
load('colormap/colormap_hot20.mat')
cmap=colormap_hot20([1 2 4 6 8 10 12 13 17 20],:);

%---
rang=25;  cloudhyd=0.005;
%---
stday=22;   hrs=[22 23 24 25 26];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; 
%
nexp=size(expri1,1); 

%---plot
p1=zeros(nexp,1);
for ei=1:nexp  
  nti=0;  ntii=0;  cldgptg=0;
  for ti=hrs       
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');    
    for tmi=minu
      clear DTE DTE2D cenx ceny
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      hgt = ncread(infile2,'HGT');
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D = sum(qr+qc+qg+qs+qi,3); 
      
  %---decide sub-domain to find max cloud area---
      if contains(expri1{ei},'TWIN001')
         subx1=200; subx2=300; suby1=100; suby2=200;
      else    
          subx1=25; subx2=125; suby1=75; suby2=175;
      end
      
  %---find max cloud area in the sub-domain and its center---
      [nx, ny]=size(hyd2D); 
      rephyd=repmat(hyd2D,3,3);      
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
        else
          continue
        end
      else 
        continue
      end
%        disp([s_hr,s_min])
  %---calculate distance from the center of the selected cloud area----------
      [yi, xi]=meshgrid(1:ny,1:nx);
      yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
      yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
      xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
      xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
      dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5;        
      
      cldgnum=length(find(hyd2D+1>cloudhyd+1 & dis2topo<=rang));   
      cldgptg=cldgnum/length(dis2topo(dis2topo<=rang))*100;  % Ratio of cloud grids in the specific range            

      
      if cldgptg>0.1 && p1(ei)==0   
         disp(['p1 time: ',s_hr,s_min])         
         p1(ei)=nti;         
         [DTE2D]=cal_DTEterms_2D(infile1,infile2);
           MDTE_m(ei,1)=double(mean(DTE2D.MDTE(dis2topo<=rang)));           
           CMDTE_m(ei,1)=double(mean(DTE2D.CMDTE(dis2topo<=rang)));                  
           DiKE_m(ei,1)=double(mean(DTE2D.KE(dis2topo<=rang)));             
           DiKE3D_m(ei,1)=double(mean(DTE2D.KE3D(dis2topo<=rang)));            
           DiSH_m(ei,1)=double(mean(DTE2D.SH(dis2topo<=rang)));        
           DiLH_m(ei,1)=double(mean(DTE2D.LH(dis2topo<=rang)));  
      end 
         
      if cldgptg > hydlim2
         disp(['p2 time: ',s_hr,s_min])
         p2(ei)=nti;         
         [DTE2D]=cal_DTEterms_2D(infile1,infile2);
           MDTE_m(ei,2)=double(mean(DTE2D.MDTE(dis2topo<=rang)));           
           CMDTE_m(ei,2)=double(mean(DTE2D.CMDTE(dis2topo<=rang)));                  
           DiKE_m(ei,2)=double(mean(DTE2D.KE(dis2topo<=rang)));             
           DiKE3D_m(ei,2)=double(mean(DTE2D.KE3D(dis2topo<=rang)));            
           DiSH_m(ei,2)=double(mean(DTE2D.SH(dis2topo<=rang)));        
           DiLH_m(ei,2)=double(mean(DTE2D.LH(dis2topo<=rang)));         
        break          
      end
      
    end % tmi
    if cldgptg > hydlim2;   break;    end   
  end %ti    
  disp([expri2{ei},' done'])
end %ei
%%

ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH'};

for pi=1:size(ploterms,1)
%  for pi=1
  ploterm=ploterms{pi}; 
  %
  eval(['DiffE_m=',ploterm,'_m;'])
  slope_FLAT= (log10(DiffE_m(1,2)) - log10(DiffE_m(1,1)) )/ (p2(1)-p1(1));
  n=1;
  for h=1:4
    for v=1:3
      n=n+1;      
      slope(h,v)=(log10(DiffE_m(n,2)) - log10(DiffE_m(n,1)) )/ (p2(n)-p1(n)) ;
    end
  end
  plotvar=slope./slope_FLAT*100;
  
  %----------
  hf=figure('Position',[100 300 650 600]);
  imagesc(plotvar)
  hc=colorbar('linewidth',1.5,'fontsize',16,'Ytick',10:10:90);
  colormap(cmap);  caxis([0 100])
  title(hc,'%','fontsize',20)
  %---text--
  for h=1:size(slope,1)
    for v=1:size(slope,2)
      if plotvar(h,v)>50; textcol='k';  else;  textcol='w'; end       
      text(v,h,num2str(slope(h,v),'%.4f'),'HorizontalAlignment','center','color',textcol,'fontsize',20,'FontWeight','bold')
    end
  end
  %  
  set(gca,'linewidth',2,'fontsize',20)
  set(gca,'xtick',[1 2 3],'xticklabel',{'V05','V10','V20'},'ytick',[1 2 3 4],'yticklabel',{'H05','H075','H10','H20'})
  title(ploterm,'fontsize',25)

  fignam=[ploterm,'_slop_all'];  
  outfile=[outdir,'/',fignam];
  print(hf,'-dpng',[outfile,'.png'])
%   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  
  
end  
