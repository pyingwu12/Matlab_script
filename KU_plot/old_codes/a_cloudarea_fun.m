function cloud=Diff_of_each_cloudarea(indir,expri1,expri2,stday,hrs,s_min,areasize,cloudhyd)

% close all
% clear; 
ccc=':';
%---setting
% expri='TWIN003';   expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
% stday=23;   hrs=0:6;  
% s_min='50'; 
%
topo_locx=375; topo_locy=400;  % center of topography
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';   scheme='WSM6';
% indir='/mnt/HDD008/pwin/Experiments/expri_twin'; outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
%---
%
% areasize=4; %threshold of finding cloud area
% cloudhyd=0.02; %threshold of definition of cloud area (Kg/Kg)

ntii=0;
for ti=1:length(hrs)
  hr=hrs(ti);
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  %
  %---perturbed state---
  infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    zh_max1=cal_zh_cmpo(infile1,scheme); 
  %---based state----  
  infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00']; 
    qr = double(ncread(infile2,'QRAIN'));   
    qc = double(ncread(infile2,'QCLOUD'));
    qg = double(ncread(infile2,'QGRAUP'));  
    qs = double(ncread(infile2,'QSNOW'));
    qi = double(ncread(infile2,'QICE')); 
    hgt = ncread(infile2,'HGT'); 
    [nx ,ny]=size(hgt);
    
    zh_max2 = cal_zh_cmpo(infile2,scheme);
    hyd = sum(qr+qc+qg+qs+qi,3);      % vertical sumation of hydrometeor
    MDTEmo = cal_DTEmo_2D(infile1,infile2) ;
    
  %---extend period boundary of domain---
  repzh1=repmat(zh_max1,3,3);
  repzh2=repmat(zh_max2,3,3);
  rephyd=repmat(hyd,3,3);  
  repMDTE=repmat(MDTEmo,3,3); 
  
  %----definition of cloud area   
  BW = rephyd > cloudhyd;  
  %---
  CC = bwconncomp(BW,8);    
  L = labelmatrix(CC);    
  stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');
  
  if ~isempty(stats)  
  centers = stats.Centroid;
  bounds=stats.BoundingBox;
  fin=find(stats.Area>areasize & centers(:,1)>ny & centers(:,1)<2*ny+1 & centers(:,2)>nx & centers(:,2)<2*nx+1);  
  %find area for calculating in center domain

  for i=1:size(fin,1) 
    ntii=ntii+1;
    cloud.size(ntii) = stats.Area(fin(i)) ;
    cloud.mdte(ntii) = mean(repMDTE(L==fin(i)));       
    cloud.maxzh(ntii)= max(repzh2(L==fin(i)));
    cloud.maxdte(ntii) = mean( maxk(repMDTE(L==fin(i)),areasize)  ); 
      
    disx=centers(fin(i),2)-topo_locx; disy=centers(fin(i),1)-topo_locy; 
    if disx>150; disx=300-disx; end
    if disy>150; disy=300-disy; end
    cloud.todis(ntii)= sqrt(disx^2 + disy^2);
      
    y1=floor(bounds(fin(i),1))+1; y2=floor(bounds(fin(i),1))+bounds(fin(i),3);
    x1=floor(bounds(fin(i),2))+1; x2=floor(bounds(fin(i),2))+bounds(fin(i),4);
    xyrange=bounds(fin(i),3)*bounds(fin(i),4);
    [cloud.scc(ntii), ~, ~, ~]=cal_score(reshape(repzh1(x1:x2,y1:y2),xyrange,1),reshape(repzh2(x1:x2,y1:y2),xyrange,1),2);
    cloud.hr(ntii) = hrs(ti);
  end

  end %if
    
end %time