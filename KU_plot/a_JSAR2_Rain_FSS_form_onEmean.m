function a_JSAR2_Rain_FSS_form_onEmean(expri,sth,acch)

close all
% clear; 
ccc=':';
saveid=1; % save figure (1) or not (0)
%---setting
% expri='TWIN003'; acch=6;  sth=[22 24 25];
expri2=[expri,'B'];  

thresholds=[1 5 10 30 50]; 
scales=[1 5 10 20 30 40 50];

stday=22;   s_minu='00';   
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin/JAS_R2';
% outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
% indir='D:expri_twin';   outdir=['G:/§Úªº¶³ºÝµwºÐ/3.³Õ¯Z/¬ã¨s/figures/expri_twin/',expri];
%---
titnam='Rainfall FSS';   fignam=[expri,'_rainFSSform-mean_'];
%
%---
for ti=sth
  s_sthj=num2str(mod(ti+9,24),'%2.2d');   s_sth=num2str(ti,'%2.2d');
  for ai=acch
    s_edhj=num2str(mod(ti+ai+9,24),'%2.2d');     
    %---cntl
    for j=1:2
      hr=(j-1)*ai+ti;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
      %------read netcdf data--------
      infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_minu,ccc,'00'];
      rall{j} = ncread(infile2,'RAINC');
      rall{j} = rall{j} + ncread(infile2,'RAINSH');
      rall{j} = rall{j} + ncread(infile2,'RAINNC');
    end %j=1:2
    rain2=double(rall{2}-rall{1}); 

    %---pert 1~5
    for mi=1:5
      if mi==1; expri1=[expri,'Pr001qv062221'];  else; expri1=[expri,'Pr001qv062221mem',num2str(mi)];   end 
      clear rall
      for j=1:2
      hr=(j-1)*ai+ti;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
      %------read netcdf data--------
      infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_minu,ccc,'00'];
      rall{j} = ncread(infile1,'RAINC');
      rall{j} = rall{j} + ncread(infile1,'RAINSH');
      rall{j} = rall{j} + ncread(infile1,'RAINNC');
      end %j=1:2
      rain1=double(rall{2}-rall{1});       
   
      %---calculate FSS
      for thi=1:length(thresholds)
        for scli=1:length(scales)
          if mi==1 && scli==1
          [fss(scli,thi,mi), fss_use(thi)]=cal_FSS(rain1,rain2,scales(scli),scales(scli),thresholds(thi));    
          else
          [fss(scli,thi,mi), ~]=cal_FSS(rain1,rain2,scales(scli),scales(scli),thresholds(thi));          
          end
        end
      end
    end %mi
    fss_mean=mean(fss,3);

    %%
    %---plot--- 
    hf=figure('position',[100 45 800 600]);
    imagesc(fss_mean);    
    colorbar; caxis([0 1]);  colormap(gray)
    % text
    for thi=1:length(thresholds)
    for scli=1:length(scales)
      if fss_mean(scli,thi)>fss_use(thi); textcol='k';  else;  textcol='w'; end       
      text(thi,scli,num2str(fss_mean(scli,thi),'%.3f'),'HorizontalAlignment','center','color',textcol,'fontsize',19,'FontWeight','bold')
    end
    end
    %
    set(gca,'fontsize',20,'LineWidth',1.2,'XTickLabel',thresholds,'YTickLabel',scales) 
    xlabel(['threshold (mm/',num2str(acch),'h)']); ylabel('scale (km)');
    %
    tit={expri;[titnam,'  ',s_sthj,s_minu,'-',s_edhj,s_minu,' LT']};
    title(tit,'fontsize',18)    
    %---
    outfile=[outdir,'/',fignam,num2str(ai),'h_',mon,num2str(stday),'_',s_sth,s_minu,...
        '_thi',num2str(length(thresholds)),num2str(thresholds(end)),'scl',num2str(length(scales)),num2str(scales(end))];
    if saveid==1
     print(hf,'-dpng',[outfile,'.png'])
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    end

  end %acch
end %ti
