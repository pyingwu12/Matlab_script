%
% close all
clear;   ccc=':';


% expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN021B'; 'TWIN020B'}; 
% exptext='H1000';
% expnam={'FLAT';'TOPO';'V05';'V20'};
% cexp=[87 198 229; 242 135 0; 230 84 80; 239 144 185]/255; 


expri1={'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
expri2={'TWIN021B'; 'TWIN020B'}; 
exptext='V05V20';
expnam={'V05';'V20'};
cexp=[230 84 80; 239 144 185]/255; 

%---setting 
xsub=1:300;   ysub=1:300;

cldtpw=0.7;
err_int=30; %interval for estimate the error growth for saturation time (min)
sat_ratio=0.01;

lev=1:25;
%---
% s_date='23'; s_hr='05';  s_min='00';
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; 

%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';
titnam='Saturated error spectra';   fignam='DTEterms-satime_';

nexp=size(expri1,1);
%---
%
load('/mnt/HDDA/Matlab_script/matfile/exp_statu.mat')

for ei=1:nexp

for i=1:size(exp_statu_saved,1)    
  if strcmp(exp_statu_saved.Exp_name{i},expri1{ei})==1 && exp_statu_saved.cldtpw(i)==cldtpw && ...
            exp_statu_saved.err_int(i)==err_int  && exp_statu_saved.sat_ratio(i)==sat_ratio && ...
            exp_statu_saved.xsub1(i)==xsub(1)  && exp_statu_saved.xsub2(i)==xsub(end) && ...
            exp_statu_saved.ysub1(i)==ysub(1)  && exp_statu_saved.ysub2(i)==ysub(end)     
     err_sat_time=convertStringsToChars(exp_statu_saved.err_sat_time(i));
     first_cld_time=convertStringsToChars(exp_statu_saved.first_cld_time(i));
  end     
end

if exist('err_sat_time','var') == 0
    disp('Calculate <err_sat_time> and <first_cld_time>...')
    exp_statu=CalSave_status(cellstr(expri1{ei}),cellstr(expri2{ei}),err_int,cldtpw,sat_ratio,xsub,ysub);
 
    err_sat_time=convertStringsToChars(exp_statu.err_sat_time);
     first_cld_time=convertStringsToChars(exp_statu.first_cld_time);
    
    exp_statu_saved=[exp_statu_saved; exp_statu];
%     save('matfile/exp_statu','exp_statu_saved')
end
%
%---saturatured time
s_date=err_sat_time(1:2); s_hr=err_sat_time(3:4);  s_min=err_sat_time(5:6);


    infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00']; 
    PowSpe=cal_spectr(infile1,infile2,lev);     
    
%     eval(['DiffE_sat=PowSpe.diff',plotid,';'])
DiffLH_sat(:,ei)=PowSpe.diffLH;
DiffKE_sat(:,ei)=PowSpe.diffKE;
DiffSH_sat(:,ei)=PowSpe.diffSH;


end
vinfo = ncinfo(infile,'U10'); nx = vinfo.Size(1); ny = vinfo.Size(2); 
%%

% first_cld_date=str2double(first_cld_time(1:2));
% first_cld_hr=str2double(first_cld_time(3:4));

%   s_min=num2str(mod(tmi,60),'%.2d');
%   hr=sth+fix(tmi/60);  s_hr=num2str(mod(hr,24),'%2.2d'); 
%   s_date=num2str(stday+fix(hr/24),'%2.2d'); 
%     
%     nti=nti+1;     
%     %---infile---
%     infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
%     infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
%     
%      qr = double(ncread(infile2,'QRAIN'));   
%      qc = double(ncread(infile2,'QCLOUD'));
%      qg = double(ncread(infile2,'QGRAUP'));  
%      qs = double(ncread(infile2,'QSNOW'));
%      qi = double(ncread(infile2,'QICE'));      
%      P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
%   
%      hyd  = qr+qc+qg+qs+qi;   
%      dP=P(xsub,ysub,1:end-1)-P(xsub,ysub,2:end);
%      tpw= dP.*( (hyd(xsub,ysub,2:end)+hyd(xsub,ysub,1:end-1)).*0.5 ) ;
%      TPW=squeeze(sum(tpw,3)./9.81);   
%      cgr(nti) = length(TPW(TPW>cldtpw)) / (size(TPW,1)*size(TPW,2))*100 ;   
%      
%      PowSpe=cal_spectr(infile1,infile2,lev);
% %      eval(['DiffE_spectr(:,nti)=PowSpe.diff',plotid,';'])
% DiffLH_spectr=PowSpe.diffLH;
% 
% [nx, ny, ~]=size(hyd);
nx=300;
ny=300;

%%
%---plot
hf=figure('position',[100 45 930 660]) ;
%---
for ei=1:nexp
  plot(DiffLH_sat(:,ei),'LineWidth',3.5,'LineStyle','-','color',cexp(ei,:)); hold on
  plot(DiffKE_sat(:,ei),'LineWidth',3.5,'LineStyle','--','color',cexp(ei,:));
  plot(DiffSH_sat(:,ei),'LineWidth',3.5,'LineStyle','-.','color',cexp(ei,:));
end

%
%-------------
xlim=[1 nx]; 
ylim=[1e-2 3e5];
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
set(gca,'position',[0.1300 0.1100 0.78 0.8150])
xlabel('wavenumber'); ylabel('J kg^-^1')

%---second axis---
ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  %ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%}
%---
tit=[titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',15)
%---
outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr,s_min,'_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
% print(hf,'-dpng',[outfile,'.png']) 
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);