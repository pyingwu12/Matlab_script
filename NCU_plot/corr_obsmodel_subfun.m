function [corr x y p_lon p_lat obs_hgt]=corr_obsmodel_subfun(hr,minu,vonam,vmnam,memsize,pradar,pela,paza,pdis,sub)
%-------------------------------------------------
%   Corr.(obs_point,model_2D-level(subdomain)) 
%-------------------------------------------------

%clear
%
%hr=0;  minu='00';   vonam='Vr';  vmnam='U'; sub=72/3;

%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
%pradar=4;  pela=0.5;  paza=203;  pdis=83;  memsize=40;   

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri]; indir2=['/SAS009/pwin/expri_largens/',expri]; 
%
voen=zeros(memsize,1); 
g=9.81;
sub2=sub*2+1;
vmen=zeros(sub2,sub2,memsize);
%
%tic
%---set time and filename---    
s_hr=num2str(hr,'%2.2d');  
%---member
for mi=1:memsize;
% ---filename----
   nen=num2str(mi,'%.3d');
   infile1=[indir1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen]; 
   infile2=[indir2,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------obs space------
   fid=fopen(infile1);      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');
   fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
   if isempty(fin)==1;  error('Error: No this obs point, pleast check the setting of <pradar> etc.'); end
   if     strcmp(vonam,'Vr')==1;  voen(mi)=vo{8}(fin); 
   elseif strcmp(vonam,'Zh')==1;  voen(mi)=vo{9}(fin); 
   else   error('Error: Wrong obs varible setting of <vonam>');  
   end      
   if voen(mi)==-9999; disp(['member ',nen,' obs is -9999']); voen(mi)=0;  end;       
%------model space----      
   ncid = netcdf.open(infile2,'NC_NOWRITE'); 
   if mi==1
      p_lon=vo{5}(fin); p_lat=vo{6}(fin); obs_hgt=vo{7}(fin);
      varid =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid); 
      varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
%---difine px, py for th line---
      dis= ( (y-p_lat).^2 + (x-p_lon).^2 );
      [mid mxI]=min(dis);    [~, py]=min(mid);    px=mxI(py); %------------------------> px,py
      %
      varid  =netcdf.inqVarID(ncid,'PH');   ph =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
      varid  =netcdf.inqVarID(ncid,'PHB');  phb =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
      P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)./g;
      [~, lev]=min(abs(zg-obs_hgt));                          %------------------------> lev
   end
   varid  =netcdf.inqVarID(ncid,vmnam);
   vm=netcdf.getVar(ncid,varid,[px-sub-1 py-sub-1 lev-1 0],[sub2+1 sub2+1 1 1]);
   vm=squeeze(vm);
   if     strcmp(vmnam(1),'Q')==1;   vmen(:,:,mi)=vm(1:sub2,1:sub2);        
   elseif strcmp(vmnam,'T')==1;      vmen(:,:,mi)=vm(1:sub2,1:sub2)+300;  
   elseif strcmp(vmnam,'U')==1;      vmen(:,:,mi)=(vm(1:sub2,1:sub2)+vm(2:sub2+1,1:sub2)).*0.5;
   elseif strcmp(vmnam,'V')==1;      vmen(:,:,mi)=(vm(1:sub2,1:sub2)+vm(1:sub2,2:sub2+1)).*0.5;
   else   error('Error: Wrong model varible setting of <vmnam>');  
   end 
   netcdf.close(ncid);
   fclose(fid);
end   %member
   
%---estimate background error---
% A:2-D, 3-dimention array, b:point, vector
A=reshape(vmen,sub2*sub2,memsize);      b=voen;    
at=mean(A,2);                        bt=mean(b);  %estimate true   
At=repmat(at,1,memsize);
Ae=A-At;                             be=b-bt;
%---variance---    
% !!note: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
cov=(Ae*be)./(memsize-1); %covariance   
%---correlation--- 
corr0=cov./(varae.^0.5)./(varbe^0.5);
corr=reshape(corr0,sub2,sub2);
%
x=x(px-sub:px+sub,py-sub:py+sub); y=y(px-sub:px+sub,py-sub:py+sub);
              
