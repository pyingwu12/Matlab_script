function KEp_kh=cal_DTEmo_spectr(expri1, expri2, stday, hrs, minu, lev)
%------------------------------------------
% calculate spectrum of moDTE
%------------------------------------------
ccc=':';
year='2018';  mon='06';
infilenam='wrfout'; dom='01';   
%
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  
%---
cp=1004.9;
Lv=(2.4418+2.43)/2 * 10^6 ;
Tr=270;
%--- 
lenhr=length(hrs);
nti=0;
for ti=1:lenhr
  hr=hrs(ti);
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');   
  for mi=minu 
    nti=nti+1;
    s_min=num2str(mi,'%2.2d');     
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];    
    %---infile 1, perturbed state---
     u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');
     u.f1=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
     v.f1=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
     t.f=ncread(infile1,'T')+300;  t.f1=t.f(:,:,lev);
     qv.f=ncread(infile1,'QVAPOR');  qv.f1=double(qv.f(:,:,lev)); 
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');
     u.f2=(u.stag(1:end-1,:,lev)+u.stag(2:end,:,lev)).*0.5;
     v.f2=(v.stag(:,1:end-1,lev)+v.stag(:,2:end,lev)).*0.5; 
     t.f=ncread(infile2,'T')+300;  t.f2=t.f(:,:,lev);
     qv.f=ncread(infile2,'QVAPOR');  qv.f2=double(qv.f(:,:,lev)); 
    %---calculate different
    u.diff=u.f1-u.f2; 
    v.diff=v.f1-v.f2;
    t.diff=t.f1-t.f2;    
    qv.diff=qv.f1-qv.f2;
   %---calculate Kh from 2D wave numbers---  
   if nti==1
      [nx, ny, nzi]=size(u.diff); 
      cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2); %position of mean value after shfit
      nk=zeros(nx,ny);
      for xi=1:nx
        for yi=1:ny
         nk(xi,yi)=((xi-cenx)^2+(yi-ceny)^2)^0.5;        
        end    
      end   
      nk2=round(nk); 
      KEp_kh=zeros(max(max(nk2)),lenhr*length(minu));  
   end
  %---calculate---
    for li=1:nzi   
      u.perfft=fft2(u.diff(:,:,li));   
      v.perfft=fft2(v.diff(:,:,li));  
      t.perfft=fft2(t.diff(:,:,li));
      qv.perfft=fft2(qv.diff(:,:,li));
    %---calculate KE (power of the FFT)---
       KEp.twoD(:,:,li) = (abs(u.perfft).^2 + abs(v.perfft).^2 + cp/Tr*abs(t.perfft).^2 + Lv^2/cp/Tr*abs(qv.perfft).^2)/nx/ny ;          
    end %li=lev
    %--shift
    KEp.shi=fftshift(mean(KEp.twoD,3));   
    %---adjust 2D KE to 1D (wave number kh)---
    for ki=1:max(max(nk2))   
      KEp_kh(ki,nti)=sum(KEp.shi(nk2==ki));
    end

  end  
  disp([s_hr,' done'])  
end %ti