% calculate error and cloud grid ratio and max cloud area for all experiments
% !!! for specific sub-somain !!!
% P.Y. Wu @ 2021.06.12

close all; clear;  ccc=':';

cloudhyd=0.003;

expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
expri2={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'};  

%---
% stday=22;   hrs=[22 23 24 25 26];  minu=0:10:50;  
stday=22;   hrs=[21 22 23 24 25 26 27];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; 
%
nexp=size(expri1,1); 
%%
%---calculate---
for ei=1:nexp  
  %---decide sub-domain to find max cloud area---
  if contains(expri1{ei},'TWIN001')
      subx1=151; subx2=300; suby1=51; suby2=200;
  else    
      subx1=1; subx2=150; suby1=51; suby2=200;
  end  
  nti=0;
  for ti=hrs       
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');    
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];

      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D = sum(qr+qc+qg+qs+qi,3);  
      
      %---cloud grid ratio and error over sub-domain
      hyd2D_sub =hyd2D(subx1:subx2,suby1:suby2);     
      cgr(nti,ei) = length(hyd2D_sub(hyd2D_sub>cloudhyd)) / (size(hyd2D_sub,1)*size(hyd2D_sub,2)) *100 ;      
      %---
      if cgr(nti,ei)>0          
        %---find max cloud area in the sub-domain---
        [nx, ny]=size(hyd2D); 
        rephyd=repmat(hyd2D,3,3);      
        BW = rephyd > cloudhyd;  
        stats = regionprops('table',BW,'Area','Centroid');     
        centers = stats.Centroid;      
        fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1);     
        [cgn, ~]=max(stats.Area(fin));   
        max_cldarea(nti,ei) = ((cgn/pi)^0.5)*2;
      end
      
      %---
      [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
      CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   
      %----             
      error2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
       CMDTE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
       
      error2D = sum(dPm.*DTE.KE3D(:,:,1:end-1),3);     
       DiKE3D_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
       
      error2D = sum(dPm.*DTE.SH(:,:,1:end-1),3);     
       DiSH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
       
      error2D = sum(dPm.*DTE.LH(:,:,1:end-1),3);     
       DiLH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
      
    end % tmi
     disp([s_hr,s_min,' done'])
  end %ti    
  disp([expri2{ei},' done'])
end %ei

  nhr=length(hrs);  nminu=length(minu);
  s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
  
  outfile_tick=[num2str(cloudhyd),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];

save(['DTE_quantify/cgr_',outfile_tick,'.mat'],'cgr')
save(['DTE_quantify/maxcld_',outfile_tick,'.mat'],'max_cldarea')
save(['DTE_quantify/CMDTE_',outfile_tick,'.mat'],'CMDTE_m')
save(['DTE_quantify/DiKE3D_',outfile_tick,'.mat'],'DiKE3D_m')
save(['DTE_quantify/DiSH_',outfile_tick,'.mat'],'DiSH_m')
save(['DTE_quantify/DiLH_',outfile_tick,'.mat'],'DiLH_m')
