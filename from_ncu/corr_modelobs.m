%-------------------------------------------------
% calculate and plot Corr(vm,vo) 
%        between model variable <vmnam> at a point=<px,py,plev> 
%            and obs variable <vonam> of whole scan volumn (plot sweep=<sw>)
%-------------------------------------------------

clear

hr=2;  minu='00';   vmnam='QVAPOR';  vonam='Zh';

%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
px=127;  py=129;  plev=5; %px=137;  py=111;  %px=161;  py=147;   
sw=1.4;  memsize=40; 
loc=36/111;  %radius for plot the circle of localization range

%---DA or forecast time---
%infilenam='wrfout';  dirnam='pert';   type='wrfo' ;
%infilenam='anal';    dirnam='cycle';  type=infilenam;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri]; indir2=['/SAS007/pwin/expri_largens/',expri]; outdir='/SAS011/pwin/201work/plot_cal/largens'; 
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br2.mat'; 
cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:);
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6];    % 02Z
%---
if strcmp(vmnam(1),'Q')==1;  s_vm=vmnam(1:2);  else  s_vm=vmnam; end
corrvari=[lower(s_vm),'-',vonam];  
%
varinam=['Corr.',corrvari];      filenam=[expri,'_corr_']; 
vmen=zeros(memsize,1);
g=9.81;

%tic
%---
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');  
%---member
   for mi=1:memsize;
% ---filename----
      nen=num2str(mi,'%.3d');
      infile1=[indir1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen]; 
      infile2=[indir2,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------model space----      
      ncid = netcdf.open(infile2,'NC_NOWRITE'); 
      varid  =netcdf.inqVarID(ncid,vmnam);     vm =netcdf.getVar(ncid,varid);   
      if     strcmp(vmnam(1),'Q')==1;    vmen(mi)=vm(px,py,plev)*1000;        
      elseif strcmp(vmnam,'U')==1;       vmen(mi)=(vm(px,py,plev)+vm(px+1,py,plev)).*0.5;
      elseif strcmp(vmnam,'V')==1;       vmen(mi)=(vm(px,py,lpev)+vm(px,py+1,plev)).*0.5;
      else   error('Error: Wrong model varible setting of <modvari>');  
      end 
%------obs space------
      %vari1=load(infile1);
      fid=fopen(infile1);      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');
      if mi==1
        varid  =netcdf.inqVarID(ncid,'XLONG');  x =netcdf.getVar(ncid,varid);   p_lon=double(x(px,py));
        varid  =netcdf.inqVarID(ncid,'XLAT');   y =netcdf.getVar(ncid,varid);   p_lat=double(y(px,py));
        varid  =netcdf.inqVarID(ncid,'PH');     ph =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'PHB');    phb =netcdf.getVar(ncid,varid); [nz]=size(ph,3); 
        P0=(phb+ph);   PH=(P0(:,:,1:nz-1)+P0(:,:,2:nz)).*0.5;   zg=double(PH)./g;
        ela=vo{2};  lon=vo{5};  lat=vo{6};   
        np=size(lon,1);   voen=zeros(np,memsize); 
      end           
      if     strcmp(vonam,'Vr')==1;  voen(:,mi)=vo{8}; 
      elseif strcmp(vonam,'Zh')==1;  voen(:,mi)=vo{9}; 
      else   error('Error: Wrong obs varible setting of <obsvari>');  
      end     
      netcdf.close(ncid);
      fclose(fid);
   end   %member   
  
   %---estimate background error---
   % A:2-D, 3-dimention array, b:point, vector
   A=voen;                          b=vmen;    
   at=mean(A,2);                    bt=mean(b);  %estimate true   
   At=repmat(at,1,memsize);
   Ae=A-At;                         be=b-bt;
   %---variance---    
   % !!notice: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
   varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
   cov=(Ae*be)./(memsize-1); %covariance   
   %---correlation--- 
   corr=cov./(varae.^0.5)./(varbe^0.5);
%---plot---
   the=0:0.01:2*pi;  xr=loc*sin(the)+p_lon;  yr=(loc-0.03)*cos(the)+p_lat; 
   %
   plotvar=corr;
   plotvar(plotvar>L(6) & plotvar<L(7))=NaN;
   for swi=sw
     %swi2=fix(swi); fin=find(ela>swi2 & ela<swi2+1);
     fin=find(ela==swi);
     plotvar_sw=plotvar(fin); lon_sw=lon(fin); lat_sw=lat(fin);    
%---plot---
     zmind=0;
     plot_radar(plotvar_sw,lon_sw,lat_sw,cmap,L,zmind) %%%----plot function
     m_plot(p_lon,p_lat,'xk','MarkerSize',10,'LineWidth',2.3)
     m_plot(xr,yr,'k','LineStyle','--','LineWidth',0.6);
     m_text(117.5,25.4,['grid height=',num2str(zg(px,py,plev))],'fontsize',12,'color',[0.6 0.6 0.6])
     %
     sw=num2str(sw);  mem=num2str(memsize);  px=num2str(px);  py=num2str(py);
     tit=[expri,'  ',varinam,'  ',s_hr,'z  (',type,' sw',sw,', mem',mem,')'];  
     title(tit,'fontsize',15)
     outfile=[outdir,'/',filenam,s_hr,'_',px,py,'_',type,'_',corrvari,'_','_sw',sw,'_m',mem];
     print('-dpng',outfile,'-r400')
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]); 
   end 
end
%toc

              
