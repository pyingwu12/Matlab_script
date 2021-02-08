function cloud=cal_cloudarea_1time(indir,expri1,expri2,ym,s_date,s_hr,s_min,areasize,cloudhyd)

% Criteria of find cloud area:
%---input---
% areasize: only involve area whose grid number > areasize
% cloudhyd: find grids where vertical summation of hydrometeros > cloudhyd (Kg/Kg)
%---output---
% cloud.size:   Grid numbers of cloud area
% cloud.scale:  Diameter of circle with the same area
% cloud.maxzh:  Maximum Zh of control run over the cloud area
% cloud.maxdte: Mean of first X maximum moist DTE over the cloud area. X=areasize
%------------
% PY Wu @ 2020.11.25

ccc=':';
% topo_locx=375; topo_locy=400;  % center of topography
%---
year=ym(1:4); mon=ym(5:6);  infilenam='wrfout';  dom='01';   scheme='WSM6';

%---perturbed state---
infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
% zh_max1=cal_zh_cmpo(infile1,scheme); 
%---based state----  
infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00']; 
  qr = double(ncread(infile2,'QRAIN'));   
  qc = double(ncread(infile2,'QCLOUD'));
  qg = double(ncread(infile2,'QGRAUP'));  
  qs = double(ncread(infile2,'QSNOW'));
  qi = double(ncread(infile2,'QICE')); 
  hgt = ncread(infile2,'HGT'); 
%---
[nx ,ny]=size(hgt);  
hyd     = sum(qr+qc+qg+qs+qi,3);      % vertical sumation of hydrometeor
zh_max2 = cal_zh_cmpo(infile2,scheme);
moDTE   = cal_DTE_2D(infile1,infile2) ;
    
%---extend period boundary of domain---
%repzh1=repmat(zh_max1,3,3);
repzh2 =repmat(zh_max2,3,3);
rephyd =repmat(hyd,3,3);  
repMDTE=repmat(moDTE,3,3); 
  
%----definition of cloud area ---  
BW = rephyd > cloudhyd;  
%---find individual cloud---
CC = bwconncomp(BW,8);     
L = labelmatrix(CC);    
stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');

%---calculate parameters for each cloud area
if ~isempty(stats)  
  centers = stats.Centroid;
  fin=find(stats.Area>areasize & centers(:,1)>ny & centers(:,1)<2*ny+1 & centers(:,2)>nx & centers(:,2)<2*nx+1);  
                                                 %find area for calculating in center domain
  if ~isempty(fin)
    for i=1:size(fin,1) 
      cloud.size(i) = stats.Area(fin(i));            %grid numbers 
      cloud.scale(i)= (stats.Area(fin(i))/pi)^0.5*2; %Diameter of circle with the same area
      cloud.maxzh(i)= max(repzh2(L==fin(i)));
      cloud.maxdte(i) = mean( maxk(repMDTE(L==fin(i)),areasize)  ); % calculate mean of first X maximum value, X=areasize
      
      %%---calculate distance between center of mountain and cloud area----
%       disx=centers(fin(i),2)-topo_locx; disy=centers(fin(i),1)-topo_locy; 
%       if disx>150; disx=300-disx; end
%       if disy>150; disy=300-disy; end
%       cloud.todis(i)= sqrt(disx^2 + disy^2);
      %---calculate SCC of zh for each box of cloud area----
%       bounds=stats.BoundingBox;      
%       y1=floor(bounds(fin(i),1))+1; y2=floor(bounds(fin(i),1))+bounds(fin(i),3);
%       x1=floor(bounds(fin(i),2))+1; x2=floor(bounds(fin(i),2))+bounds(fin(i),4);
%       xyrange=bounds(fin(i),3)*bounds(fin(i),4);
%       [cloud.scc(i), ~, ~, ~]=cal_score(reshape(repzh1(x1:x2,y1:y2),xyrange,1),reshape(repzh2(x1:x2,y1:y2),xyrange,1),2); 
      %----
    end
  else
    cloud=[];  
  end % if ~isempty(fin)
else % if ~isempty(stats)  
  cloud=[];
end %if ~isempty(stats)  
    
