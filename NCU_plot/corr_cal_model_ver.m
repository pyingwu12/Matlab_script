function R=corr_cal_model_ver(hr,minu,expri,infilenam,dirnam,px,py,memsize)

%clear; 
%hr=2;   minu='00';   expri='e02';   infilenam='fcst';  
%dirnam='cycle';  px=137;  py=118;   memsize=40; 
                 %px=137;  py=118; %px=115;  py=90;

%---experimental setting---
global dom year mon date indir nz
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; 
%---
px0=px-1; py0=py-1;

%---set time and filename---    
s_hr=num2str(hr,'%2.2d');  
%---member
for mi=1:memsize;
% ---filename----
   nen=num2str(mi,'%.3d'); 
   infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   ncid = netcdf.open(infile,'NC_NOWRITE');      
   varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'U');       ustag =netcdf.getVar(ncid,varid,[px0 py0 0 0],[2 1 nz 1]);   
   varid  =netcdf.inqVarID(ncid,'V');       vstag =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 2 nz 1]);
   varid  =netcdf.inqVarID(ncid,'W');       wstag =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz+1 1]);  
   varid  =netcdf.inqVarID(ncid,'T');       t0    =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz 1]);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv0   =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz 1]); 
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr0   =netcdf.getVar(ncid,varid,[px0 py0 0 0],[1 1 nz 1]);
   netcdf.close(ncid);
      %
   if mi==1  
   U=zeros(nz,memsize);   V=zeros(nz,memsize);   W=zeros(nz+1,memsize);   T=zeros(nz,memsize);
   QV=zeros(nz,memsize); QR=zeros(nz,memsize);    
   end
   U(:,mi)=squeeze(ustag(1,:,:)     +ustag(2,:,:)   ).*0.5;
   V(:,mi)=squeeze(vstag(:,1,:)     +vstag(:,2,:)   ).*0.5;
   %W(:,mi)=squeeze(wstag(:,:,1:nz)+wstag(:,:,2:nz+1)).*0.5;
      W(:,mi)=squeeze(wstag);
   T(:,mi)=squeeze(t0+300);   
   QV(:,mi)=squeeze(qv0).*10^3;      
   QR(:,mi)=squeeze(qr0).*10^3; 
end   %member
WS=(U.^2+V.^2).^0.5;
A=[U; V; W; WS; T; QV; QR]; 
%-----calculate correlation------------
at=mean(A,2);   At=repmat(at,1,memsize);   Ae=A-At;
%---variance---    
varae=sum(Ae.^2,2)./(memsize-1);     
varaeall=(varae.^0.5)*(varae'.^0.5);
cov=(Ae*Ae')./(memsize-1); %covariance   
%---correlation--- 
corr=cov./(varaeall);
corr(varaeall==0)=0;
R=single(corr);
   