% function DTE_2D_twin(expri)
%------------------------------------------
% plot vertical weighted average MDTE or CMDTE between two simulations
%------------------------------------------
close all
clear;   ccc='-';
saveid=1; % save figure (1) or not (0)
%---
plotid='CMDTE';  %optioni: MDTE or CMDTE
expri='TWIN201'; 
expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
day=23;    hr=2;  minu=50;  
%
tpwid=0.7;  % for tpwid~=0, plot contour of TPW = <tpwid> (kg/m^2)
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='E:expri_twin';   outdir=['D:/figures/expri_twin/',expri];
titnam=plotid;   fignam=[expri1,'_tpw_',];
%---

%---
for ti=hr    
  s_date=num2str(day+fix(ti/24),'%2.2d');    s_hr=num2str(mod(ti,24),'%2.2d');   
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    hgt = ncread(infile2,'HGT');
    %
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE'));   
     P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
      hyd  = qr+qc+qg+qs+qi;   
      dP=P(:,:,1:end-1)-P(:,:,2:end);
      tpw= dP.*( (hyd(:,:,2:end)+hyd(:,:,1:end-1)).*0.5 ) ;
      TPW2=squeeze(sum(tpw,3)./9.81);   
      

      %---
     qr = double(ncread(infile1,'QRAIN'));   
     qc = double(ncread(infile1,'QCLOUD'));
     qg = double(ncread(infile1,'QGRAUP'));  
     qs = double(ncread(infile1,'QSNOW'));
     qi = double(ncread(infile1,'QICE'));   
     P=double(ncread(infile1,'P')+ncread(infile1,'PB')); 
      hyd  = qr+qc+qg+qs+qi;   
      dP=P(:,:,1:end-1)-P(:,:,2:end);
      tpw= dP.*( (hyd(:,:,2:end)+hyd(:,:,1:end-1)).*0.5 ) ;
      TPW1=squeeze(sum(tpw,3)./9.81);   


    %---plot---  
    hf=figure('position',[100 75 750 700]); 
    %---
    contour(TPW2',[tpwid tpwid],'color',[0.3 0.3 0.3],'linewidth',2.4); hold on 
    contour(TPW1',[tpwid tpwid],'color',[0.4 0.7 0.9],'linewidth',1.5); 
    %---
    if (max(max(hgt))~=0)
     hold on; contour(hgt',[100 500 900],'color',[0.45 0.45 0.45],'linestyle','--','linewidth',2.5); 
    end
    %---
%     set(gca,'fontsize',18,'LineWidth',1.2)
    set(gca,'fontsize',24,'LineWidth',2) 
%     set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
        set(gca,'Xtick',50:50:250,'Ytick',50:50:250)

        set(gca,'fontsize',24,'LineWidth',2) 
    xlabel('(km)'); ylabel('(km)');
    %---
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % JST time string
    s_datej=num2str(day+fix((ti+9)/24),'%2.2d'); 
%       if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1,[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' LT']}; 
    title(tit,'fontsize',20,'Interpreter','none')
    
    %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    if saveid==1
      print(hf,'-dpng',[outfile,'.png']) 
%       system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
    end
  end %tmi
end
