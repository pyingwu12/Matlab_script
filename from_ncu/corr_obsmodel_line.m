%function corr_obsmodel_hline(vonam,vmnam,memsize)
function corr_obsmodel_hline(vonam,vmnam,pradar,pela,paza,pdis)
%-------------------------------------------------
%   Corr.(obs_point,model_2D-level) of 20 40 80 160 256
%-------------------------------------------------
%
%clear
%
hr=0;  minu='00'; % vonam='Vr';  vmnam='QVAPOR';  
memsize=[20 40 64 128 256];  s_mem={'20';'40';'64';'128';'256'};
memsizeL=256;

%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
%pradar=4;  pela=0.5;  paza=178;  pdis=73;
lev=0; 

len=2;   slopx=1;   slopy=0; %integer

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri]; indir2=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 

%---set
if strcmp(vmnam(1),'Q')==1;  s_vm=[vmnam(1),lower(vmnam(2))];  else  s_vm=vmnam; end
corrvari=[vonam,'-',lower(s_vm)];  
%
varinam=['Corr.(',vonam,',',lower(s_vm),')'];    filenam=['corr-line_',expri,'_']; 
%
voen=zeros(memsizeL,1); 
g=9.81;


%---set time and filename---    
   s_hr=num2str(hr,'%2.2d');  
%---member
   for mi=1:memsizeL;
% ---filename----
      nen=num2str(mi,'%.3d');      
      infile1=[indir1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen]; 
      infile2=[indir2,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------obs space------
      %vari1=load(infile1);
      fid=fopen(infile1);
      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');
      fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
      %fin=30424;
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
         varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
         varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
         [nx ny]=size(x);      %vmen=zeros(nx,ny,memsize);         
         if lev==0
           %---difine px, py for th line---
           dis= ( (y-p_lat).^2 + (x-p_lon).^2 );
           [mid mxI]=min(dis);    [~, py]=min(mid);    px=mxI(py); %------------------------> px,py
           %
           varid =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
           varid  =netcdf.inqVarID(ncid,'PH');   ph =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
           varid  =netcdf.inqVarID(ncid,'PHB');  phb =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
           P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)./g;
           [~, lev]=min(abs(zg-obs_hgt));                          %------------------------> lev
         end
         %----get x,y coordinate of the line---
         n=0;  lonB=0; latB=0;
         %from obs point to the last point, find n  
         while lonB<=x(px,py)+len/2 && latB<=y(px,py)+len/2
           n=n+1; lonB=x(px+slopx*(n-1),py+slopy*(n-1));  latB=y(px+slopx*(n-1),py+slopy*(n-1));
         end           
         %total grids = n*2; x coordinate of the line: linex; y coordinate of the line: liney;
         np=n*2+1;  %linex=zeros(1,np); liney=zeros(1,np); 
         for i=1:np
           indx(i)=px+slopx*(i-n-1);    indy(i)=py+slopy*(i-n-1);  %  linex(i)=x(indx,indy);  liney(i)=y(indx,indy);   
         end
         vmen=zeros(np,memsizeL);
      end %if m==1
%
      varid  =netcdf.inqVarID(ncid,vmnam);    
      npx2=1; npy2=1;  if strcmp(vmnam,'V')==1; npy2=2; elseif strcmp(vmnam,'U')==1; npx2=2; end
      for i=1:np
         vm =netcdf.getVar(ncid,varid,[indx(i)-1 indy(i)-1 lev-1 0],[npx2 npy2 1 1]);  vm=squeeze(vm);      
         if     strcmp(vmnam(1),'Q')==1;   vmen(i,mi)=vm;        
         elseif strcmp(vmnam,'T')==1;      vmen(i,mi)=vm+300;  
         elseif strcmp(vmnam,'U')==1;      vmen(i,mi)=(vm(1)+vm(2)).*0.5;
         elseif strcmp(vmnam,'V')==1;      vmen(i,mi)=(vm(1)+vm(2)).*0.5;
         else   error('Error: Wrong model varible setting of <vmnam>');  
         end 
      end
      netcdf.close(ncid);
      fclose(fid);
   end   %member
   %
   %---estimate background error---
   for mj=1:length(memsize)   
      A=vmen(:,1:memsize(mj));   b=voen(1:memsize(mj));   at=mean(A,2);    bt=mean(b);  %estimate true   
      At=repmat(at,1,memsize(mj));  Ae=A-At;         be=b-bt;
      varae=sum(Ae.^2,2)./(memsize(mj)-1);     varbe=be'*be/(memsize(mj)-1);  %---variance---
      cov=(Ae*be)./(memsize(mj)-1); %covariance   
      corr{mj}=cov./(varae.^0.5)./(varbe^0.5); %correlation
   end
%}
%---plot---
%
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
   dx=3*(slopx^2+slopy^2)^0.5;
   cmap=winter(length(memsize))-0.1;    cmap(cmap<0)=0; cmap(1,:)=[0.1 0.1 1];
   %---
   figure('position',[200 100 850 500]) 
   for i=1:length(memsize)
     plot(1:np,corr{i},'color',cmap(i,:),'LineWidth',1.5); hold on
   end 
   h=legend(s_mem,'location','NorthEastOutside','fontsize',14);
   %title(h,'Ensemble Size')
   xtick=1:n/3:np;
   set(gca,'XLim',[1 np],'Xtick',xtick,'XtickLabel',(xtick-n-1)*dx,'Ylim',[-0.8 0.6],'Ytick',[-0.6:0.2:0.4],'fontsize',13)
   xlabel('Distant (km)'); ylabel('CORR')
%---
   lev=num2str(lev); 
   tit=[num2str(pradar),'-',num2str(pela),'-',num2str(paza),'-',num2str(pdis),'  ',varinam,'  ',s_hr,'UTC']; 
%   tit=['CORR(',vonam,', ',s_vm,')','  ',mem,' members']; 
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',corrvari,'_',num2str(fin),'_slo',slope];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
  %} 
             
