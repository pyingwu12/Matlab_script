function cloud=cal_cloudarea_1time_subdom(infile1,infile2,areasize,cloudtpw,ploterm,xsub1,xsub2,ysub1,ysub2)

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
% 2021/11/06: change cloud area criteria to TPW

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
  
  P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
  hyd  = qr+qc+qg+qs+qi;   
  dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
  tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
  TPW=squeeze(sum(tpw,3)./9.81);

%---
[nx ,ny]=size(hgt);  
% hyd2D     = sum(qr+qc+qg+qs+qi,3);      % vertical sumation of hydrometeor
zh_max2 = cal_zh_cmpo(infile2,scheme);

[DTE, P]=cal_DTEterms(infile1,infile2);
 dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
 dPall = P.f2(:,:,end)-P.f2(:,:,1);
 dPm = dP./repmat(dPall,1,1,size(dP,3)); 

 if strcmp(ploterm,'MDTE')==1
    DTE3D = DTE.KE + DTE.SH + DTE.LH ;
    DiffE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + DTE.Ps;
 elseif strcmp(ploterm,'CMDTE')==1
    DTE3D = DTE.KE3D + DTE.SH + DTE.LH ; 
    DiffE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + DTE.Ps;
 else
    eval(['DiffE2D = sum(dPm.*DTE.',ploterm,'(:,:,1:end-1),3);'])
 end
    
%---extend period boundary of domain---
%repzh1=repmat(zh_max1,3,3);
repzh2 =repmat(zh_max2,3,3);
% rephyd =repmat(hyd2D,3,3);  
repDTE=repmat(DiffE2D,3,3); 
repTPW =repmat(TPW,3,3);  
  
%----definition of cloud area ---  
% BW = rephyd > cloudhyd;  
BW = repTPW > cloudtpw;  
%---find individual cloud---
CC = bwconncomp(BW,8);     
L = labelmatrix(CC);    
stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');

%---calculate parameters for each cloud area
if ~isempty(stats)  
  centers = stats.Centroid;

%   fin=find(stats.Area>areasize & centers(:,1)>ny & centers(:,1)<2*ny+1 & centers(:,2)>nx & centers(:,2)<2*nx+1);  
    fin=find(stats.Area>areasize & centers(:,1)>=ny+ysub1 & centers(:,1)<=ny+ysub2 & centers(:,2)>=nx+xsub1 & centers(:,2)<=nx+xsub2+1);  

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
