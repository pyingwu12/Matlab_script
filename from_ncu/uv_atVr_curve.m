function uv_atVr_obscurve(pradar,paza)
%
%clear all
%close all
%
hr=0;  minu='00';   memsize=25;  

expri='largens';  infilenam='wrfout';  type='wrfo';
%pradar=3;  paza=253;
pela=0.5; pdis=83;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS011/pwin/201work/data/wrf2obs_uv/largens_wrf2obs_',expri]; 
%
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br2.mat';
%---
vr=zeros(memsize,1); vru=zeros(memsize,1); vrv=zeros(memsize,1);
g=9.81;
plon=[118.4 121.8]; plat=[20.65 24.35];


%---
s_hr=num2str(hr,'%2.2d');  
for mi=1:memsize;
   nen=num2str(mi,'%.3d');      
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen];
%--- 
   fid=fopen(infile);
   vo=textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f');      fclose(fid);
   fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
   if isempty(fin)==1;  error('Error: No this obs point, pleast check the setting of <pradar> etc.'); end
   vr(mi)=vo{8}(fin);
   if vr(mi)==-9999; disp(['member ',nen,' obs is -9999']); vr(mi)=0;  end;

   vru(mi)=sin(vo{3}(fin)./180*pi).*vo{10}(fin).*cos(vo{2}(fin)./180*pi);
   vrv(mi)=cos(vo{3}(fin)./180*pi).*vo{11}(fin).*cos(vo{2}(fin)./180*pi);

   if mod(mi,10)==0; disp(num2str(mi)); end
end   %member

   %diff=u_vrm-v_vrm;
   %lon=vo{5}(fin); lat=vo{6}(fin);

%
 %----plot
  figure('position',[100 200 600 500])

  plot(vr,'k'); hold on
  plot(vru,'r'); plot(vrv,'b')
  legend('vr','vru','vrv')
  set(gca,'Xlim',[1 memsize])

   tit='u-v ratio to Vr';
   title(tit,'fontsize',15)
%   outfile=[outdir,'/',filenam,s_hr,minu,'_',vonam,'-',lower(s_vm),'_sub',num2str(sub)];

%}

