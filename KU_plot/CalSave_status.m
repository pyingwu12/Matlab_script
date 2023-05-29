function exp_statu=CalSave_status(expri1,expri2,err_int,cldtpw,sat_ratio,xsub,ysub)

% Calculate the time of cloud grid formed and the saturation time
% Add the list to exp_statu_saved ('matfile/exp_statu')
% Mainly for plot relative error spectra (b_DTEterm_relative_spectr.m)
% 2021/10/16
%----------------------------------------
%
% close all
% clear; 
ccc=':';

% expri1={'TWIN042Pr001qv062221'   };
% expri2={'TWIN042B'     };     


% expri1={
% 'TWIN001Pr001qv062221';
%        'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
%        'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
%        'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
%        'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'
%         };
% expri2={
%     'TWIN001B';
%         'TWIN017B';'TWIN013B';'TWIN022B';
%         'TWIN025B';'TWIN019B';'TWIN024B';
%         'TWIN021B';'TWIN003B';'TWIN020B';       
%         'TWIN023B';'TWIN016B';'TWIN018B'
%         };     

%---setting 
% stday=22;  sth=21;  lenh=15;   minu=0:10:50;  
stday=23;  sth=0;  lenh=9;   minu=0:10:50;  


% err_int=30; %interval for estimate the error growth for saturation time (min)
% cldtpw=0.7;
% sat_ratio=0.01;
% 
% % xsub=151:300;   ysub=51:200;
% xsub=1:300;   ysub=1:300;

%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/';  

nexp=size(expri1,1); 


exp_statu=table('Size',[nexp 10],...
    'VariableNames',{'Exp_name','xsub1','xsub2','ysub1','ysub2','err_sat_time','err_int','sat_ratio','first_cld_time','cldtpw'},...
    'VariableTypes',{'string','double','double','double','double','string','double','double','string','double'});

exp_statu.Exp_name=expri1;
  exp_statu.xsub1=repmat(xsub(1),nexp,1);   
  exp_statu.xsub2=repmat(xsub(end),nexp,1); 
  exp_statu.ysub1=repmat(ysub(1),nexp,1);   
  exp_statu.ysub2=repmat(ysub(end),nexp,1);   
exp_statu.err_int=repmat(err_int,nexp,1);
exp_statu.sat_ratio=repmat(sat_ratio,nexp,1);
exp_statu.cldtpw=repmat(cldtpw,nexp,1);
%
for ei=1:nexp
  nti=0; sati=0;  cgrid=0;
  
  for ti=1:lenh  
    hr=sth+ti-1;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    for tmi=minu      
      nti=nti+1;     
      s_min=num2str(tmi,'%.2d');
      %---infile now---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
      
      [~,CMDTE] = cal_DTE_2D(infile1,infile2) ; 
      CMDTE_m=mean(mean(CMDTE(xsub,ysub)));
    
%       if cgrid==0
       qr = double(ncread(infile2,'QRAIN'));   
       qc = double(ncread(infile2,'QCLOUD'));
       qg = double(ncread(infile2,'QGRAUP'));  
       qs = double(ncread(infile2,'QSNOW'));
       qi = double(ncread(infile2,'QICE'));      
       P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
       hyd  = qr+qc+qg+qs+qi;   
       dP=P(xsub,ysub,1:end-1)-P(xsub,ysub,2:end);
       tpw= dP.*( (hyd(xsub,ysub,2:end)+hyd(xsub,ysub,1:end-1)).*0.5 ) ;
       TPW=squeeze(sum(tpw,3)./9.81);   
       cgr(nti) = length(TPW(TPW>cldtpw)) / (size(TPW,1)*size(TPW,2))*100 ;
       if cgr(nti)~=0 && cgrid==0
         exp_statu.first_cld_time(ei)=[s_date,s_hr,s_min];
         cgrid=1;
       end
%       else       
        minu30=tmi+err_int;
        s_min30=num2str(mod(minu30,60),'%.2d');
        s_hr30=num2str(mod(hr+fix(minu30/60),24),'%2.2d');
        s_date30= num2str(stday+fix((hr+fix(minu30/60))/24));    
        %---infile later---
        infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date30,'_',s_hr30,ccc,s_min30,ccc,'00'];
        infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date30,'_',s_hr30,ccc,s_min30,ccc,'00'];   
        [~,CMDTE] = cal_DTE_2D(infile1,infile2) ; 
        CMDTE_m30=mean(mean(CMDTE(xsub,ysub)));      
        if CMDTE_m30/CMDTE_m <= exp(sat_ratio)  && cgr(nti)>0.1
          disp(['saturation time: ',s_date,s_hr,s_min,' (for xsub=',num2str(xsub(1)),'-',num2str(xsub(end)),', ysub=',num2str(ysub(1)),'-',num2str(ysub(end)),')'])
          disp(['30min later: ',s_date30,s_hr30,s_min30])
          exp_statu.err_sat_time(ei)=[s_date,s_hr,s_min];         
          sati=1;    break
        end   
%       end  
         
    end  %tmi    
    disp([s_hr,s_min,' done']) 
    if sati~=0; break; end    
  end  %ti   
  
  disp([expri1{ei},' done'])
end

% LoadFile=load('matfile/exp_statu','exp_statu_saved');
% exp_statu_old=LoadFile.exp_statu_saved;
% exp_statu_save=[exp_statu_old; exp_statu];
% exp_statu_saved=exp_statu;
% save('matfile/exp_statu','exp_statu_saved')
