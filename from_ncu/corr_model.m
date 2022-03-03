%function corr_model(memsize) 
%-------------------------------------------------
% calculate and plot Corr(v1,v2) 
%        between model variable <v1nam> at point <px,py>, level <plev> 
%            and model variable <v2nam> at level <lev> 
%-------------------------------------------------
clear all
close all

hr=0;  minu='00';   v1nam='V';  v2nam='U';

%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
plev=10;  %px=139;  py=142;    %px=161;  py=147;     %px=137;  py=111;   %px=137;  py=118;  %px=151;  py=132; 
px=128;  py=129;
%px=162;  py=94;
lev =10;  memsize=256;   
%loc=36/111;  %radius for plot the circle of localization range

%---DA or forecast time---
%infilenam='wrfout';  dirnam='pert';  type='wrfo';
%infilenam='fcst';    dirnam='cycle'; type=infilenam;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  %outdir='/SAS011/pwin/201work/plot_cal/largens'; 
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%indir=['/work/pwin/data/sz_wrf2obs_',expri];  outdir='/SAS011/pwin/201work/plot_cal/IOP8'; 
%memsize=256;  
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');  load '/work/pwin/data/colormap_br2.mat'; 
cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:);
L=[-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6];   
%---
if strcmp(v1nam(1),'Q')==1;  s_v1=v1nam(1:2);  else  s_v1=v1nam; end
if strcmp(v2nam(1),'Q')==1;  s_v2=v2nam(1:2);  else  s_v2=v2nam; end
corrvari=[s_v1,'-',lower(s_v2)];  
%
varinam=['Corr.',corrvari];     filenam=[expri,'_corr_']; 
%plon=[117.5 122.5]; plat=[20.5 25.65];
plon=[118.1 121.1]; plat=[20.85 24.1];
%
v1en=zeros(memsize,1); 

%---
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');  
%---member
   for mi=1:memsize;
% ---filename----
      nen=num2str(mi,'%.3d'); 
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
      ncid = netcdf.open(infile,'NC_NOWRITE'); 
      if mi==1
        varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
        [nx ny]=size(x);
        v2en=zeros(nx,ny,memsize);         
%         varid  =netcdf.inqVarID(ncid,'PH');     ph =netcdf.getVar(ncid,varid);
%         varid  =netcdf.inqVarID(ncid,'PHB');    phb =netcdf.getVar(ncid,varid); [nz]=size(ph,3); 
%         P0=(phb+ph);   PH=(P0(:,:,1:nz-1)+P0(:,:,2:nz)).*0.5;   zg=double(PH)./g;
      end      
      %---point
      varid  =netcdf.inqVarID(ncid,v1nam);      v1 =netcdf.getVar(ncid,varid,[px-1 py-1 plev-1 0],[2 2 1 1],'double');   
      if     strcmp(v1nam(1),'Q')==1;  v1en(mi)= v1(1,1)*1000;        
      elseif strcmp(v1nam,'U')==1;     v1en(mi)=(v1(1,1)+v1(2,1)).*0.5;
      elseif strcmp(v1nam,'V')==1;     v1en(mi)=(v1(1,1)+v1(1,2)).*0.5;
      else   error('Error: Wrong model varible setting of <pvari>');  
      end
      %---2D domain
      varid  =netcdf.inqVarID(ncid,v2nam);     v2 =netcdf.getVar(ncid,varid);
      if     strcmp(v2nam(1),'Q')==1;  v2en(:,:,mi)= v2(:,:,lev)*1000;        
      elseif strcmp(v2nam,'U')==1;     v2en(:,:,mi)=(v2(1:nx,:,lev)+v2(2:nx+1,:,lev)).*0.5;
      elseif strcmp(v2nam,'V')==1;     v2en(:,:,mi)=(v2(:,1:ny,lev)+v2(:,2:ny+1,lev)).*0.5;
      else   error('Error: Wrong model varible setting of <mvari>');  
      end 
      netcdf.close(ncid);
   end   %member
   
   %---estimate background error---
   % A:2-D, 3-dimention array, b:point, vector
   A=reshape(v2en,nx*ny,memsize);      b=v1en;    
   at=mean(A,2);                       bt=mean(b);  %estimate true   
   At=repmat(at,1,memsize);
   Ae=A-At;                            be=b-bt;
   %---variance---    
   % !!notice: mean(Ai-Abar)=0, i.e. mean of ensemble perturbation is zero, so it doesn't need to minus mean
   varae=sum(Ae.^2,2)./(memsize-1);     varbe=be'*be/(memsize-1);  
   cov=(Ae*be)./(memsize-1); %covariance   
   %---correlation--- 
   corr0=cov./(varae.^0.5)./(varbe^0.5);
   corr=reshape(corr0,nx,ny);
% %---plot---

   %the=0:0.01:2*pi;  xr=loc*sin(the)+x(px,py);  yr=(loc-0.03)*cos(the)+y(px,py);  

   pmin=double(min(min(corr)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %
   [c hp]=m_contourf(x,y,corr,L2);   set(hp,'linestyle','none');  hold on;  
   cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45); 
   m_gshhs_h('color','k','LineWidth',0.8);
   %m_coast('color','k');
   %
   m_plot(x(px,py),y(px,py),'xk','MarkerSize',10,'LineWidth',2.3)
   %m_plot(xr,yr,'k','LineStyle','--','LineWidth',0.6);   
   %
   lev=num2str(lev); plev=num2str(plev); mem=num2str(memsize); px=num2str(px); py=num2str(py);
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,', lev',plev,'-',lev,', mem',mem,')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',px,py,'_',type,'_',corrvari,'_lev',plev,'-',lev,'_m',mem];
   print('-dpng',outfile,'-r400')  
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]); 
end
%toc

              
