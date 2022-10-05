
% calculate cloud grid ratio and only plot 2D MDTE when cloud ratio larger than <hydlim>

% close all
clear;    ccc=':';

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

hydlim=10;    
%-----
rang=30;  cloudhyd=0.005;  grids=1;
%---
stday=22;   hrs=[22 23 24 25 26];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  
outdir='/mnt/e/figures/expri_twin/DTE_2D_for_paper';
titnam='MDTE'; 
%
fload=load('colormap/colormap_dte.mat');
cmap=fload.colormap_dte; cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%  L=[0.5 2 4 6 8 10 15 20 25 35];
 L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
%
nexp=size(expri1,1); 

%---plot
% for ei=2:nexp
for ei=9     
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
          cenx=centers_fin(maxcldid,2)-nx;        ceny=centers_fin(maxcldid,1)-ny; 
        else
          continue
        end
      else 
        continue
      end
  %---calculate distance from the center of the selected cloud area----------
      [yi, xi]=meshgrid(1:ny,1:nx);
      yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
      yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
      xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
      xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
      dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5;        
      
      cldgnum=length(find(hyd2D+1>cloudhyd+1 & dis2topo<=rang));   
      cldgptg=cldgnum/length(dis2topo(dis2topo<=rang))*100;  % Ratio of cloud grids in the specific range            
       
  %--- plot MDTE when cldgptg > hydlim---
      if cldgptg > hydlim
        
        [MDTE,~] = cal_DTE_2D(infile1,infile2) ; 
        %
        plotvar=MDTE';   
        pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
        %---
        hf=figure('position',[100 80 800 700]); 
        [~, hp]=contourf(plotvar,L2,'linestyle','none');    
        if (max(max(hgt))~=0)
         hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',3); 
        end
        hold on; contour(hyd2D',[0.005 0.005],'color',[0.1 0.1 0.1],'linewidth',3.5);     
        [c,hdis]=contour(dis2topo',[rang rang],'r','linewidth',2,'LabelSpacing',500);
%         clabel(c,hdis,rang,'fontsize',15)    
    
        set(gca,'fontsize',25,'LineWidth',2) 
        set(gca,'Xtick',0:100:300,'Xticklabel',0:100:300,'Ytick',0:50:300,'Yticklabel',0:50:300)
        set(gca,'xlim',[0 150],'ylim',[25 175])
         xlabel('(km)'); ylabel('(km)');
%       set(gca,'fontsize',18,'LineWidth',1.2)
%     set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    
        s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
        if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
        tit={expri1{ei},[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
        title(tit,'fontsize',20,'Interpreter','none')
    
        %---colorbar---
        fi=find(L>pmin,1);
        L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
        hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
        colormap(cmap); title(hc,'J kg^-^1','fontsize',14);  drawnow;
        hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
        for idx = 1 : numel(hFills)
          hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
        end
        %---
        fignam=[expri1{ei}(1:7),'_rang',num2str(rang),'_cldr',num2str(hydlim),'_'];
        outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min];
        print(hf,'-dpng',[outfile,'.png']) 
        system(['convert -trim ',outfile,'.png ',outfile,'.png']);     
        
        break          
      end  %if cldgptg > hydlim      
    end % tmi
    if cldgptg > hydlim;   break;    end   
  end %ti    
  disp([expri2{ei},' done'])
end %ei
