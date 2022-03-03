
%-------------------------------------------------------
% Caculate and plot ensemble spread of integrate qr
%-------------------------------------------------------

clear

hr=0;   minu='00';   expri='largens';   memsize=256;
%---DA or forecast time---
infilenam='wrfout';   type=infilenam;  dirnam='pert';

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];   outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri];    % path of the experiments
%indir=['/SAS009/pwin/expri_morakotEC/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/morakot_EC/',expri];
%indir=['/SAS007/pwin/expri_largens/WRF_shao'];  outdir='/SAS011/pwin/201work/plot_cal/largens';
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[0.1 0.5 1 2 3 4 5 6 7];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_sprd.mat';  cmap=colormap_sprd([1 3 4 6 7 9 11 13 14 15],:); 
%---
varinam='total qr spread';    filenam=[expri,'_TPW-qr-sprd_'];  
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
plon=[118.3 122.85];  plat=[21.2 25.8];
g=9.81;    
  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
   for mi=1:memsize
%---set filename---
      nen=num2str(mi,'%.3d');
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
      varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
       netcdf.close(ncid)
      [nx ny]=size(x);
      if mi==1;    TPWmen=zeros(nx,ny,memsize);  end
%---integrate TPW---
      P=(pb+p);        dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
      tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
      TPWmen(:,:,mi)=sum(tpw,3)./g;      
      %TPWmen(:,mi)=reshape(TPW,nx*ny,1); 
   end  %member
%---
   A=reshape(TPWmen,nx*ny,memsize);     
   am=mean(A,2);     Am=repmat(am,1,memsize);
   Ap=A-Am; 
   varae=sum(Ap.^2,2)./(memsize-1);    
   sprd=reshape(sqrt(varae),nx,ny);
%---plot---
   plotvar=sprd;
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   %
   figure('position',[600 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [cp hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)   
   %
   mem=num2str(memsize);
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,', mem',mem,')']; 
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_m',mem];
%    print('-dpng',outfile,'-r400')     
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  
end  %ti