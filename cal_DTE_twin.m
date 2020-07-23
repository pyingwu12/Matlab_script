function mdte=cal_DTE_twin(expri1,expri2,stdate,sth,lenh,minu)
%clear;  
ccc=':';
%---
% expri1='twin02';  expri2='test94';
% stdate=21; sth=21;  lenh=16;  minu=[00 30];
year='2018'; mon='06'; 
dom='01';  infilenam='wrfout';  
%
indir=['/mnt/HDD003/pwin/Experiments/expri_test/'];
%
cp=1004.9;
Tr=270;

mdte=zeros(lenh*length(minu),1);
nti=0;
for ti=1:lenh 
   hr=sth+ti-1;
   hrday=fix(hr/24);  hr=hr-24*hrday;
   s_date=num2str(stdate+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
   for tmi=minu
     nti=nti+1;
     s_min=num2str(tmi,'%.2d');
     %---infile 1---
     infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     u.stag = ncread(infile1,'U');%u.stag=double(u.stag);
     v.stag = ncread(infile1,'V');%v.stag=double(v.stag);
     u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
     v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
     t.f1=ncread(infile1,'T')+300; 
     %---infile 2---
     infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     u.stag = ncread(infile2,'U');
     v.stag = ncread(infile2,'V');
     u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
     v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
     t.f2=ncread(infile2,'T')+300; 
     
     %---calculate different
     u.diff=u.f1-u.f2; 
     v.diff=v.f1-v.f2;
     t.diff=t.f1-t.f2;
     %---Different Total Energy----
     dte=1/2*(u.diff.^2+v.diff.^2+cp/Tr*t.diff.^2);
     mdte(nti)=mean(mean(mean(dte)));  
   end %tmi
  % if mod(ti,5)==0; disp([s_hr,' done']); end
end
