function sprd=TPWqv_sprd_mean(hr,minu,year,mon,date,expri,memsize)
%-------------------------------------------------------
% Caculate spread of total Qv of an ensemble (horizontal mean)
%-------------------------------------------------------

%clear

%hr=18;   minu='00';   expri='largens';   memsize=10; year='2008'; mon='06'; date=15;
%---DA or forecast time---
infilenam='wrfout';    dirnam='pert';

%---experimental setting---
dom='02';   indir=['/SAS009/pwin/expri_largens/',expri]; 
%---set
addpath('/work/pwin/m_map1.4/')
%---
g=9.81;    
  
%---
sprd=zeros(length(hr),1);
nt=0;
for ti=hr;
   nt=nt+1;
   if ti>=24;  s_hr=num2str(ti-24,'%2.2d'); s_date=num2str(date+1,'%2.2d');  
   else        s_hr=num2str(ti,'%2.2d');    s_date=num2str(date,'%2.2d'); 
   end
   for mi=1:memsize
%---set filename---
      nen=num2str(mi,'%.3d');
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
       netcdf.close(ncid)
      [nx ny nz]=size(qv);
      if mi==1;    TPWmen=zeros(nx,ny,memsize);  end
%---integrate TPW---
      P=(pb+p);        dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
      tpw= dP.*( (qv(:,:,2:nz)+qv(:,:,1:nz-1)).*0.5 ) ;    
      TPWmen(:,:,mi)=sum(tpw,3)./g;      
   end  %member
%---
   A=reshape(TPWmen,nx*ny,memsize);     
   am=mean(A,2);     Am=repmat(am,1,memsize);
   Ap=A-Am; 
   varae=sum(Ap.^2,2)./(memsize-1);    
   sprd(nt)=sqrt(mean(varae));   
   disp([s_hr,' is ok'])
end  %ti
