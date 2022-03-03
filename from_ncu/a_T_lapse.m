%-------------------------------------------------------
% 
%-------------------------------------------------------

clear

hr=2;  expri1='e01';  expri2='e04';   px=145; py=124;

%---DA or forecast time---
infilenam='wrfout';  minu='00';            type='sing';
%infilenam='output/fcstmean';  minu='00';  type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/';
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
%------
varinam='T';  filenam=[expri1,'_T-lsp_'];


%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');    % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'T');       t1  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PH');       ph1  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb1 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   t1=t1+300;
   t1p=squeeze(t1(px,py,:))-273;
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'T');      t2  =(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,'PH');       ph2  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb2 =netcdf.getVar(ncid,varid); 
   netcdf.close(ncid)
   t2=t2+300;
   t2p=squeeze(t2(px,py,:))-273;
%---plot---

   figure('position',[500 500 600 500]) 
   plot(t1p,1:nz,'r','LineWidth',2); hold on
   plot(t2p,1:nz,'k','LineWidth',2);
   %legh=legend('256 w/o da','40 w/o da','256 w/ da','40 w/ da'); 
   %legh=legend('256 mem (fcst)','40 mem (fcst)'); 
  % legh=legend(explegend);
   %set(legh,'fontsize',13,'Location','Southeast','box','off')
   %line([0 0],[0 45],'color','k'); 
   %
    set(gca,'XLim',[24 35],'YTick',1:2:nz,'YTickLabel',1:2:nz,'fontsize',13,'LineWidth',1)
    xlabel('Potetial Temperature (^oC)','fontsize',14);  ylabel('height(km)','fontsize',14);
    %
    tit=[expri1,' , ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,')'];
    title(tit,'fontsize',15)
%    outfile=[outdir,'/',filenam,s_hr,minu,'_',type];  %print('-dpng',outfile,'-r400')       
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 
end    
