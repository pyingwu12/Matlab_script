% close all; 
clear;   ccc=':';

%---setting
expri='TWIN001B';  

stday=22;   sth=23;   lenh=10;  minu=0:10:50;   tint=2;
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri];  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%
titnam='Convective intensity';   fignam=[expri,'_Con_Ts_'];
%
nminu=length(minu);  ntime=lenh*nminu;

%---
nti=0; ntii=0;  ss_hr=cell(length(tint:tint:lenh),1);

for ti=1:lenh 
  hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
  s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
  if mod(ti,tint)==0 
    ntii=ntii+1;    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
  end   
  for tmi=minu 
    nti=nti+1;     s_min=num2str(tmi,'%2.2d');       
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---
    if hr==23 && tmi==50        
      infile_r=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',num2str(stday+hrday+1,'%2.2d'),'_',num2str(0,'%2.2d'),ccc,num2str(0,'%2.2d'),ccc,'00'];      
    elseif tmi==50
      infile_r=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',num2str(hr+1,'%2.2d'),ccc,num2str(0,'%2.2d'),ccc,'00'];      
    else
      infile_r=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,num2str(tmi+10,'%2.2d'),ccc,'00'];
    end
    %---
     p = ncread(infile,'P');p=double(p);
    pb = ncread(infile,'PB');pb=double(pb);  
    %---    
      qr = double(ncread(infile,'QRAIN'));   
      qc = double(ncread(infile,'QCLOUD'));
      qg = double(ncread(infile,'QGRAUP'));  
      qs = double(ncread(infile,'QSNOW'));
      qi = double(ncread(infile,'QICE')); 
       hyd=qr+qc+qg+qs+qi;   
      hyd2D = sum(hyd,3);
      
      [nx, ny, nz]=size(hyd);
      %---
      P=(pb+p);  dP=P(:,:,1:nz-1,:)-P(:,:,2:nz,:);
    tpw= dP.*( (hyd(:,:,2:nz,:)+hyd(:,:,1:nz-1,:)).*0.5 ) ;
    TPW=squeeze(sum(tpw,3)./9.81);

      %---
%       zh_max=cal_zh_cmpo(infile,'WSM6');
      %---
      raina = ncread(infile,'RAINC');
      raina = raina + ncread(infile,'RAINSH');
      raina = raina + ncread(infile,'RAINNC');
       rainb = ncread(infile_r,'RAINC');
       rainb = rainb + ncread(infile_r,'RAINSH');
       rainb = rainb + ncread(infile_r,'RAINNC');
       rain=double(rainb-raina);
      %---
      
      TPW075(nti) = length( TPW(TPW>0.75) ) / (nx*ny) *100 ;
      TPW05(nti) = length( TPW(TPW>0.5) ) / (nx*ny) *100 ;
      TPW1(nti) = length( TPW(TPW>1) ) / (nx*ny) *100 ;
      
      cld5(nti) = length( hyd2D(hyd2D>0.005) ) / (nx*ny) *100 ;
      cld3(nti) = length( hyd2D(hyd2D>0.003) ) / (nx*ny) *100 ;  
      cld1(nti) = length( hyd2D(hyd2D>0.001) ) / (nx*ny) *100 ;  
%       cld05(nti) = length( hyd2D(hyd2D>0.0005) ) / (nx*ny) *100 ;  
 
%       zh1(nti) = length( zh_max(zh_max>1) ) / (nx*ny) *100 ;  
%       zh5(nti) = length( zh_max(zh_max>5) ) / (nx*ny) *100 ;  
      
%       rain0(nti) = length( rain(rain+1>1) ) / (nx*ny) *100 ; 
      rain01(nti) = length( rain(rain>0.1) ) / (nx*ny) *100 ;  
      rain002(nti) = length( rain(rain>0.02) ) / (nx*ny) *100 ;  

%       rain05(nti) = length( rain(rain>0.5) ) / (nx*ny) *100 ; 
      
      rain_max(nti) = max(max(rain)) ;  
      rain_mean(nti) = mean(mean(rain)) ;  
      
      
%{
      if ~isempty(hyd2D(hyd2D>0.005))          
        %---find max cloud area in the sub-domain---        
        rephyd=repmat(hyd2D,3,3);      
        BW = rephyd > 0.005;  
        stats = regionprops('table',BW,'Area','Centroid');     
%         [cgn, ~]=max(stats.Area);   
%         max_cld5(nti) = ((cgn/pi)^0.5)*2;
        max_cld5(nti) =  max(stats.Area) /  (nx*ny) *100;
      end
      
      if ~isempty(hyd2D(hyd2D>0.003))          
        %---find max cloud area in the sub-domain---        
        rephyd=repmat(hyd2D,3,3);      
        BW = rephyd > 0.003;  
        stats = regionprops('table',BW,'Area','Centroid');     
%         [cgn, ~]=max(stats.Area);   
%         max_cld3(nti) = ((cgn/pi)^0.5)*2;
         max_cld3(nti) =  max(stats.Area) /  (nx*ny) *100;
      end
      
      if ~isempty(hyd2D(hyd2D>0.001))          
        %---find max cloud area in the sub-domain---        
        rephyd=repmat(hyd2D,3,3);      
        BW = rephyd > 0.001;  
        stats = regionprops('table',BW,'Area','Centroid');     
%         [cgn, ~]=max(stats.Area);   
%         max_cld1(nti) = ((cgn/pi)^0.5)*2;
        max_cld1(nti) =  max(stats.Area) /  (nx*ny) *100;
      end
      %}
      
      
      
  end
  disp([s_hr,' done'])
end
 %%  
%---plot---       
hf=figure('position',[200 45 1000 600]);

plot(cld5,'linewidth',3,'color',[0.6350 0.0780 0.1840]); hold on
plot(cld3,'linewidth',3,'color',[0.85,0.325,0.098]);
plot(cld1,'linewidth',3,'color',[0.929,0.694,0.125]);
% plot(cld05,'linewidth',3);
% plot(zh1,'linewidth',3);
% plot(zh5,'linewidth',3);
% plot(rain0,'linewidth',3);
plot(rain01,'linewidth',3,'color',[0,0.447,0.741]);
plot(rain002,'linewidth',3,'color',[ 0.3,0.745,0.933]);
% plot(rain05,'linewidth',3,'color','r');
% plot(max_cld1,'linewidth',3);
% plot(max_cld3,'linewidth',3);
% plot(max_cld5,'linewidth',3);
plot(TPW1,'linewidth',3,'color',[0.066,0.374,0.088]);
plot(TPW075,'linewidth',3,'color',[0.466,0.674,0.188]);
plot(TPW05,'linewidth',3,'color',[0.566,0.90,0.688]);

ylabel('%') 

% yyaxis right
% % plot(rain_max,'linewidth',3,'color','k');
% plot(rain_mean,'linewidth',3,'color','r');

legend('cld5','cld3','cld1','rain01','rain002','TPW1','TPW075','TPW05','location','best','fontsize',18,'box','off','Interpreter','none')

% legend('cld5','cld3','cld1','cld05','rain002','rain01','max_cld1','max_cld3','max_cld5','rain_max','location','best','fontsize',18,'box','off','Interpreter','none')
% legend('cld5','cld1','cld05','zh1','zh5','rain0','rain01','rain05','location','best','fontsize',18,'box','off')

%
set(gca,'Linewidth',1.2,'fontsize',16,'box','on')
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
% set(gca,'Yscale','log')
xlabel('Local time');  
%---
tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
