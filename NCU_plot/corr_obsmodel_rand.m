%function corr_obsmodel(hr,minu,vonam,vmnam,memsize,pradar,pela,paza,pdis)
%function corr_obsmodel(hr,minu,vonam,vmnam,memsize)
function corr_obsmodel_rand(vonam,vmnam)
%-------------------------------------------------
%   Corr.(obs_point,model_2D-level) 
%-------------------------------------------------
%
%clear
%
hr=0;  minu='00';   %vonam='Zh';  vmnam='QVAPOR';  
memsize=40;
%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
pradar=4;  pela=0.5;  paza=248;  pdis=83;
lev=0; 

loc=12/111;  %radius for plot the circle of localization range

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri]; indir2=['/SAS009/pwin/expri_largens/',expri]; 
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 

%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br2.mat'; 
cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:);
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6];    % 02Z
%---

if strcmp(vmnam(1),'Q')==1;  s_vm=lower(vmnam(1:2));  else  s_vm=vmnam; end
corrvari=[vonam,'-',lower(s_vm)];  
%
varinam=['Corr.',corrvari];    filenam=[expri,'_']; 
%plon=[117.5 122.5]; plat=[20.5 25.65];
plon=[117.85 121.8]; plat=[20.5 24.65]; %southwest area for paper
%plon=[118.3 121.8];   plat=[21 24.3];
if pradar==3; lonrad=120.8471; latrad=21.9026; elseif pradar==4; lonrad=120.086; latrad=23.1467; end
%
voen=zeros(memsize,1); 
g=9.81;
memsizeL=256;

randmem=randi(memsizeL,1,memsize);
%tic
%---
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');  
%---member
   for mi=1:memsize;
% ---filename----
      %nen=num2str(mi,'%.3d');
      nen=num2str(randmem(mi),'%.3d');    % <-------------------------------
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
         [nx ny]=size(x);      vmen=zeros(nx,ny,memsize);         
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
      end
      varid  =netcdf.inqVarID(ncid,vmnam);    
      nx2=nx; ny2=ny; if strcmp(vmnam,'V')==1 ny2=ny+1; elseif strcmp(vmnam,'U')==1 nx2=nx+1; end
      vm =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx2 ny2 1 1]);  vm=squeeze(vm); 
      if     strcmp(vmnam(1),'Q')==1;   vmen(:,:,mi)=vm*1000*;        
      elseif strcmp(vmnam,'T')==1;      vmen(:,:,mi)=vm+300;  
      elseif strcmp(vmnam,'U')==1;      vmen(:,:,mi)=(vm(1:nx,:)+vm(2:nx+1,:)).*0.5;
      elseif strcmp(vmnam,'V')==1;      vmen(:,:,mi)=(vm(:,1:ny)+vm(:,2:ny+1)).*0.5;
      else   error('Error: Wrong model varible setting of <vmnam>');  
      end 
      netcdf.close(ncid);
      fclose(fid);
   end   %member
   
   %---estimate background error---
   % A:2-D, 3-dimention array, b:point, vector
   A=reshape(vmen,nx*ny,memsize);      b=voen;    
   at=mean(A,2);                        bt=mean(b);  %estimate true   
   At=repmat(at,1,memsize);
   Ae=A-At;                             be=b-bt;
   %---variance---    
   % !!note: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
   varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
   cov=(Ae*be)./(memsize-1); %covariance   
   %---correlation--- 
   corr0=cov./(varae.^0.5)./(varbe^0.5);
   corr0((varae.^0.5).*(varbe^0.5)+1==1)=0;
   corr=reshape(corr0,nx,ny);
   %%
%}
%---plot---
   pmin=double(min(min(corr)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[1500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %
   [c hp]=m_contourf(x,y,corr,L2);   set(hp,'linestyle','none');  hold on;  
   cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   m_gshhs_h('color','k','LineWidth',0.8);
   %m_coast('color','k');
%---
   %---obs point and radar positation
   m_plot(p_lon,p_lat,'xk','MarkerSize',11,'LineWidth',2.6)                                    % obs point
   m_plot(lonrad,latrad,'^','color',[0.1 0.8 0.1],'MarkerFaceColor',[0 1 0],'MarkerSize',10)   % radar position
   %---localization radius circle---
   %the=0:0.01:2*pi;  xr=loc*3.12*sin(the)+p_lon;  yr=(loc*3)*cos(the)+p_lat; 
   %m_plot(xr,yr,'k','LineStyle','--','LineWidth',0.6);
   %---prit location and height of the obs point
%   m_text(plon(2)-(plon(2)-plon(1))/4.5,plat(1)+(plat(2)-plat(1))/66,[num2str(pradar),'-',num2str(pela),'-',num2str(paza),'-',num2str(pdis)],'color',[0.4 0.4 0.4])
%   m_text(plon(1)+(plon(2)-plon(1))/72,plat(2)-(plat(2)-plat(1))/25,['obs height=',num2str(obs_hgt)],'fontsize',12,'color',[0.4 0.4 0.4]) % obs height
%---
   lev=num2str(lev);  mem=num2str(memsize);
   tit=[expri,'  ',varinam,'  ',s_hr,'UTC  (',type,' lev',lev,', mem',mem,')']; 
%   tit=['Corr.(',vonam,', ',s_vm,')','  ',mem,' members']; 
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',num2str(fin),'_',type,'_',corrvari,'_lev',lev,'_m',mem];
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 
  %} 
end              
