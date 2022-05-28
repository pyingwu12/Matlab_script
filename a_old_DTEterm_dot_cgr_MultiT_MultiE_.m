
% 'cloud grid ratio' to 'error' over a specific range (decided by <rang>)
% use "center of a cloud area" to be the center of the specific range
%----------------
% x-aixs: cloud grid ratio; y-aixs: error; color: time
%---------------
% PY @ 2021/05/10


close all
clear;   
ccc=':';

% expri1={'TWIN001Pr001qv062221';'TWIN013Pr001qv062221';'TWIN019Pr001qv062221';'TWIN003Pr001qv062221'};
% expri2={'TWIN001B';'TWIN013B';'TWIN019B';'TWIN003B'};    
% expnam={ 'FLAT';'H500';'H750';'H1000'};
% expmark={'s';'o';'p';'^'};     
% exptext='JpGU';

% expri1={'TWIN001Pr001qv062221';'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221'};
% exptext='h500';
% expri2={'TWIN001B';'TWIN017B';'TWIN013B';'TWIN022B'};    
% expnam={ 'FLAT';'V05H05';'V10H05';'V20H05'};
% expmark={'s';'o';'^';'p'};        

% expri1={'TWIN001Pr001qv062221';'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221'};
% exptext='h750';
% expri2={'TWIN001B';'TWIN025B';'TWIN019B';'TWIN024B'};    
% expnam={ 'FLAT';'V05H075';'V10H075';'V20H075'};
% expmark={'s';'o';'^';'p'};     
% cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7];
% 
% expri1={'TWIN001Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
% expri2={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'};    
% expnam={ 'FLAT';'Vol05';'Vol10';'Vol20'};
% expmark={'s';'o';'^';'p'};     
% exptext='h1000JpGU';

expri1={'TWIN001Pr0025THM062221';'TWIN021Pr0025THM062221';'TWIN003Pr0025THM062221';'TWIN020Pr0025THM062221'};
expri2={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'};    
expnam={ 'FLAT';'V05H10_THM';'V10H10_THM';'V20H10_THM'};
expmark={'s';'o';'^';'p'};     
exptext='h1000THM';

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

rang=25; 

cloudhyd=0.005;
%---
stday=22;   hrs=[23 24 25 26 27];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
fignam0=['-cldRati_',exptext,'_'];
%---
nexp=size(expri1,1);  nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%---
loadfile=load('colormap/colormap_ncl.mat');  col=loadfile.colormap_ncl(15:8:end,:);

lim_ratio=62;
  cldgptg=zeros(length(hrs)*length(minu),nexp);
  DiffE_m=zeros(length(hrs)*length(minu),nexp);
%---plot
for ei=1:nexp  
  nti=0; 
  for ti=hrs       
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for tmi=minu
      clear DTE
      nti=nti+1;      s_min=num2str(tmi,'%.2d');     
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
      cldgptg(nti,ei)=cldgnum/length(dis2topo(dis2topo<=rang))*100;  % Ratio of cloud grids in the specific range
      
  %--- calculate DTE when cldgptg < lim_ratio
      if  cldgptg(nti,ei) > lim_ratio;    break;    end          
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
    if  cldgptg(nti,ei) > lim_ratio;    break;    end    
    disp([s_hr,s_min,' done'])
  end %ti    
  disp([expri2{ei},' done'])
end %ei
%%
%---set time legend (not all times are looped above)---
nti=0;
for ti=hrs 
  hr=ti;
  for tmi=minu
    nti=nti+1;  s_min=num2str(tmi,'%.2d');
    lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];
  end
end
%%
%
ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH';'DiPs'};
% ploterms={'DiPs'};

% for ploti=1:size(ploterms,1)
for ploti=1

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,fignam0];
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 900 600]);
  %---plot points---

  for ei=1:nexp
    nti=0;
    for ti=hrs 
      for tmi=minu
          nti=nti+1;
        if nti>length(DiffE_m(:,ei)); break; end
        plot(cldgptg(nti,ei),DiffE_m(nti,ei),expmark{ei},'MarkerSize',13,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2)
        hold on
      end
    end
  end  
  
  %---colorbar for time legend----
  nti=length(hrs)*length(minu); tickint=2;
  L1=( (1:tickint:nti)*diff(caxis)/nti )  +  min(caxis()) -  diff(caxis)/nti/2;
  n=0; for i=1:tickint:nti; n=n+1; llll{n}=lgnd{i}; end
  colorbar('YTick',L1,'YTickLabel',llll,'fontsize',13,'LineWidth',1.2);
  colormap(col(1:nti,:))

  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
 

  xlabel('Ratio (%)'); 
  ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,', r= ',num2str(rang),' km)'],'fontsize',18,'Interpreter','none')
  %    set(gca,'Ylim',[1e-4 1e1])
  set(gca,'Xlim',[5e-2 9e1],'Ylim',[1e-3 3e1])


  %---plot legent for experiments---
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  for ei=1:nexp  
    plot(10^(log10(xlimit(1))+0.2) , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',13,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
    text(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',18,'FontName','Consolas','Interpreter','none'); 
  end
 
  s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
  outfile=[outdir,'/',fignam,num2str(stday),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end)),'_r',num2str(rang)];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);

end
%}
