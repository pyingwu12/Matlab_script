clear

hr=2;    minu='00';   expri='largens';   
%expri='e01'; 
memsize=40;  px=137;  py=118; 

%---DA or forecast time---
infilenam='wrfout';  dirnam='pert';    type='wrfo';
%infilenam='fcst';    dirnam='cycle';  type=infilenam;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir='/SAS011/pwin/201work/plot_cal/largens/';
%---
varinam='TPW-qv histogram';    filenam=[expri,'_TPWqv-hist_'];  
g=9.81;    
TPW=zeros(memsize,1);
range=55:80;
  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
   for mi=1:memsize
%---set filename---
      nen=num2str(mi,'%.3d');
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
      varid  =netcdf.inqVarID(ncid,'QVAPOR');    q  =netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'P');         p  =netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'PB');        pb =netcdf.getVar(ncid,varid); 
      netcdf.close(ncid);
%---integrate TPW---       
      P=(pb+p);   [nx ny nz]=size(q);
      dP=P(px,py,1:nz-1)-P(px,py,2:nz);    
      tpw= dP.*( (q(px,py,2:nz)+q(px,py,1:nz-1)).*0.5 ) ;    
      TPW(mi)=sum(tpw,3)./g;       
   end  %member
   %--histogram
   hi=cal_histc(TPW,range);  hi=hi./length(TPW).*100;
%---plot
   len=length(range)+1;
   
   figure('position',[100 500 880 490]) 
   hb=bar(1:len,hi);    colormap([0.5 0.87 0.96]);
   text(1,max(hi),['lon=',num2str(x(px,py))]);    text(1,max(hi)-max(hi)*0.03,['lat=',num2str(y(px,py))])
   %   
   set(gca,'fontsize',13,'XLim',[0 len+1],'XTick',0.5:len+0.5,'XTickLabel',[-inf,range,inf])
   set(gca,'YLim',[0 max(hi)+1])
   xlabel('qv integral','fontsize',14);   ylabel('number(%)','fontsize',14);
   %
   tit=[varinam,'  ',s_hr,minu,'z (mem',num2str(memsize),', ',type,')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,minu,'_',num2str(px),num2str(py),'_',type,'_m',num2str(memsize)];
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]);  
end  %ti


