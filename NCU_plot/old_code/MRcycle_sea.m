
clear;  sth=11; acch=1; min='00'; expri='0614e09'; tresh=3;

load '/work/pwin/data/heighti.mat';
%---set---
%indir=['/SAS002/pwin/expri_241/morakot_',expri,'/'];
%outdir=['/work/pwin/plot_cal/Rain/',expri,'/'];
indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_',expri,'mrcy/'];
outdir=['/work/pwin/plot_cal/IOP8/Rain/',expri,'/'];
msize=40;  
xmi=118; xma=120.1; ymi=21; yma=23.3; inx=561; iny=441;
%
%---
for ti=sth
  s_sth=num2str(ti);
  for ai=acch
%=======obs==========
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
%===wrf---set filename---
    for mi=1:msize;
      for j=1:2; 
        %for j=2;    %!!!!   
        hr=(j-1)*ai+ti;
        s_hr=num2str(hr);    
        nen=num2str(mi);
        if mi<=9
         infile=[indir,'cycle0',nen,'/wrfout_d02_2008-06-14_',s_hr,':',min,':00'];
         %infile=[indir,'cycle0',nen,'/oriout_d02_2008-06-14_',s_hr,':',min,':00'];
        else
         infile=[indir,'cycle',nen,'/wrfout_d02_2008-06-14_',s_hr,':',min,':00'];
         %infile=[indir,'cycle',nen,'/oriout_d02_2008-06-14_',s_hr,':',min,':00'];
        end
%------read netcdf data--------
        ncid = netcdf.open(infile,'NC_NOWRITE');
        varid  =netcdf.inqVarID(ncid,'XLONG');      lon =netcdf.getVar(ncid,varid);
         x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');       lat =netcdf.getVar(ncid,varid);
         y=double(lat);
        varid  =netcdf.inqVarID(ncid,'LANDMASK');   land =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'RAINC');
         %rc  =netcdf.getVar(ncid,varid);  
         rc{j}  =netcdf.getVar(ncid,varid);  %!!!!!
        varid  =netcdf.inqVarID(ncid,'RAINNC');
         %rnc =netcdf.getVar(ncid,varid); 
         rnc{j} =netcdf.getVar(ncid,varid);   %!!!!!
      end
%-----interpolation------
      %rain=double(rc+rnc);  
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});    %!!!!!          
      wrfacci{mi}=griddata(x,y,rain,obslon,obslat,'cubic');
      wrfacci{mi}(wrfacci{mi}<0)=0; 
%----   
    netcdf.close(ncid)
    end % Member
%-------  
    xi=obslon;  yj=obslat;
    save([outdir,'MRfcst_sea_',s_sth,s_hr,'.mat'],'wrfacci','obsacci','xi','yj')
  end % accumulation interval
end % start hour
%

for mi=1:msize
  obsacci2=    obsacci(xi>xmi & xi<xma & yj>ymi & yj<yma);
  wrfacci2=wrfacci{mi}(xi>xmi & xi<xma & yj>ymi & yj<yma);
  %fin=find(isnan(obsacci2) ==0 & isnan(wrfacci2)==0 & wrfacci2>=0 & obsacci2>=0);
  [scc(mi,1) rmse(mi,1) ETS(mi,1) bias(mi,1)]=score(obsacci2,wrfacci2,tresh); 
end %member 

[scc(:,2) scc(:,3)]=sort(scc(:,1));
[a b]=max(scc(:,1))
%}
%=====================
%{
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
    edh=ti+ai;
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    %infile=[outdir,'obs_acci_',s_sth,min,'_',s_edh,min,'.mat'];
    infile=[outdir,'MRfcst_sea_',s_sth,s_edh,'.mat'];
    load (infile);       
      for mi=1:msize
        obsacci2=    obsacci(xi>xmi & xi<xma & yj>ymi & yj<yma);
        wrfacci2=wrfacci{mi}(xi>xmi & xi<xma & yj>ymi & yj<yma);
        %fin=find(isnan(obsacci2) ==0 & isnan(wrfacci2)==0 & wrfacci2>=0 & obsacci2>=0);
        [scc(mi,1) rmse(mi,1) ETS(mi,1) bias(mi,1)]=score(obsacci2,wrfacci2,tresh); 
      end %member    
  end
end
[ETS(:,2) ETS(:,3)]=sort(ETS(:,1));
[scc(:,2) scc(:,3)]=sort(scc(:,1));
[a b]=max(scc(:,1))
%}