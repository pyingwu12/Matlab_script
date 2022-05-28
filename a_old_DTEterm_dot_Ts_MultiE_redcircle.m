
% 'time' to 'error' over a specific range (decided by <rang>)
% use "center of a cloud area" to be the center of the specific range
%----------------
% Multi experiments; x-axis: time; y-axis: error; color: cloud ratio 
%----------------

close all;   clear;   ccc=':';

% expri1={'TWIN001Pr001qv062221';'TWIN013Pr001qv062221';'TWIN019Pr001qv062221';'TWIN003Pr001qv062221';'TWIN016Pr001qv062221'};
% expri2={'TWIN001B';'TWIN013B';'TWIN019B';'TWIN003B';'TWIN016B'};    
% expnam={ 'FLAT';'H500';'H750';'H1000';'H2000'};
% expmark={'s';'*';'p';'^';'o'};     
% cexp=[ 20 20 20; 20 20 20; 20 20 20; 20 20 20; 20 20 20 ]/255;
% exptext='vol10JpGU';

% expri1={'TWIN001Pr001qv062221';'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221'};
% exptext='h500';
% expri2={'TWIN001B';'TWIN017B';'TWIN013B';'TWIN022B'};    
% expnam={ 'FLAT';'V05H05';'V10H05';'V20H05'};
% expmark={'s';'o';'^';'p'};     
% cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7];

% expri1={'TWIN001Pr001qv062221';'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221'};
% exptext='h750';
% expri2={'TWIN001B';'TWIN025B';'TWIN019B';'TWIN024B'};    
% expnam={ 'FLAT';'V05H075';'V10H075';'V20H075'};
% expmark={'s';'o';'^';'p'};     
% cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7];
% 
% expri1={'TWIN001Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
% expri2={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'};    
% expnam={ 'FLAT';'V05H10';'V10H10';'V20H10'};
% expmark={'s';'o';'^';'p'};     
% cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7];
% exptext='h1000';
% 
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};
expri2={'TWIN001B';'TWIN003B'};    
expnam={ 'FLAT';'TOPO'};
expmark={'s';'^'};     
cexp=[ 0.1 0.1 0.1;  0.5 0.5 0.5];
exptext='exp0103';

% expri1={'TWIN001Pr001qv062221';'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
% expri2={'TWIN001B';'TWIN023B';'TWIN016B';'TWIN018B'};    
% expnam={ 'FLAT';'V05H20';'V10H20';'V20H20'};
% expmark={'s';'o';'^';'p'};     
% cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7];
% exptext='h2000';
% 
% expri1={'TWIN018Pr001qv062221'};
% expri2={'TWIN018B'};    
% expnam={'V20H20'};
% expmark={'p'};     
% cexp=[  0.7 0.7 0.7];
% exptext='TWIN018';

% expri1={'TWIN003Pr001qv062221'};
% expri2={'TWIN003B'};    
% expnam={ 'TOPO'};
% expmark={'^'};     
% cexp=[ 0.5 0.5 0.5];
% exptext='TOPO';

rang=30; 
cloudhyd=0.005;
lim_ratio=60;
%---
stday=22;   sth=22;   lenh=5;  minu=0:10:50;   tint=1;
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
%
nexp=size(expri1,1);  nminu=length(minu);  ntime=lenh*nminu;
%
loadfile=load('colormap/colormap_ncl.mat'); 
cmap0=loadfile.colormap_ncl(17:26:end-10,:); cmap=cmap0(1:7,:);
L=[0.1 0.5 1 5 10 20];

%---plot
for ei=1:nexp  
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      clear DTE
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D = sum(qr+qc+qg+qs+qi,3); 
      
  %---decide sub-domain to find max cloud area---
      if contains(expri1{ei},'TWIN001')
         subx1=200; subx2=300; suby1=100; suby2=200;
      else    
         subx1=25; subx2=125; suby1=75; suby2=175;
      end            
  %---find max cloud area in the sub-domain and its center---
      [nx, ny]=size(hyd2D); 
      rephyd=repmat(hyd2D,3,3);      
      BW = rephyd > cloudhyd;  
      stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');     
      if isempty(stats)~=1
        centers = stats.Centroid;      
        fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1);     
        if isempty(stats.Area(fin))~=1    
          [maxcldsize, maxcldid]=max(stats.Area(fin));      
          centers_fin=centers(fin,:);      
          cenx=centers_fin(maxcldid,2)-nx;
          ceny=centers_fin(maxcldid,1)-ny; 
