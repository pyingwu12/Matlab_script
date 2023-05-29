%
close all
clear;   ccc=':';
saveid=1;
%---setting
expri='TWIN030';
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B'];  
 
plotid='LH';  lev=1:33;

xsub=1:300;   ysub=1:300; 
cldtpw=0.7;
err_int=30; %interval for estimate the error growth for saturation time (min)
sat_ratio=0.01;
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01';  grids=1; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin'];
% indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam=['relative ',plotid,' spectra'];   fignam=[expri1(8:end),'_rel-',plotid,'_',];
%---
%
% load('/mnt/HDDA/Matlab_script/matfile/exp_statu.mat')
load('matfile/exp_statu.mat')

for i=1:size(exp_statu_saved,1)    
  if strcmp(exp_statu_saved.Exp_name{i},expri1)==1 && exp_statu_saved.cldtpw(i)==cldtpw && ...
            exp_statu_saved.err_int(i)==err_int  && exp_statu_saved.sat_ratio(i)==sat_ratio && ...
            exp_statu_saved.xsub1(i)==xsub(1)  && exp_statu_saved.xsub2(i)==xsub(end) && ...
            exp_statu_saved.ysub1(i)==ysub(1)  && exp_statu_saved.ysub2(i)==ysub(end)     
     err_sat_time=convertStringsToChars(exp_statu_saved.err_sat_time(i));
     first_cld_time=convertStringsToChars(exp_statu_saved.first_cld_time(i));
  end     
end
if exist('err_sat_time','var') == 0
    disp('Calculate <err_sat_time> and <first_cld_time>...')
    exp_statu=CalSave_status(cellstr(expri1),cellstr(expri2),err_int,cldtpw,sat_ratio,xsub,ysub); 
    %
    err_sat_time=convertStringsToChars(exp_statu.err_sat_time);
    first_cld_time=convertStringsToChars(exp_statu.first_cld_time);    
    exp_statu_saved=[exp_statu_saved; exp_statu];
%     save('matfile/exp_statu','exp_statu_saved')    
end
%%
%---saturatured time
s_date=err_sat_time(1:2); s_hr=err_sat_time(3:4);  s_min=err_sat_time(5:6);
  infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00']; 
  PowSpe=cal_spectr(infile1,infile2,lev);     
  eval(['DiffE_sat=PowSpe.diff',plotid,';'])
%
st=-4;  % start time for plot spectra. <-4> means for 4 hous before
first_cld_date=str2double(first_cld_time(1:2));
first_cld_hr=str2double(first_cld_time(3:4));
%
stday=first_cld_date+floor((first_cld_hr+st)/24); 
if mod(first_cld_hr+st,24)<21; sth=21; else; sth=mod(first_cld_hr+st,24); end
%
stmin=str2double(first_cld_time(5:6));

% stday=22; sth=21; stmin=20;
mint=30;  lenh=8;
ntime=lenh*(60/mint);
%%
nti=0; 
for tmi= stmin: mint: stmin+lenh*60-mint
  nti=nti+1;  
  s_min=num2str(mod(tmi,60),'%.2d');
  hr=sth+fix(tmi/60);  s_hr=num2str(mod(hr,24),'%2.2d'); 
  s_date=num2str(stday+fix(hr/24),'%2.2d');    
  if nti==1; stime=[num2str(mod(hr+9,24),'%2.2d'),s_min] ;  end
  %---infile---
  infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
  infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];   
    
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
     
  PowSpe=cal_spectr(infile1,infile2,lev);
  eval(['DiffE_spectr(:,nti)=PowSpe.diff',plotid,';'])

  if mod(nti,3)==0; disp([s_hr,s_min,' done']); end
end
[nx, ny, ~]=size(hyd);
%%

satratio=DiffE_spectr./ repmat(DiffE_sat',1,ntime) *100;
satratio(end,:)=0;
%
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl(6:30:end-30,:); cmap(1,:)=[0.9 0.9 0.9];  cmap(8,:)=[0.75 0.1 0];
L=[0 0.01 0.1 0.5 1 5 10];

%---plot
hf=figure('position',[100 45 930 660]) ;
%---
for ti=1:ntime
%   cgr(ti)  
  if cgr(ti)<=L(1)
    col=cmap(1,:);
  elseif cgr(ti)>L(end)
    col=cmap(length(L)+1,:);
  else    
    for k=1:length(L)-1
     if cgr(ti)>L(k) && cgr(ti)<=L(k+1); col=cmap(k+1,:); end
    end   
  end    
  plot(satratio(:,ti),'LineWidth',3.5,'LineStyle','-','color',col); hold on
end

%-------------
xlim=[1 min(nx,ny)]; 
ylim=[1e-4 3e2];
% %---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',18)
set(gca,'Ylim',ylim)
set(gca,'position',[0.1300 0.1100 0.78 0.8150])
xlabel('wavenumber'); ylabel('%')

%---colorbar---
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',16,'LineWidth',1.3);
  colormap(cmap); 
  ylabel(hc,'Cloud grid ratio (%)','fontsize',18)  
  set(hc,'position',[0.87 0.12 0.018 0.7150]);

%---second axis---
ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  %ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',18)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
 
text(6.5,2e-4,['start time: ',stime,' LT'],'fontsize',16)

%---
tit=[expri1,'  ',titnam,'  lev',num2str(lev(1),'%.2d'),'-',num2str(lev(end),'%.2d'),' mean'];     
title(tit,'fontsize',15)
%---
outfile=[outdir,'/',fignam,mon,num2str(stday),num2str(sth),num2str(stmin,'%.2d'),...
    '_',num2str(lenh),'h_m',num2str(mint),'_lev',num2str(lev(1),'%.2d'),num2str(lev(end),'%.2d')];
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end