function [corr]=corr_cal_mvp(hr,minu,expri,v1nam,v2nam,px,py,memsize,infilenam,dirnam)
%------
% This is a function for calculate vertical error Corr. of model at the point: (px,py)
% function name:         ^^^       ^                       ^            ^
% The output corr(i,:) is the corr. between v1's i-th point and all v2's points
%
%---input example---
%clear;   hr=2;    minu='00';   expri='e02';       v1nam='WS';  v2nam='WS';
%px=137;  py=118;  memsize=40;  infilenam='fcst';  dirnam='cycle';
%
%--------------------------
%---experimental setting---
global dom year mon date indir nz
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];    
%---   
%g=9.81;
px=px-1; py=py-1;
%
s_hr=num2str(hr,'%2.2d');  
%---member
for mi=1:memsize;
% ---filename----
   nen=num2str(mi,'%.3d'); 
   infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   ncid = netcdf.open(infile,'NC_NOWRITE'); 
   if mi==1;    
     varid=netcdf.inqDimID(ncid,'bottom_top');  [~, nz]=netcdf.inqDim(ncid,varid);
     v1en=zeros(nz,memsize);  v2en=zeros(nz,memsize);
   end   
%---variable 1
   if     strcmp(v1nam,'WS')==1;
     varid=netcdf.inqVarID(ncid,'U');     ustag =netcdf.getVar(ncid,varid,[px py 0 0],[2 1 nz 1],'double');   
     varid=netcdf.inqVarID(ncid,'V');     vstag =netcdf.getVar(ncid,varid,[px py 0 0],[1 2 nz 1],'double');
     u=(ustag(1,:,:)+ustag(2,:,:)).*0.5;  v=(vstag(:,1,:)+vstag(:,2,:)).*0.5;
     v1en(:,mi)=(u.^2+v.^2).^0.5;
   elseif strcmp(v1nam,'W')==1; 
     varid=netcdf.inqVarID(ncid,'W');     wstag =netcdf.getVar(ncid,varid,[px py 0 0],[1 1 nz+1 1],'double'); 
     v1en(:,mi)=(wstag(1,1,1:nz)+wstag(1,1,2:nz+1)).*0.5;
   else
     varid=netcdf.inqVarID(ncid,v1nam);   v1 =netcdf.getVar(ncid,varid,[px py 0 0],[2 2 nz 1],'double');  
     if     strcmp(v1nam(1),'Q')==1;  v1en(:,mi)=v1(1,1,:);        
     elseif strcmp(v1nam,'U')==1;     v1en(:,mi)=(v1(1,1,:)+v1(2,1,:)).*0.5;
     elseif strcmp(v1nam,'V')==1;     v1en(:,mi)=(v1(1,1,:)+v1(1,2,:)).*0.5; 
     else   error('Error: Wrong model varible setting of <v1nam>'); 
     end       
   end    
%---variable 2
   if     strcmp(v2nam,'WS')==1;
     varid=netcdf.inqVarID(ncid,'U');     ustag =netcdf.getVar(ncid,varid,[px py 0 0],[2 1 nz 1],'double');   
     varid=netcdf.inqVarID(ncid,'V');     vstag =netcdf.getVar(ncid,varid,[px py 0 0],[1 2 nz 1],'double');
     u=(ustag(1,:,:)+ustag(2,:,:)).*0.5;  v=(vstag(:,1,:)+vstag(:,2,:)).*0.5;
     v2en(:,mi)=(u.^2+v.^2).^0.5;
   elseif strcmp(v2nam,'W')==1; 
     varid=netcdf.inqVarID(ncid,'W');     wstag =netcdf.getVar(ncid,varid,[px py 0 0],[1 1 nz+1 1],'double'); 
     v2en(:,mi)=(wstag(1,1,1:nz)+wstag(1,1,2:nz+1)).*0.5;
   else
     varid=netcdf.inqVarID(ncid,v2nam);     v1 =netcdf.getVar(ncid,varid,[px py 0 0],[2 2 nz 1],'double');  
     if     strcmp(v2nam(1),'Q')==1;  v2en(:,mi)=v1(1,1,:);        
     elseif strcmp(v2nam,'U')==1;     v2en(:,mi)=(v1(1,1,:)+v1(2,1,:)).*0.5;
     elseif strcmp(v2nam,'V')==1;     v2en(:,mi)=(v1(1,1,:)+v1(1,2,:)).*0.5; 
     else   error('Error: Wrong model varible setting of <v1nam>'); 
     end       
   end  
      netcdf.close(ncid);
end   %member   
%-----calculate correlation------------
A=v1en;                    B=v2en;
at=mean(A,2);              bt=mean(B,2);
At=repmat(at,1,memsize);   Bt=repmat(bt,1,memsize);
Ae=A-At;                   Be=B-Bt;   
%---variance---    
% !!notice: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean here
varae=sum(Ae.^2,2)./(memsize-1);    varbe=sum(Be.^2,2)./(memsize-1); 
varaeall=(varae.^0.5)*(varbe'.^0.5);
%---covariance   
cov=(Ae*Be')./(memsize-1); 
%---correlation--- 
corr=cov./(varaeall);

