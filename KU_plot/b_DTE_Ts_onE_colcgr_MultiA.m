% close all; 
clear;   ccc=':';

%---setting
expri='TWIN001'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 

stday=22;   sth=21;   lenh=12;  minu=0:10:50;   tint=2;
% stday=22;   sth=23;   lenh=5;  minu=0:10:50;   tint=1;

cloudhyd=0.003;
%---
year='2018'; mon='06';  infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin/'; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='MDTE';   fignam=[expri,'_MDTE_Ts_areas_'];

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
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %
%     [~, CMDTE{nti}] = cal_DTE_2D(infile1,infile2) ;
    
    
          [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
%       MDTE = DTE.KE + DTE.SH + DTE.LH;            
      CMDTE3D = DTE.KE3D + DTE.SH + DTE.LH;   
      CMDTE{nti} = sum(dPm.*CMDTE3D(:,:,1:end-1),3) + DTE.Ps;
      
    %---
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D{nti} = sum(qr+qc+qg+qs+qi,3); 
      [nx, ny]=size(hyd2D);
  end
  disp([s_hr,' done'])
end
 %%  
  clear cgr_whole CMDTE_m_whole cgr  lgnd CMDTE_m
for ti=1:ntime
    
  cgr_whole(ti)= length(hyd2D{ti}(hyd2D{ti}>cloudhyd)) / (300*300) *100;  
  CMDTE_m_whole(ti)=mean(mean( CMDTE{ti} ));
  
  nai=0;  
  for xai=[0 50 100 150 200 250]  
    for yai=[0 50 100 150 200 250]
        
%   for xai=[0 100 200]  
%     for yai=[0 100 200]
                
      nai=nai+1;  
      
      xsub=xai+1:xai+150;  xsub(xsub>300)=xsub(xsub>300)-300;
      ysub=yai+1:yai+150;  ysub(ysub>300)=ysub(ysub>300)-300;
      
      hyd_sub= hyd2D{ti}(xsub, ysub);
      cgr(ti,nai)= length(hyd_sub(hyd_sub>cloudhyd)) / (150*150) *100;
      
      
      lgnd{nai}=['(',num2str(xai),' ,',num2str(yai),')'];
      
      CMDTE_m(ti,nai)=mean(mean(CMDTE{ti}(xsub, ysub)));
      
    end
  end         
end


   diff_ai=   mean( ((log10(CMDTE_m)  -  repmat(log10(CMDTE_m_whole)',1,nai) ).^2) ,1);



cmap_file=load('colormap/colormap_ncl.mat'); 
col=cmap_file.colormap_ncl(10:6:end,:); 
% col=cmap_file.colormap_ncl(10:26:end,:); 

 hf=figure('position',[200 60 1000 820]);
 for pti=1:size(cgr,2)
   plot(cgr(:,pti),'linewidth',3,'color',col(pti,:)); hold on 
 end 
 hold on 
 plot(cgr_whole,'linewidth',3,'color','k') 
 legend(lgnd,'location','best')
%%
 hf=figure('position',[200 60 1000 800]);
 for pti=1:size(cgr,2)
   plot(CMDTE_m(:,pti),'linewidth',3,'color',col(pti,:)); hold on 
 end
 hold on 
 plot(CMDTE_m_whole,'linewidth',3,'color','k') 
 legend(lgnd,'location','bestoutside') 
set(gca,'Linewidth',1.2,'fontsize',16,'box','on')
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
set(gca,'Yscale','log')

 s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_all'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

 %%
 clear cgr_whole CMDTE_m_whole cgr 
 xsub1=[1:100, 251:300]; ysub1=1:150;
 xsub2=151:300; ysub2=51:200;
 
 for ti=1:ntime
    
  cgr_whole(ti)= length(hyd2D{ti}(hyd2D{ti}>cloudhyd)) / (300*300) *100;  
  CMDTE_m_whole(ti)=mean(mean( CMDTE{ti} ));  
  
  hyd_sub= hyd2D{ti}(xsub1, ysub1);
  cgr_sub(ti)= length(hyd_sub(hyd_sub>cloudhyd)) / (150*150) *100;
  CMDTE_sub(ti)=mean(mean( CMDTE{ti}(xsub1, ysub1) ));  
  
  hyd_sub= hyd2D{ti}(xsub2, ysub2);
  cgr_sub2(ti)= length(hyd_sub(hyd_sub>cloudhyd)) / (150*150) *100;
  CMDTE_sub2(ti)=mean(mean( CMDTE{ti}(xsub2, ysub2) ));  
  
 end
hf=figure('position',[200 60 1000 700]);
plot(CMDTE_sub,'linewidth',3,'color','r'); hold on 
plot(CMDTE_sub2,'linewidth',3,'color','b'); hold on 
plot(CMDTE_m_whole,'linewidth',3,'color','k');

legend('new','ori','whole')

set(gca,'Linewidth',1.2,'fontsize',16,'box','on')
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
set(gca,'Yscale','log')

 s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_test2'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);

 %%
 
 %{
%---plot---       
liwd=6;
load('colormap/colormap_ncl.mat');  col=colormap_ncl(15:12:end,:);
L=[0.05 0.1 0.4 0.7 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];

hf=figure('position',[200 45 1000 600]);
plot_col_line(1:ntime,MDTE_m(:,1),cld_r(:,1),col,L,liwd)
plot_col_line(1:ntime,MDTE_m(:,2),cld_r(:,2),col,L,liwd)
% plot_col_line(1:ntime,MDTE_m(:,3),cld_r(:,3),col,L,liwd)


%---colorbar---
L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  colorbar('YTick',L1,'YTickLabel',L,'fontsize',13,'LineWidth',1.2);
  colormap(col)

%
set(gca,'Linewidth',1.2,'fontsize',16,'box','on')
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
set(gca,'Yscale','log')
xlabel('Local time'); ylabel('Jkg^-^1')  
%---
tit=[expri,'  ',titnam];     
title(tit,'fontsize',18)

s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%}
