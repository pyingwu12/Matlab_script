%-------------------------------------------------------
% Difference(exp1-exp2) of T between expri1 to expri2  (DA cycle & forecasting time)
%-------------------------------------------------------

clear

hr=2;  expri1='e01';  expri2='e04';  isoid=0;

if isoid==0; lev=15; else hgt_w =500; end  % level or height for plot
%---DA or forecast time---
infilenam='wrfout';  minu='00';            type='sing';
%infilenam='output/fcstmean';  minu='00';  type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/';
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
%L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5];
 L=[-2 -1.5 -1 -0.5 -0.3 -0.1 0.1 0.3 0.5 1 1.5 2];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam='theta';  filenam=[expri1,'-diff-',expri2,'_Th_'];
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
plon=[118.3 122.85];  plat=[21.2 25.8];
%plon=[118.3 121.8];  plat=[21 24.3];


%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');    % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'T');       t1  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PH');       ph1  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb1 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   t1=t1+300;
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'T');      t2  =(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,'PH');       ph2  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb2 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   t2=t2+300;
   
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
       Y=squeeze(vari1(i,j,:));     variso1(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
          
       X=squeeze(zg2(i,j,:));
       Y=squeeze(vari2(i,j,:));     variso2(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       end
      end
      plotvar=variso1-variso2;
      isotype=[num2str(hgt_w/1000),'km'];
   else
      plotvar=t1(:,:,lev)-t2(:,:,lev);
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
   tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,' ',isotype,')'];
   title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,s_hr,minu,'_',isotype];   %print('-dpng',outfile,'-r400')       
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]); 
end    
