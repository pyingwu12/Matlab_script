%   variance of a model veriable at every grid point on a model level
%-------------------------------------------------
%
clear

hr=0;  minu='00';   vnam='QRAIN'; 

%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
lev=10;  memsize=256;   

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir='/SAS011/pwin/201work/plot_cal/largens'; 
%indir=['/work/pwin/data/sz_wrf2obs_',expri];  outdir='/SAS011/pwin/201work/plot_cal/IOP8'; 
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');  load '/work/pwin/data/colormap_sprd.mat'; 
cmap=colormap_sprd;
%L=[1 2 4 6 8 10 15 20 25 30 35 40 45 50]; %V
L=[1 5 10 15 20 25 30 35 40 45 50 55 60 65]*0.00005; %qv
%---
if strcmp(vnam(1),'Q')==1;  s_v=lower(vnam(1:2));  else  s_v=lower(vnam); end
varinam=['Var. ',s_v];     filenam=[expri,'_var-',s_v,'_']; 
plon=[117.5 122.5]; plat=[20.5 25.65];
%

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
        ven=zeros(nx,ny,memsize);         
%         varid  =netcdf.inqVarID(ncid,'PH');     ph =netcdf.getVar(ncid,varid);
%         varid  =netcdf.inqVarID(ncid,'PHB');    phb =netcdf.getVar(ncid,varid); [nz]=size(ph,3); 
%         P0=(phb+ph);   PH=(P0(:,:,1:nz-1)+P0(:,:,2:nz)).*0.5;   zg=double(PH)./g;
      end      
      varid  =netcdf.inqVarID(ncid,vnam);     vari =netcdf.getVar(ncid,varid);
      if     strcmp(vnam(1),'Q')==1;  varien(:,:,mi)= vari(:,:,lev);        
      elseif strcmp(vnam,'U')==1;     varien(:,:,mi)=(vari(1:nx,:,lev)+vari(2:nx+1,:,lev)).*0.5;
      elseif strcmp(vnam,'V')==1;     varien(:,:,mi)=(vari(:,1:ny,lev)+vari(:,2:ny+1,lev)).*0.5;
      else   error('Error: This model varible is unavailable');  
      end 
      netcdf.close(ncid);
   end   %member
   
   %---variance---    
   A=reshape(varien,nx*ny,memsize);
   am=mean(A,2);     Am=repmat(am,1,memsize);
   Ap=A-Am;
   varae=sum(Ap.^2,2)./(memsize-1);
   vvar=reshape(varae,nx,ny);
%}
%---plot---
   plotvar=vvar*1000;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;  
   cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
   title(hc,'10^-^3')
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
   m_gshhs_h('color','k','LineWidth',0.8);
   %m_coast('color','k');
   %
   s_lev=num2str(lev); mem=num2str(memsize);
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,', lev',s_lev,', mem',mem,')'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_lev',s_lev,'_m',mem];
   %print('-dpng',outfile,'-r400')  
   %set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   %system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   %system(['rm ',[outfile,'.pdf']]); 
%}
end
%toc

              
