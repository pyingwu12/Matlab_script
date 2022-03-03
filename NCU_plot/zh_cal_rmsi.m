function inno=zh_cal_rmsi(expdir,hm,day,dom,obsdir)

%------------------------------------------------------------------
% calculate root mean square innovation(rmsi) 
%          and mean innovation of ensemble mean in DA cycle
%------------------------------------------------------------------

%---experimental setting---
year=day(1:4); mon=day(5:6); date=day(7:8);    % time setting
obsdir=['/SAS004/pwin/data/',obsdir];  indir=['/work/pwin/data/',expdir]; 
%---set--- 
num=size(hm,1);

for ti=1:num;
  time=hm(ti,:);
%---read obs data---
  infile=[obsdir,'/obs_d03_',year,'-',mon,'-',date,'_',time,':00'];
  A=importdata(infile);   zho =A(:,9);   %hgt=A(:,7);  %irad=A(:,1); aza=A(:,3); dis=A(:,4);
  zho(zho==-9999)=NaN;
%---read model data (ensemble mean)---  
  for tyi=1:2     
    if tyi==1; type='fcst'; elseif tyi==2; type='anal'; end
    ni=2*(ti-1)+tyi;    
    %
    infile=[indir,'/',type,'mean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00']; 
    B=importdata(infile);   zh =B(:,9);
    zh(zh==-9999 )=NaN;   
    %---innovation---    
    inno_all=zho-zh;  
%    inno_all=inno_all(isnan(inno_all)~=1 & hgt<3000);    
    inno_all=inno_all(isnan(inno_all)~=1);    
    inno.mean(ni)=mean(inno_all);  
    inno.rmsi(ni)=( mean( inno_all.^2 ) )^0.5;  
    %    
  end  % fcst / anal  
  if strcmp(time(4:5),'00')==1; disp(['time ',time,' done']); end
end %time
% 

