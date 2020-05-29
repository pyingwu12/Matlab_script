function RMDTE_t=cal_DTE(expri,sth,lenh,minu,member)

ccc=':';
year='2018'; mon='06';  stdate=21;  
dom='01';  
dirmem='pert'; infilenam='wrfout';  
%
indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
cp=1004.9;
Tr=270;

%RMDTE_t=zeros(lenh*length(minu),1);
nti=0;
for ti=1:lenh 
   hr=sth+ti-1;
   hrday=fix(hr/24);  hr=hr-24*hrday;
   s_date=num2str(stdate+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
   for tmi=minu
     nti=nti+1;
     s_min=num2str(tmi,'%.2d');
     %---ensemble mean
     infile=[indir,'/mean/wrfmean_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     u.stag = ncread(infile,'U');%u.stag=double(u.stag);
     v.stag = ncread(infile,'V');%v.stag=double(v.stag);
     u.mean=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
     v.mean=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
     t.mean=ncread(infile,'T')+300; %t.mean=double(t.mean)+300;
     %--members
     if nti==1; [nx, ny, ~]=size(u.mean); end
     MDTE=zeros(nx,ny);
     for mi=member
      nen=num2str(mi,'%.2d');
      infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %------read netcdf data--------
      u.stag = ncread(infile,'U'); %u.stag=double(u.stag);
      v.stag = ncread(infile,'V'); %v.stag=double(v.stag);
      t.mem =ncread(infile,'T')+300; %t.mem=double(t.mem)+300;
      p = ncread(infile,'P');%p=double(p);
      pb = ncread(infile,'PB');%pb=double(pb);
      u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
      v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
      %---perturbation---
      u.pert=u.unstag - u.mean;
      v.pert=v.unstag - v.mean;
      t.pert=t.mem - t.mean;   
      P=(pb+p);     dP=P(:,:,2:end)-P(:,:,1:end-1);
      dPall=P(:,:,end)-P(:,:,1);
      dPm=dP./repmat(dPall,1,1,size(dP,3));
   
      DTE=1/2*(u.pert.^2+v.pert.^2+cp/Tr*t.pert.^2);
      MDTE=MDTE+sum(dPm.*DTE(:,:,1:end-1),3)./length(member);  
      RMDTE=MDTE.^0.5;
     end
     %RMDTE_t(nti)=mean(mean(RMDTE));
     RMDTE_t{nti}=RMDTE;
   end %tmi
   disp([s_hr,' done'])
end


