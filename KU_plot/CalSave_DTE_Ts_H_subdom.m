function CalSave_DTE_Ts_H_subdom(expri,xsub,ysub,hrs)

% calculate (interpolation) errors, hydrometeors to isohypsic surface for
% sub domain defined by input <xsub, ysub>
% save a file for each time
% plot time-height fiures by <DTEterms_Ts_H_One_load.m>

% clear; 
ccc=':';

%---setting 
% expri='TWIN001'; xsub=151:300;  ysub=51:200;
% expri='TWIN013';  xsub=1:150;  ysub=51:200;
% expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; outdir='./matfile/isoh_subdom';
expri1=[expri,'Pr0025THM062221'];  expri2=[expri,'B'];  outdir='./matfile/isoh_subdom_THM';
stday=22;    minu=0:10:50;    
% hrs=22:25;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  
g=9.81;         nx=length(xsub); ny=length(ysub);

%
nti=0;
for ti=hrs 
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  for mi=minu
    nti=nti+1;      s_min=num2str(mi,'%2.2d');     
    %---infile 1---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---  
tic 
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');  PH0=(phb+ph);  zg0=PH0/g; 
    PH=( PH0(:,:,1:end-1)+PH0(:,:,2:end) ).*0.5;   zg=PH/g; 
       
      zg_1D=squeeze(zg0(150,150,:));     
      if nti==1; nz=length(zg_1D); nzgi=nz*2-1; end
      zgi(1:2:nzgi,1)= zg_1D;   
      zgi(2:2:nzgi,1)= ( zg_1D(1:end-1) + zg_1D(2:end) )/2;   
      
      qr_sub1=zeros(nx,ny,nzgi); qc_sub1=zeros(nx,ny,nzgi); qi_sub1=zeros(nx,ny,nzgi);  qg_sub1=zeros(nx,ny,nzgi);   qs_sub1=zeros(nx,ny,nzgi);   
      qr_sub2=zeros(nx,ny,nzgi); qc_sub2=zeros(nx,ny,nzgi); qg_sub2=zeros(nx,ny,nzgi);  qs_sub2=zeros(nx,ny,nzgi);   qi_sub2=zeros(nx,ny,nzgi);   
      w_sub1=zeros(nx,ny,nzgi);  w_sub2=zeros(nx,ny,nzgi); 
      KE3D_sub=zeros(nx,ny,nzgi);     KE_sub=zeros(nx,ny,nzgi);    SH_sub=zeros(nx,ny,nzgi);     LH_sub=zeros(nx,ny,nzgi);
  
    qr1 = double(ncread(infile1,'QRAIN'));   
    qc1 = double(ncread(infile1,'QCLOUD'));
    qg1 = double(ncread(infile1,'QGRAUP'));  
    qs1 = double(ncread(infile1,'QSNOW'));
    qi1 = double(ncread(infile1,'QICE'));     
    w1 = double(ncread(infile1,'W'));    
    
    qr2 = double(ncread(infile2,'QRAIN'));   
    qc2 = double(ncread(infile2,'QCLOUD'));
    qg2 = double(ncread(infile2,'QGRAUP'));  
    qs2 = double(ncread(infile2,'QSNOW'));
    qi2 = double(ncread(infile2,'QICE'));     
    w2 = double(ncread(infile2,'W')); 
    
    [DTE, ~]=cal_DTEterms(infile1,infile2);               
   
    ni=0;
    for i=xsub
      ni=ni+1;
      nj=0;
      for j=ysub      
         nj=nj+1;
         qr_sub1(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qr1(i,j,:)),zgi,'linear');
         qc_sub1(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qc1(i,j,:)),zgi,'linear');
         qi_sub1(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qi1(i,j,:)),zgi,'linear');
         qg_sub1(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qg1(i,j,:)),zgi,'linear');
         qs_sub1(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qs1(i,j,:)),zgi,'linear');
         w_sub1(ni,nj,:)=interp1(squeeze(zg0(i,j,:)),squeeze(w1(i,j,:)),zgi,'linear');
         
         qr_sub2(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qr2(i,j,:)),zgi,'linear');
         qc_sub2(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qc2(i,j,:)),zgi,'linear');
         qi_sub2(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qi2(i,j,:)),zgi,'linear');
         qg_sub2(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qg2(i,j,:)),zgi,'linear');
         qs_sub2(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(qs2(i,j,:)),zgi,'linear');
         w_sub2(ni,nj,:)=interp1(squeeze(zg0(i,j,:)),squeeze(w2(i,j,:)),zgi,'linear');
         
         KE3D_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(DTE.KE3D(i,j,:)),zgi,'linear');
         KE_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(DTE.KE(i,j,:)),zgi,'linear');
         SH_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(DTE.SH(i,j,:)),zgi,'linear');
         LH_sub(ni,nj,:)=interp1(squeeze(zg(i,j,:)),squeeze(DTE.LH(i,j,:)),zgi,'linear');
      end
    end         
toc
      
    save([outdir,'/',expri1(1:7),'_',mon,s_date,'_',s_hr,s_min,'.mat'],...
        'qr_sub1','qc_sub1','qi_sub1','qg_sub1','qs_sub1','w_sub1',...
        'qr_sub2','qc_sub2','qi_sub2','qg_sub2','qs_sub2','w_sub2','KE3D_sub','KE_sub','SH_sub','LH_sub','zgi')

    disp([s_hr,s_min,' done'])
      
  end % tmi
end %ti    