%           disp(nti)
        end
      end
      %--- if there is no any cloud area over the whole domain and the sub-domain, find max DTE----
      if isempty(stats)==1 || isempty(stats.Area(fin))==1    
        [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
        MDTE = DTE.KE + DTE.SH + DTE.LH;      
        MDTE_2D = sum(dPm.*MDTE(:,:,1:end-1),3) + DTE.Ps;      
        [maxval, maxloc]=max(MDTE_2D(subx1+1:subx2,suby1+1:suby2));  [~, ceny0]=max(maxval);  cenx0=maxloc(ceny0); 
        cenx=subx1+cenx0-1; 
        ceny=suby1+ceny0-1; 
%         disp(nti)
      end
  %---calculate distance from the center of the selected cloud area----------
      [yi, xi]=meshgrid(1:ny,1:nx);
      yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
      yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
      xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
      xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
      dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5;        
      
      cldgnum=length(find(hyd2D+1>cloudhyd+1 & dis2topo<=rang)); 
      cldgptg{ei}(nti,1)=cldgnum/length(dis2topo(dis2topo<=rang))*100;  % Ratio of cloud grids in the specific range
      
  %--- calculate DTE when cldgptg < lim_ratio
      if  cldgptg{ei}(nti,1) > lim_ratio;    break;    end          
      if isempty(stats)~=1 && isempty(stats.Area(fin))~=1
        [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
        MDTE = DTE.KE + DTE.SH + DTE.LH;      
        MDTE_2D = sum(dPm.*MDTE(:,:,1:end-1),3) + DTE.Ps;             
      end
          
      MDTE_m(nti,ei)=double(mean(MDTE_2D(dis2topo<=rang))); 
         
      CMDTE = DTE.KE3D + DTE.SH + DTE.LH;     
      CMDTE_2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
       CMDTE_m(nti,ei)=double(mean(CMDTE_2D(dis2topo<=rang)));  
      error2D = sum(dPm.*DTE.KE(:,:,1:end-1),3);     
       DiKE_m(nti,ei)=double(mean(error2D(dis2topo<=rang)));  
      error2D = sum(dPm.*DTE.KE3D(:,:,1:end-1),3);     
       DiKE3D_m(nti,ei)=double(mean(error2D(dis2topo<=rang))); 
      error2D = sum(dPm.*DTE.SH(:,:,1:end-1),3);     
       DiSH_m(nti,ei)=double(mean(error2D(dis2topo<=rang)));   
      error2D = sum(dPm.*DTE.LH(:,:,1:end-1),3);     
       DiLH_m(nti,ei)=double(mean(error2D(dis2topo<=rang)));     
      error2D = DTE.Ps;     
       DiPs_m(nti,ei)=double(mean(error2D(dis2topo<=rang)));   
      
    end % tmi
    if  cldgptg{ei}(nti,1) > lim_ratio;    break;    end    
    disp([s_hr,s_min,' done'])
  end %ti  

  cldgptg{ei}( 1:find(cldgptg{ei}>=0.05,1)-5 ) =NaN;
  cldgptg{ei}( cldgptg{ei}>lim_ratio ) =NaN;
  
  disp([expri2{ei},' done'])
end %ei

%---set x tick (not all times are looped above)---
nti=0; ss_hr=cell(length(tint:tint:lenh),1);
for ti=tint:tint:lenh
  nti=nti+1;  
  ss_hr{nti}=num2str(mod(sth+ti-1+9,24),'%2.2d');
end
%%
%
ratio1=0.1; ratio2=10;
ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH';'DiPs'};
% ploterms={'DiPs'};
% for ploti=1:size(ploterms,1)
for ploti=2

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,'_',exptext,'_'];
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 900 600]);  
  %---plot slope line---
  for ei=1:nexp
    p1=find(cldgptg{ei}>ratio1,1);if p1==0; p1=1; end;  if DiffE_m(p1,ei)==0; p1=p1+1; end    
    p2=find(cldgptg{ei}>ratio2,1);
    line([p1 p2],[DiffE_m(p1,ei) DiffE_m(p2,ei)],'color',cexp(ei,:),'linewidth',3,'Linestyle','-.')     
    slope(ei)= (log10(DiffE_m(p2,ei)) - log10(DiffE_m(p1,ei)) )/ (p2-p1) ;
  end 
  %---plot points----
  hold on
  for ei=1:nexp
    plot_dot(1:ntime,DiffE_m(:,ei),cldgptg{ei},cmap,L,expmark{ei},12)
  end  
  %---plot black edge---
  for ei=1:nexp
    p1=find(cldgptg{ei}>0.1,1);if p1==0; p1=1; end;   if DiffE_m(p1,ei)==0; p1=p1+1; end 
    p2=find(cldgptg{ei}>5,1)*1;
    
    plot(p1,DiffE_m(p1,ei),expmark{ei},'Markeredgecolor','k','Markersize',12)
    plot(p2,DiffE_m(p2,ei),expmark{ei},'Markeredgecolor','k','Markersize',12)
  end
  %----
  set(gca,'yscale','log','fontsize',16,'LineWidth',1.2,'box','on')
  set(gca,'Xlim',[1 ntime+1],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
%    set(gca,'Ylim',[1e-4 1e1])
  xlabel('Local time');   ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,', r= ',num2str(rang),' km)'],'fontsize',18,'Interpreter','none')

%---colorbar---
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
  colormap(cmap); 
  ylabel(hc,'Ratio of cloud grids (%)','fontsize',15)    
  set(hc,'position',[0.914 0.160 0.0137 0.7150]);

%---legend
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  for ei=1:nexp  
    plot(xlimit(1)+1 , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',10,'MarkerFaceColor',cexp(ei,:),'MarkerEdgeColor',cexp(ei,:),'linewidth',1.5);
    text(xlimit(1)+1.8 , 10^(log10(ylimit(2))-0.4*ei) ,[expnam{ei},' (',num2str(slope(ei)),')'],'fontsize',18,'FontName','Consolas','Interpreter','none','color',cexp(ei,:)); 
  end
  drawnow  

  s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
  outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min','_r',num2str(rang)];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);

end
%}
