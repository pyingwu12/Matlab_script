%--------------------------------------------------
% Potential temperature increment (anal-fcst) profile 
%--------------------------------------------------

clear

hr=0;   minu='00';    expri='e04';   isoid=0;
if isoid==0; lev=10; else hgt_w =500; end  % level or height for plot

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 
obsdir='/SAS004/pwin/data/obs_sz6414'; indir2=['/work/pwin/data/largens_wrf2obs_',expri];  
L=[-1 -0.8 -0.6 -0.4 -0.2 -0.1 0.1 0.2 0.4 0.6 0.8 1];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam='theta increment';   filenam=[expri,'_Th-incr_'];
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.3 121.8];  plat=[21 24.3];

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile1=[indir,'/output/fcstmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,'/output/analmean_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   x =double(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,'XLAT');    y =double(netcdf.getVar(ncid,varid));    
   varid  =netcdf.inqVarID(ncid,'T');       t1  =(netcdf.getVar(ncid,varid))+300;
   varid  =netcdf.inqVarID(ncid,'PH');      ph1 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb1 =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
  %---integrate TPW---
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'T');      t2  =(netcdf.getVar(ncid,varid))+300;
   varid  =netcdf.inqVarID(ncid,'PH');      ph2 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb2 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid) 
   
   %---interpolation to constant-height above surface
   if isoid~=0
      g=9.81;
      P0=double(phb1+ph1);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg1=double(PH)/g;   
      P0=double(phb2+ph2);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg2=double(PH)/g;   
      hgtiso=double(hgt)+hgt_w; 
      variso1=zeros(nx,ny);  variso2=zeros(nx,ny);
      for i=1:nx
       for j=1:ny
       X=squeeze(zg1(i,j,:));
       Y=squeeze(t1(i,j,:));     variso1(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
          
       X=squeeze(zg2(i,j,:));
       Y=squeeze(t2(i,j,:));     variso2(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       end
      end
      plotvar=variso2-variso1;
      isotype=[num2str(hgt_w/1000),'km'];
   else
      plotvar=t2(:,:,lev)-t1(:,:,lev);
      isotype=['lev',num2str(lev)];
   end
     
%--plot----
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   %
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);  title(hc,'(K)') 
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
    %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',isotype,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',isotype];   %print('-dpng',outfile,'-r400')       
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 
end    

