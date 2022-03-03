function dte=cal_DTE_twin(indir,expri1,expri2,ymd,sth,lenh,minu,ccc)

% calculate different total energy (DTE, Zhang 2007?) 
% defined as DTE=1/2(u_diff^2 + v_diff^2 + cp/Tr * T_diff^2 )
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!20/09/23 modified to DTE=1/2(u_diff^2 + v_diff^2 ) + cp/Tr * T_diff^2
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% cp: Specific heat capacity (J / Kg K)
% Tr: reference temparature 
% Lv: specific latent heat (J/Kg)

%---setting
if isempty(ccc); ccc=':'; end
year=ymd(1:4); mon=ymd(5:6); stday=str2double(ymd(7:8)); 
infilenam='wrfout'; dom='01';  

cp=1004.9;
Tr=287;

dte=cell(lenh*length(minu),1);
nti=0;
for ti=1:lenh    
  hr=sth+ti-1;
  hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  for tmi=minu
    nti=nti+1;
    s_min=num2str(tmi,'%.2d');
    %---infile 1---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u.stag = ncread(infile1,'U');    v.stag = ncread(infile1,'V');
    u.f1=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.f1=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    t.f1=ncread(infile1,'T')+300; 
    %---infile 2---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    u.stag = ncread(infile2,'U');    v.stag = ncread(infile2,'V');
    u.f2=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.f2=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5; 
    t.f2=ncread(infile2,'T')+300; 
    %
    %---calculate different
    u.diff=u.f1-u.f2; 
    v.diff=v.f1-v.f2;
    t.diff=t.f1-t.f2;
    %
    %---Different Total Energy----
    dte{nti}=1/2*(u.diff.^2+v.diff.^2 ) +cp/Tr*t.diff.^2;
  end %tmi
  if mod(ti,5)==0; disp([s_hr,' done']); end
end
