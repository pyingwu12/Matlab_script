clear;  ccc=':';
close all
%---setting
filt_len=[1 3 5:5:300]; %unit:km  
expri='ens08';   stdate=21;  sth=16;  lenh=20;
year='2018'; mon='06';  minu='00';  dom='01';  ensize=10; 
dirmem='pert'; infilenam='wrfout';  
tint=2;

indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri,'/'];
%
titnam='Ensemble similarity of hourly rainfall';   fignam=[expri,'_accum-simi_'];

col=[
0.1    0.2    0.2;   0 0  0;
0      0.447  0.701; 0 0  0;
0.184, 0.284, 0.356; 0 0  0;
0.3,   0.745, 0.933;   0 0  0;

0.1    0.4   0.10;  0 0  0;
0.466, 0.674, 0.188;  0 0  0;

0.685  0.188  0.074; 0 0  0;
0.85,  0.325, 0.098; 0 0  0;
0.929  0.694  0.125; 0 0  0;
0.98   0.88   0.01; 0 0  0;];


simi=zeros(length(filt_len),lenh);
for ti=1:tint:lenh   
   var_mem=zeros(length(filt_len),1);
%---read ensemble data---
   for mi=1:ensize
      nen=num2str(mi,'%.2d');  
      for j=1:2
         hr=(j-1)+sth+ti-1;     
         hrday=fix(hr/24);  hr=hr-24*hrday;
         s_date=num2str(stdate+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');        
         %------read netcdf data--------
         infile=[indir,'/',dirmem,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
         rc{j} = ncread(infile,'RAINC');
         rsh{j} = ncread(infile,'RAINSH');
         rnc{j} = ncread(infile,'RAINNC');
      end %j=1:2
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1}+rsh{2}-rsh{1});
      if ti==1; [nx,ny]=size(rain); end
      if mi==1;  rain_sum=zeros(nx,ny,length(filt_len)); end           
      for fi=1:length(filt_len) 
         accum_filt=low_pass_filter(rain,filt_len(fi),1,1);   % filter
         var_mem(fi)=var_mem(fi)+var(reshape(accum_filt,nx*ny,1));
         rain_sum(:,:,fi)=rain_sum(:,:,fi)+accum_filt;
      end %filt_len
   end %mi
   %
   for fi=1:length(filt_len)
      var_sum=var(reshape(rain_sum(:,:,fi),nx*ny,1));
      simi(fi,ti)=var_mem(fi)/var_sum; 
   end %filt_len  
end  %ti
%%

ss_hr=cell(length(sth:tint:sth+lenh-1),1);
nti=0;  
for ti=sth:tint:sth+lenh-1
  jti=ti+9;  
  hrday=fix(jti/24);  hr=jti-24*hrday;
  nti=nti+1;  ss_hr{nti}=[num2str(hr,'%2.2d'),'00 JST'];
end

%---plot---
hf=figure('position',[-1300 30 1000 600]) ;
for ti=1:tint:lenh
plot(filt_len,simi(:,ti),'LineWidth',2.5,'Color',col(ti,:)); hold on
end
% for ti=1:tint:lenh
% plot(filt_len,simi(:,ti),'LineWidth',2); hold on
% end
legend(ss_hr,'Location','BestOutside')

xlabel('wave lenght (km)','fontsize',16)
%set(gca, 'YDir','reverse','Ylim',[0 1],'Linewidth',1.2,'fontsize',15)
set(gca,'YDir','reverse','Ylim',[0.08 2],'Linewidth',1.2,'fontsize',15)
set(gca,'Xlim',[1 100])
%set(gca,'XScale','log','YScale','log','Xlim',[1 300])
%---
tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)
outfile=[outdir,fignam,num2str(sth),minu,'_',num2str(lenh),'h'];
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
 
 