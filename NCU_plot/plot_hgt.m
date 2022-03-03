clear; 

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_tern.mat'
%======
%indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_0614e01'];
%indir=['/SAS009/pwin/expri_cctmorakot/shao_sing'];
%outdir=['/work/pwin/plot_cal/IOP8/'];
%infile='/SAS009/pwin/expri_morakotEC/shao/wrfout_d02_2009-08-08_18:00:00';
infile='/SAS009/pwin/expri_whatsmore/vr124/wrfout_d01_2012-06-10_12:00:00';
%infile1='/SAS009/pwin/expri_morakotEC/shao/cycle01/wrfinput_d01_2009-08-08_16:30:00';
%infile='/SAS007/juliechang/WRFt3.6.1/WRFV3/run/wrfinput_1300_2312_preparationforTCcentered_neweta/wrfinput_d01_2010-10-18_00:00:00';
L=[100 250 500 1000 1200 1500 2000 2500 3000];

%colormap_tern=[221 239 253; 182 217 154; 217 233 160; 250 215 151; 226 169 115; 185 142 108 ]./255;
%{
colormap_tern=[121 168  39;
               130 200  39;
               175 214  89;
               217 239 123;
               240 220 124;
               243 196  54;
               243 150  75;
               245 112  38;
               225 105  41
               186 107  31]./255;
%}
cmap=colormap_tern;

%---
%infile=[indir,'/wrfout_d02_2008-06-14_12:00:00_mean'];
%infile=[indir,'/wrfout_d01_2009-08-09_00:00:00'];
%----read netcdf data--------
%   ncid = netcdf.open(infile1,'NC_NOWRITE');
%    varid  =netcdf.inqVarID(ncid,'XLONG');    lonr =netcdf.getVar(ncid,varid);    xr=double(lonr);
%    varid  =netcdf.inqVarID(ncid,'XLAT');    latr =netcdf.getVar(ncid,varid);    yr=double(latr);
%    varid  =netcdf.inqVarID(ncid,'HGT');    hgtr =netcdf.getVar(ncid,varid);
   
  ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'HGT');    hgt =netcdf.getVar(ncid,varid);   
   
   hgt(hgt<0.02)=NaN;
   
   hgt(lon<119.9 | lat<20)=NaN;  
   
   
%---plot
    figure('position',[200 500 600 500])
   % m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
    m_proj('miller','lon',[113 123],'lat',[17 26])
      
    %L2=[L(1) L];  
    %[c1 hp1]=m_contourf(xr,yr,hgtr,L2);   set(hp1,'linestyle','none');   
    %hold on  
    
    plotvar=hgt(:,:);
    pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end     
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
  cm=colormap(cmap);    caxis([L2(1) L(length(L))])    
  hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
% %---
% 
    %m_coast('color','k','LineWidth',1);
    m_grid('fontsize',12,'LineStyle','--','LineWidth',1,'tickdir','out','backcolor',[0.7 0.9 0.95]); 
    m_gshhs_h('color','k','LineWidth',1);
% 
    tit='terrain from model (3-km grid spacing)';
    title(tit,'fontsize',15)
    outfile='terrain';
    %print('-dpng',outfile,'-r400')    
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
    
    netcdf.close(ncid)
    