% close all; 
clear; ccc=':';

expri={'TWIN001';...
       'TWIN017';'TWIN013';'TWIN022';
       'TWIN025';'TWIN019';'TWIN024';
       'TWIN021';'TWIN003';'TWIN020';
       'TWIN023';'TWIN016';'TWIN018'
        };

%---setting 
ploterm='DTE'; % option: DTE, KE, ThE, LH

stday=22;   hrs=[23 24 25];  minu=[00 10 20 30 40 50];  
%
cloudhyd=0.005;  % threshold of definition of cloud area (Kg/Kg)
areasize=10;     % threshold of finding cloud area (gird numbers)
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';

nexp=size(expri,1); 

%---
for ei=1:nexp  
  expri1=[expri{ei},'Pr001qv062221'];  expri2=[expri{ei},'B'];  
  nti=0;  
  for ti=hrs 
  hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for mi=minu
      nti=nti+1;      s_min=num2str(mi,'%2.2d');     
      infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
      cloud=cal_cloudarea_1time(infile1,infile2,areasize,cloudhyd,ploterm); 
      if ~isempty(cloud)        
        maxcloudsize(ei,nti)=max(cloud.scale);
      else
        maxcloudsize(ei,nti)=NaN;
      end % if ~isempty(cloud)    
    end % mi
    disp([s_hr,s_min,' done'])
  end %ti
  disp([expri{ei},' done'])
end %ei
save('maxcloudsize_all.mat','maxcloudsize')