

%{
sth=16; acch=1; min='00'; expri='morakot_MRcycle06';

load '/work/pwin/data/heighti.mat';
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---set---
indir=['/SAS002/pwin/expri_241/',expri,'/'];
%---
for ti=sth
  s_sth=num2str(ti);
  for ai=acch
%===wrf---set filename---
    for mi=1:40;
      for j=1:2;
        hr=(j-1)*ai+ti;
        s_hr=num2str(hr);    
        nen=num2str(mi);
        if mi<=9
         infile=[indir,'cycle0',nen,'/wrfout_d03_2009-08-08_',s_hr,':',min,':00'];
        else
         infile=[indir,'cycle',nen,'/wrfout_d03_2009-08-08_',s_hr,':',min,':00'];
        end
%------read netcdf data--------
        ncid = netcdf.open(infile,'NC_NOWRITE');
        varid  =netcdf.inqVarID(ncid,'XLONG');
         lon =netcdf.getVar(ncid,varid);
         x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');
         lat =netcdf.getVar(ncid,varid);
         y=double(lat);
        varid  =netcdf.inqVarID(ncid,'RAINC');
         rc{j}  =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'RAINNC');
         rnc{j} =netcdf.getVar(ncid,varid);
      end
%-----interpolation------
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
      wrfacci{mi}=griddata(x,y,rain,xi,yj,'cubic');
%-----land-----
      for j=1:81
        for k=1:41
          if heighti(j,k)<=0. || isnan(heighti(j,k))==1 
           wrfacci{mi}(j,k)=NaN;
          elseif wrfacci{mi}(j,k)<0
           wrfacci{mi}(j,k)=0;   
          end
        end
      end
%------------    
    netcdf.close(ncid)
    end % Member
    
%===obs===read and add data
      for j=1:ai        
        hr1=num2str(ti+j-1);
        if ti+j==24; hr2='00'; else hr2=num2str(ti+j); end      
        infile=['/SAS004/pwin/obs_rain/obs_1hr_',hr1,min,'_',hr2,min,''];
        A=importdata(infile);  obsrain(:,j)=A(:,3);      
      end
      acc=sum(obsrain,2);
      lat=A(:,1);  lon=A(:,2);
%---interpolate and land---
      obsacci=griddata(lon,lat,acc,xi,yj,'cubic');
      for j=1:81
        for k=1:41
          if heighti(j,k)<=0. || isnan(heighti(j,k))==1 || obsacci(j,k)<0
           obsacci(j,k)=NaN;
          end
        end
      end
      save(['obs_acci_',s_sth,min,'_',s_hr,min,'.mat'],'wrfacci','obsacci')
%-------  
  end % accumulation interval
end % start hour


for mi=1:40
  fin=find(isnan(obsacci) ==0 & isnan(wrfacci{mi})==0 & wrfacci{mi}>=0 & obsacci>=0);
  [scc(mi,1) rmse(mi,1)]=score(obsacci(fin),wrfacci{mi}(fin)); 
end %member 

[scc(:,2) scc(:,3)]=sort(scc(:,1));
[a b]=max(scc(:,1))
%}
%=====================
%
sth=16; acch=1; min='00';
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    infile=['obs_acci_',s_sth,min,'_',s_edh,min,'.mat'];
    load (infile);       
      for mi=1:40
        fin=find(isnan(obsacci) ==0 & isnan(wrfacci{mi})==0 & wrfacci{mi}>=0 & obsacci>=0);
        [scc(mi,1) rmse(mi,1)]=score(obsacci(fin),wrfacci{mi}(fin)); 
      end %member 
    %save([expdir,'/score/score_',s_sth,s_edh,'.mat'],'scc','rmse')
  end
end
[scc(:,2) scc(:,3)]=sort(scc(:,1));
[a b]=max(scc(:,1))
%}