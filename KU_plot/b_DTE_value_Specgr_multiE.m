%------------------------------------------
% calculate power spectra of different terms in moist different total engergy 
%------------------------------------------
% close all
clear;  ccc=':';
saveid=1;
%---

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
    
    
expnam={'FLAT';
        'H500\_V05';'H500';'H500\_V20';
        'H750\_V05';'H750';'H750\_V20';
        'V05';'TOPO';'V20';
        'H2000\_V05';'H2000';'H2000\_V20'};      
exptext='TOPOall';
fignam=['Error-bar_',exptext,'_'];


day=22;  hrs=22:30;  minu=00:10:50;

cldtpw=0.7;
cgrthresh=0.125;

%--
year='2018';  mon='06';
infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin'; outdir='/mnt/e/figures/expri_twin';

%---
nexp=size(expri1,1);  nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%---
%
%---
% lgnd=cell(lenhr*length(minu),1);  
for ei=1:nexp
  nti=0; ntii=1;
  cgrid=0;
  for ti=hrs
    hr=ti; s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    for mi=minu 
      s_min=num2str(mi,'%2.2d'); 
      nti=nti+1;    
      
      %---infile 1, perturbed state---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2, based state---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];     
      
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE'));      
      P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
      hyd  = qr+qc+qg+qs+qi;   
      dP=P(:,:,1:end-1)-P(:,:,2:end);
      tpw= dP.*( (hyd(:,:,2:end)+hyd(:,:,1:end-1)).*0.5 ) ;
      TPW=squeeze(sum(tpw,3)./9.81);   
      cgr = length(TPW(TPW>cldtpw)) / (size(TPW,1)*size(TPW,2))*100 ;   
        
      thresh=cgrthresh(ntii);
      
      if cgr>thresh
      cgrid=1;              

      
      [DTE2D]=cal_DTEterms_2D(infile1,infile2);
        CMDTE_m(ei)=mean(DTE2D.CMDTE(:));                             
        DiKE3D_m(ei)=mean(DTE2D.KE3D(:));            
        DiSH_m(ei)=mean(DTE2D.SH(:));        
        DiLH_m(ei)=mean(DTE2D.LH(:));  

          
      disp([s_hr,s_min,' done']); 
      
      end
        
      if cgrid==1; break; end
    end %mi    
    if cgrid==1; break; end
  end %ti
  disp([expri1{ei},' done'])  
end %ei

DTE_all(1,:)=CMDTE_m;
DTE_all(2,:)=DiLH_m;
DTE_all(3,:)=DiKE3D_m;
DTE_all(4,:)=DiSH_m;
%%
close all
hf=figure('position',[100 55 1200 900]);
% bar(DTE_all')
% legend('CMDTE','LH','KE','SH')
b=bar(DTE_all([4 2 3],:)',0.4,'stack','FaceColor',"flat",'EdgeColor',[0.3 0.3 0.3],'linewidth',1.2);
% b(1).CData=[246 215 150]/255;
% b(2).CData=[240 190 186]/255;
% b(3).CData=[151 171 125]/255;
b(1).CData=[253 228 178]/255;
b(2).CData=[216 196 221]/255;
b(3).CData=[161 216 228]/255;



legend('DiSH','DiLH','DiKE','box','off','fontsize',28)
% set(gca,'YScale','log')
set(gca,'fontsize',20,'tickdir','out')
set(gca,'Xticklabel',expnam,'linewidth',1.5,'Ylim',[-0.002 0.06])
xlabel('Experiments'); ylabel('J kg^-^1')  
xtickangle(50)
title(['cloud grid ratio= ',num2str(cgrthresh),' %'])

outfile=[outdir,'/',fignam,'cgrthresh',num2str(cgrthresh)];
if saveid==1
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end