clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
%---set time---
sth=15:16;   acch=1;   dire='wrfout_morakot_MRzh_1500';  fre=zeros(100,1); mefre=zeros(100,1);
%---
for ti=sth
  s_sth=num2str(ti);
  for ai=acch
%---set filename---
    merain=zeros(198,198);
    for i=1:40;
      for j=1:2;
        h=(j-1)*ai+ti;
        if h==24
         s_date='09';   hr='00';
        else
         s_date='08';   hr=num2str(h);
        end       
        en=num2str(i);
        if i<=9
         infile=['/SAS004/pwin/',dire,'/wrfout_d03_2009-08-',s_date,'_',hr,':00:00_0',en];
        else
         infile=['/SAS004/pwin/',dire,'/wrfout_d03_2009-08-',s_date,'_',hr,':00:00_',en];
        end
%------read netcdf data--------
        ncid = netcdf.open(infile,'NC_NOWRITE');
        varid  =netcdf.inqVarID(ncid,'RAINC');
         rc{j}  =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'RAINNC');
         rnc{j} =netcdf.getVar(ncid,varid);
      end
%-----interpolation------
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
      merain=rain./40+merain;
      for k=71:140
        for l=41:160
          for h=1:100
            if rain(k,l)>=h && rain(k,l)<h+1  
             fre(h)=fre(h)+1;
            end
            if merain(k,l)>=h && merain(k,l)<h+1  
             mefre(h)=mefre(h)+1;
            end
          end        
        end
      end     

%------------    
    end % Member

    disp([s_sth,hr,' done'])
  end % accumulation interval
end % start hour


