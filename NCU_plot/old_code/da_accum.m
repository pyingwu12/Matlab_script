clear



load '/work/pwin/data/heighti.mat';
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---set---
s_sth='16'; s_edh='17';  s_min='45';
hm=['17:15';'17:30';'17:45';'17:00'];
indir='/SAS002/pwin/expri_241/morakot_newda_1518_vr_900';
num=size(hm,1);


%---
 for mi=1:40;   
   nen=num2str(mi);     
   rain=zeros(198,198);
   for ti=1:num
   time=hm(ti,:);
     if mi<=9
      infile=[indir,'/cycle0',nen,'/fcst_d03_2009-08-08_',time,':00'];
     else
      infile=[indir,'/cycle',nen,'/fcst_d03_2009-08-08_',time,':00'];
     end
%------read netcdf data--------
     ncid = netcdf.open(infile,'NC_NOWRITE');
     if mi==1 && ti==1
     varid  =netcdf.inqVarID(ncid,'XLONG');
      lon =netcdf.getVar(ncid,varid);
      x=double(lon);
     varid  =netcdf.inqVarID(ncid,'XLAT');
      lat =netcdf.getVar(ncid,varid);
      y=double(lat);
     end
     varid  =netcdf.inqVarID(ncid,'RAINC');
      rc  =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'RAINNC');
      rnc =netcdf.getVar(ncid,varid);
%-----interpolation------
     rain=rain+double(rc+rnc);
   end   
   acci{mi}=griddata(x,y,rain,xi,yj,'cubic');
%-----land-----
   for j=1:81
    for k=1:41
      if heighti(j,k)<=0. || isnan(heighti(j,k))==1 
       acci{mi}(j,k)=NaN;
      elseif acci{mi}(j,k)<0
       acci{mi}(j,k)=0;   
      end
    end
   end
%------------    
 netcdf.close(ncid)
 end % Member
%----    
   
   save(['acci_',s_sth,s_min,s_edh,s_min,'_da.mat'],'acci','xi','yj')
   
   