function cloud=cal_cloudarea_1time(infile1,infile2,areasize,cloudhyd,ploterm)

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
% 2021/02/10: modified the input from <expri1 and expri2> to <infile1 an infile2>
% 2021/02/11: add <ploterm> option for calculating different terms in the DTE

topo_locx=75; topo_locy=100;  % center of topography
%---
scheme='WSM6';

%---perturbed state---
% zh_max1=cal_zh_cmpo(infile1,scheme); 
%---based state----  
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

[KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2);
 dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
 dPall = P.f2(:,:,end)-P.f2(:,:,1);
 dPm = dP./repmat(dPall,1,1,size(dP,3)); 

 if strcmp(ploterm,'MDTE')==1
    DTE3D = KE + ThE + LH ;
    DiffE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + Ps;
 else
    eval(['DiffE2D = sum(dPm.*',ploterm,'(:,:,1:end-1),3);'])
 end
    
%---extend period boundary of domain---
%repzh1=repmat(zh_max1,3,3);
repzh2 =repmat(zh_max2,3,3);
rephyd =repmat(hyd,3,3);  
repDTE=repmat(DiffE2D,3,3); 
  
%----definition of cloud area ---  
BW = rephyd > cloudhyd;  
%---find individual cloud---
CC = bwconncomp(BW,8);     
L = labelmatrix(CC);    
stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');

%---calculate parameters for each cloud area
if ~isempty(stats)  
  centers = stats.Centroid;
%   fin=find(stats.Area>areasize & centers(:,1)>ny+50 & centers(:,1)<=ny+50+300 & centers(:,2)>nx+75 & centers(:,2)<=nx+75+300);  
  fin=find(stats.Area>areasize & centers(:,1)>ny & centers(:,1)<2*ny+1 & centers(:,2)>nx & centers(:,2)<2*nx+1);  
                                                 %find area for calculating in center domain
  if ~isempty(fin)
    for i=1:size(fin,1) 
      cloud.size(i) = stats.Area(fin(i));            %grid numbers 
      cloud.scale(i)= (stats.Area(fin(i))/pi)^0.5*2; %Diameter of circle with the same area
      cloud.maxzh(i)= max(repzh2(L==fin(i)));
      cloud.maxdte(i) = mean( maxk(repDTE(L==fin(i)),areasize)  ); % calculate mean of first X maximum value, X=areasize
      cloud.meandte(i) = mean(repDTE(L==fin(i)));
      
      %%---calculate distance between center of mountain and cloud area----
      disx=centers(fin(i),2)-(topo_locx+nx); disy=centers(fin(i),1)-(topo_locy+ny); 
      if disx>150; disx=300-disx; end
      if disy>150; disy=300-disy; end
      cloud.todis(i)= sqrt(disx^2 + disy^2);
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
    
