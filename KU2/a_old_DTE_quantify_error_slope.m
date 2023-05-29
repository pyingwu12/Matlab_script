% quantatify the error growth
% P.Y. Wu @ 2021.06.12

close all; clear;  ccc=':';

expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
expri2={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'};  

cgr1 = 0;    cgr2 = 2;   
%
cloudhyd=0.001;
%---
stday=22;   hrs=[22 23 24 25 26];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
%
nexp=size(expri1,1); 

load('colormap/colormap_hot20.mat');   cmap=colormap_hot20([1 2 4 6 8 10 12 13 17 20],:);

%---plot
p1=zeros(nexp,1);

for ei=1:nexp  
  %---decide sub-domain to find max cloud area---
  if contains(expri1{ei},'TWIN001')
      subx1=151; subx2=300; suby1=51; suby2=200;
  else    
      subx1=1; subx2=150; suby1=51; suby2=200;
  end  
  nti=0;  cgr=0;
  for ti=hrs       
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');    
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D = sum(qr+qc+qg+qs+qi,3); 

      %---cloud grid ratio and error over sub-domain
      hyd2D_sub =hyd2D(subx1:subx2,suby1:suby2);     
      cgr = length(hyd2D_sub(hyd2D_sub>cloudhyd)) / (size(hyd2D_sub,1)*size(hyd2D_sub,2)) *100 ;      
      
      if cgr > cgr1 && p1(ei)==0   
         disp(['p1 time: ',s_hr,s_min])         
         p1(ei)=nti;         
         [DTE2D]=cal_DTEterms_2D(infile1,infile2);
           CMDTE_m(ei,1)=mean(mean(DTE2D.CMDTE(subx1:subx2,suby1:suby2)));                             
           DiKE3D_m(ei,1)=mean(mean(DTE2D.KE3D(subx1:subx2,suby1:suby2)));            
           DiSH_m(ei,1)=mean(mean(DTE2D.SH(subx1:subx2,suby1:suby2)));        
           DiLH_m(ei,1)=mean(mean(DTE2D.LH(subx1:subx2,suby1:suby2)));  
      end 
         
      if cgr > cgr2
         disp(['p2 time: ',s_hr,s_min])
         p2(ei)=nti;         
         [DTE2D]=cal_DTEterms_2D(infile1,infile2);
           CMDTE_m(ei,2)=mean(mean(DTE2D.CMDTE(subx1:subx2,suby1:suby2)));                             
           DiKE3D_m(ei,2)=mean(mean(DTE2D.KE3D(subx1:subx2,suby1:suby2)));            
           DiSH_m(ei,2)=mean(mean(DTE2D.SH(subx1:subx2,suby1:suby2)));        
           DiLH_m(ei,2)=mean(mean(DTE2D.LH(subx1:subx2,suby1:suby2)));         
        break          
      end
      
    end % tmi
    if cgr > cgr2;   break;    end   
  end %ti    
  disp([expri2{ei},' done'])
end %ei
%%

ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH'};

% for pi=1:size(ploterms,1)
for pi=[2 4 5 6]
  ploterm=ploterms{pi}; 
  %
  eval(['DiffE_m=',ploterm,'_m;'])
  slope_FLAT= (log10(DiffE_m(1,2)) - log10(DiffE_m(1,1)) )/ (p2(1)-p1(1));
  n=1;
  for h=1:4
    for v=1:3
      n=n+1;      
      slope(h,v)=(log10(DiffE_m(n,2)) - log10(DiffE_m(n,1)) )/ (p2(n)-p1(n)) ;
    end
  end
  plotvar=slope./slope_FLAT*100;
  
  %----------
  hf=figure('Position',[100 300 650 600]);
  imagesc(plotvar)
  hc=colorbar('linewidth',1.5,'fontsize',16,'Ytick',10:10:90);
  colormap(cmap);  caxis([0 100])
  title(hc,'%','fontsize',20)
  %---text--
  for h=1:size(slope,1)
    for v=1:size(slope,2)
      if plotvar(h,v)>50; textcol='k';  else;  textcol='w'; end       
      text(v,h,num2str(slope(h,v),'%.4f'),'HorizontalAlignment','center','color',textcol,'fontsize',20,'FontWeight','bold')
    end
  end
  %  
  set(gca,'linewidth',2,'fontsize',20)
  set(gca,'xtick',[1 2 3],'xticklabel',{'V05','V10','V20'},'ytick',[1 2 3 4],'yticklabel',{'H05','H075','H10','H20'})
  title(ploterm,'fontsize',25)

  fignam=[ploterm,'_slop_all_cld',num2str(cloudhyd),'_lim',num2str(cgr1),'-',num2str(cgr2)];  
  outfile=[outdir,'/',fignam];
  print(hf,'-dpng',[outfile,'.png'])
%   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end  

