
%--------------------------------
% 
% x-axis: value of w (+or-); y-axis: height; color: time
%

close all
clear;   ccc=':';
%---setting


expri={'TWIN001Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
expnam={ 'FLAT';'V05H10';'V10H10';'V20H10'};
cexp=[ 0.1 0.1 0.1; 0.9216 0.6863 0.1255; 0.8627 0.3333 0.0980; 0.6275 0.0784 0.1765];
exptext='h1000';


 s_date='23'; hr=0; minu=00;  
%---
year='2018'; mon='06'; infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
%---
titnam='W';   fignam=['W-ver_',exptext,'_'];
%
g=9.81;
zgi=10:50:9000;   ytick=1000:1000:zgi(end);
nexp=size(expri,1);

rangx=1:150; rangy=26:175;

%---
for ei=1:nexp
  for ti=hr
    s_hr=num2str(ti,'%2.2d');      
    for mi=minu    
      %---set filename---
      s_min=num2str(mi,'%2.2d');
      infile=[indir,'/',expri{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---
      ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
      hgt = ncread(infile,'HGT');   
      w = double(ncread(infile,'W'));   
      %---    
       PH=phb+ph;   zg=double(PH)/g;      
      for i=rangx
        for j=rangy      
          w_iso(i,j,:)=interp1(squeeze(zg(i,j,:)),squeeze(w(i,j,:)),zgi,'linear');
        end
      end    
     
      for k=1:length(zgi)
        ww=w_iso(:,:,k);        
        w_p(k,ei) = mean(ww(ww>0));
        w_n(k,ei) = mean(ww(ww<0));        
      end
   %
    end %min
  end %ti
  disp([expri{ei},' done'])
end %nexp
%%
%---plot---
hf=figure('position',[45 300 800 680]);
    
for ei=1:nexp
  plot(w_p(:,ei),zgi,'color',cexp(ei,:),'linewidth',2);     hold on
end
for ei=1:nexp
  plot(w_n(:,ei),zgi,'color',cexp(ei,:),'linewidth',2)
end

set(gca,'fontsize',18,'LineWidth',1.2)    
    set(gca,'Ytick',ytick,'Yticklabel',ytick./1000)    

     ylabel('Height (km)')
    xlabel('W (m/s)');
    legend(expnam,'box','off','fontsize',18,'location','best')

%     set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
%     xlabel('(km)'); ylabel('(km)');
%     tit={[expri,'  ',s_hr,s_min,' UTC'];[titnam,'  ','(',num2str(p_int),'hpa)']};     
%     title(tit,'fontsize',18)
%   
%  
%     outfile=[outdir,'/',fignam,num2str(p_int),'hpa_',mon,s_date,'_',s_hr,s_min];
%    print(hf,'-dpng',[outfile,'.png']) 
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);