%function iop8_QPESUMS_read(sth,acch,expri)
%sth=[18 21]; acch=3; textid=0; ctnid=0;  %test
% sth: start time
% acch: accumulation time
% texid: Mark max value when texid~=0
% ctnid: same colorbar maximum=ctnid when ctnid~=0

clear; sth=10; acch=2; expri='0614e01'; 
%---set---
indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_',expri]; 
outdir=['/work/pwin/plot_cal/IOP8/Rain/',expri];  
inx=561; iny=441;
%---
for ti=sth 
  s_sth=num2str(ti);
  for ai=acch           
%===============obs==================    
%---read and add data---
    for j=1:ai
      hr2=num2str(ti+j);  hr1=num2str(ti+j-1);      
      infile=['/SAS004/pwin/data/obs_rain/qpedata0614/20080614_',hr1,hr2,'_qpesums.dat'];   
      B=importdata(infile);  obsrain(:,j)=B(:,3); 
      fin= obsrain(:,j)<0; obsrain(fin,j)=0;      
    end
    obsacc=sum(obsrain,2);
    n=0;
     for j=1:inx
      for k=1:iny
         n=n+1;
         obsacci(j,k)=obsacc(n);
         obslon(j,k)=B(n,1);
         obslat(j,k)=B(n,2);
      end
     end    
     obsacci=obsacci(1:2:inx,1:2:iny); obslon=obslon(1:2:inx,1:2:iny);  obslat=obslat(1:2:inx,1:2:iny);   
     obsacci(obsacci<0)=0;     
 %=====wrf---set filename---
    for mi=1:40;
      for j=1:2;
        hr=(j-1)*ai+ti;
        if hr==24
         s_date='15';  s_hr='00';
        else
         s_date='14';  s_hr=num2str(hr);
        end       
        nen=num2str(mi,'%2.2d');
        infile=[indir,'/pert',nen,'/wrfout_d02_2008-06-',s_date,'_',s_hr,':00:00'];  
%------read netcdf data--------
        ncid = netcdf.open(infile,'NC_NOWRITE');
        varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);      x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);      y=double(lat);
        varid  =netcdf.inqVarID(ncid,'RAINC');   rc{j}  =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'RAINNC');  rnc{j} =netcdf.getVar(ncid,varid);
      end
%-----interpolation------
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});      
      wrfacci{mi}=griddata(x,y,rain,obslon,obslat,'cubic');
      wrfacci{mi}(wrfacci{mi}<0)=0; 
%------------    
      netcdf.close(ncid)
    end % Member           
%========================
     acci=wrfacci; xi=obslon; yj=obslat; 
     save([outdir,'/qpe_acci_',s_sth,s_hr,'.mat'],'wrfacci','obsacci','xi','yj')
     save([outdir,'/sea_acci_',s_sth,s_hr,'.mat'],'acci','xi','yj')
     disp([expri,'"s ',s_sth,s_hr,'Z done'])
    %}
  end
end