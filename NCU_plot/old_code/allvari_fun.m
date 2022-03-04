function  allvari_fun(pradar,pela,paza,pdis)
%-------------------------------------------------
%   read and save obs and model variables in the sub area 
%-------------------------------------------------
%clear
hr=0;  minu='00';  %pradar=4;  pela=0.5;  paza=248;  pdis=83;    
sub=36; %grid numbers of radius, 12 => 12*dx*2  
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri]; indir2=['/SAS009/pwin/expri_largens/',expri]; 
%
memsizel=256;  memsizes=40;
g=9.81;
sub2=sub*2+1;
%

V=zeros(sub2,sub2,memsizel); U=zeros(sub2,sub2,memsizel); T=zeros(sub2,sub2,memsizel);
QVAPOR=zeros(sub2,sub2,memsizel); QRAIN=zeros(sub2,sub2,memsizel);
Zh=zeros(memsizel,1); 
Vr=zeros(memsizel,1); 
%
%---set time and filename---    
s_hr=num2str(hr,'%2.2d');  
%---member
for mi=1:memsizel;
%---filename----
   nen=num2str(mi,'%.3d');
   infile1=[indir1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen]; 
   infile2=[indir2,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------obs space------
   fid=fopen(infile1);      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');
   fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
   if isempty(fin)==1;  error('Error: No this obs point, pleast check the setting of <pradar> etc.'); end

   Vr(mi)=vo{8}(fin);  
   Zh(mi)=vo{9}(fin);
   if Vr(mi)==-9999; disp(['member ',nen,' ',Vr,' is -9999']); voen(mi)=0;  end;
   if Zh(mi)==-9999; disp(['member ',nen,' ',Zh,' is -9999']); voen(mi)=0;  end;

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

   varid  =netcdf.inqVarID(ncid,'V');
   vm=netcdf.getVar(ncid,varid,[px-sub-1 py-sub-1 lev-1 0],[sub2+1 sub2+1 1 1]); vm=squeeze(vm);
   V(:,:,mi)=(vm(1:sub2,1:sub2)+vm(1:sub2,2:sub2+1)).*0.5;
   
   varid  =netcdf.inqVarID(ncid,'U');
   vm=netcdf.getVar(ncid,varid,[px-sub-1 py-sub-1 lev-1 0],[sub2+1 sub2+1 1 1]); vm=squeeze(vm);
   U(:,:,mi)=(vm(1:sub2,1:sub2)+vm(2:sub2+1,1:sub2)).*0.5;

   varid  =netcdf.inqVarID(ncid,'QRAIN');
   vm=netcdf.getVar(ncid,varid,[px-sub-1 py-sub-1 lev-1 0],[sub2+1 sub2+1 1 1]); vm=squeeze(vm);
   QRAIN(:,:,mi)=vm(1:sub2,1:sub2);

   varid  =netcdf.inqVarID(ncid,'QVAPOR');
   vm=netcdf.getVar(ncid,varid,[px-sub-1 py-sub-1 lev-1 0],[sub2+1 sub2+1 1 1]); vm=squeeze(vm);
   QVAPOR(:,:,mi)=vm(1:sub2,1:sub2);

   varid  =netcdf.inqVarID(ncid,'T');
   vm=netcdf.getVar(ncid,varid,[px-sub-1 py-sub-1 lev-1 0],[sub2+1 sub2+1 1 1]); vm=squeeze(vm);
   T(:,:,mi)=vm(1:sub2,1:sub2);

   netcdf.close(ncid);
   fclose(fid);
end   %member


  %hr=0;  minu='00';  pradar=4;  pela=0.5;  paza=248;  pdis=83;    sub=12;
  save(['varis_',num2str(pradar),'-',num2str(pela),'-',num2str(paza),'-',num2str(pdis),'_sub',num2str(sub),'.mat'],'Vr','Zh','U','V','T','QVAPOR','QRAIN')





