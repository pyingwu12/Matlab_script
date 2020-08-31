clear;  ccc=':';
close all
%---setting
filt_len=[1 3 5:10:300]; %unit:km  
expri='ens09';   stdate=21;  sth=23;  lenh=16;
year='2018'; mon='06';  minu='00';  dom='01';  ensize=10; 
dirmem='pert'; infilenam='wrfout';  
tint=1;

indir=['/mnt/HDD007/pwin/Experiments/expri_ens200323/',expri];
outdir=['/mnt/e/figures/ens200323/',expri];
%
titnam='Ensemble similarity of hourly rainfall';   fignam=[expri,'_accum-simi_'];
col_ncl_WBGYR254;
col=color_map([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:)/255;

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
%---set ticks of legend---
nti=0;  ss_hr=cell(length(sth:tint:sth+lenh-1),1);
for ti=sth:tint:sth+lenh-1
  nti=nti+1;  jti=ti+9;  
  ss_hr{nti}=[num2str(mod(jti,24),'%2.2d'),'00 JST'];
end

%---plot---
hf=figure('position',[100 30 1000 600]) ;
for ti=1:tint:lenh
plot(filt_len,simi(:,ti),'LineWidth',2.5,'Color',col(ti,:)); hold on
end
legend(ss_hr,'Location','BestOutside','box','off')

xlabel('wave length (km)','fontsize',16)
 set(gca,'YDir','reverse','Linewidth',1.2,'fontsize',15)
 set(gca,'XScale','log','Xlim',[1 max(filt_len)])
 set(gca,'YScale','log','Ylim',[0.1 2])
%---
tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)
outfile=[outdir,'/',fignam,num2str(sth),minu,'_',num2str(lenh),'h'];
 print(hf,'-dpng',[outfile,'.png']) 
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
 
 