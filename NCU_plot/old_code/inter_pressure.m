clear

target='member';
hr=18;
expri='MRcycle05';
indir=['/SAS002/pwin/expri_241/morakot_en_',expri];
%indir=['/SAS004/pwin/wrfout_morakot_',expri];
pre=950:-20:750; %hpa

for ti=hr
  s_hr=num2str(ti);  
  %infile=[indir,'/wrfout_d03_2009-08-08_',s_hr,':00:00_mean'];
     for mi=1:40
     nen=num2str(mi);
     if mi<=9
      infile=[indir,'/pert0',nen,'/wrfout_d03_2009-08-08_',s_hr,':00:00'];
      %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
     else
      infile=[indir,'/pert',nen,'/wrfout_d03_2009-08-08_',s_hr,':00:00'];
      %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
     end
%----read netcdf data--------
  ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');    u0 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');    v0 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'W');    w0 =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb =netcdf.getVar(ncid,varid); 

%----calculate wind U, V and Speed---
   [rangx rangy]=find(x>118.5 & x<123.5 & y>21.5 & y<26);
   [nx ny nz]=size(qv);
   u=(u0(1:nx,:,:)+u0(2:nx+1,:,:)).*0.5;
   v=(v0(:,1:ny,:)+v0(:,2:ny+1,:)).*0.5;   
   w=(w0(:,:,1:nz)+w0(:,:,2:nz+1)).*0.5;
   P0=(pb+p).*0.01;
   
   for i=rangx(1):rangx(length(rangx))
     for j=rangy(1):rangy(length(rangy))
       ni=i-rangx(1)+1; nj=j-rangy(1)+1; 
       x_p(ni,nj)=x(i,j); y_p(ni,nj)=y(i,j); 
       X=squeeze(P0(i,j,:));
       Y=squeeze(u(i,j,:));  u_p{mi}(ni,nj,:)=interp1(X,Y,pre,'linear');
       Y=squeeze(v(i,j,:));  v_p{mi}(ni,nj,:)=interp1(X,Y,pre,'linear');
       Y=squeeze(w(i,j,:));  w_p{mi}(ni,nj,:)=interp1(X,Y,pre,'linear');
       Y=squeeze(qr(i,j,:));  qr_p{mi}(ni,nj,:)=interp1(X,Y,pre,'linear');
       Y=squeeze(qv(i,j,:));  qv_p{mi}(ni,nj,:)=interp1(X,Y,pre,'linear');
     end
   end  
   netcdf.close(ncid)
   disp(['member ',nen,' OK'])
     end %member
   save([expri,'_isobaric_',s_hr,'_',target],'x_p','y_p','u_p','v_p','w_p','qr_p','qv_p','pre')
end

