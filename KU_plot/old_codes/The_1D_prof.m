% close all
% clear; ccc=':';
%---setting
expri='TWIN001B';  stday=23; hrs=16:3:16+20;  minu=00;   
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  
%---
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
%---
titnam='Potential Temperature';   fignam=[expri,'_The1D_'];

%---

load('colormap/colormap_ncl.mat')
col0=colormap_ncl([36 49  70 81 97 114 129 147 151 155 160 166 172 179 186 ...
    191 197 202 206 210 216 222 225 230 234 236 241 246 251 254],:);
col=col0(1:3:end,:);


Rcp=287.43/1005; 
g=9.81;

%%

hf=figure('position',[100 45 600 800]);  
for ti=1:length(hrs)
  for mi=minu    
    hr=hrs(ti);
    hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    %---set filename---
       s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');   t=t+300;   
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');

    
    T_mean = squeeze(mean(mean(t,1),2));
    
    %---plot---
    
    plot(T_mean,1:49,'linewidth',2.5,'color',col(ti,:)); hold on
       
    %

  end
end


    set(gca,'fontsize',16,'LineWidth',1.2) 
    set(gca,'Ylim',[0 20])
%     xlabel('(km)'); ylabel('(km)');
%     tit={expri,[titnam,'  ',s_hr,s_min,' UTC']}; 
%     title(tit,'fontsize',18)
    
    %    
%     outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_h',num2str(height)];
%     print(hf,'-dpng',[outfile,'.png']) 
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);