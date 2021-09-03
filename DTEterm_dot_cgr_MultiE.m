%----------------------------------------------------
% 'cloud grid ratio' or 'max cloud area' against 'error' over a specific sub-domain (decided by <xsub> and <ysub>)
%                                                                        ^^^^^^^^^^^
% Multi experiments; x-axis: cloud grid ratio/max cloud area; y-axis: error; color: time
% PY WU @2021/06/13
%----------------------------------------------------

% close all
clear;   ccc=':';

% expri1={'TWIN001Pr001qv062221';'TWIN013Pr001qv062221';'TWIN019Pr001qv062221';'TWIN003Pr001qv062221'};
% expri2={'TWIN001B';'TWIN013B';'TWIN019B';'TWIN003B'};    
% expnam={ 'FLAT';'H500';'H750';'H1000'};
% expmark={'s';'o';'p';'^'};     
% exptext='JpGU';

% expri1={'TWIN001Pr001qv062221';'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221'};
% exptext='H500';
% expri2={'TWIN001B';'TWIN017B';'TWIN013B';'TWIN022B'};    
% expnam={ 'FLAT';'V05H05';'V10H05';'V20H05'};
% expmark={'s';'o';'^';'p'};        
% 
% expri1={'TWIN001Pr001qv062221';'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221'};
% exptext='h750';
% expri2={'TWIN001B';'TWIN025B';'TWIN019B';'TWIN024B'};    
% expnam={ 'FLAT';'V05H075';'V10H075';'V20H075'};
% expmark={'s';'o';'^';'p'};     
% 
% expri1={'TWIN001Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
% expri2={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'};    
% expnam={ 'FLAT';'V05H10';'V10H10';'V20H10'};
% expmark={'s';'o';'^';'p'};     
% exptext='H1000';

% expri1={'TWIN001Pr001qv062221';'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
% expri2={'TWIN001B';'TWIN023B';'TWIN016B';'TWIN018B'};    
% expnam={ 'FLAT';'V05H20';'V10H20';'V20H20'};
% expmark={'s';'o';'^';'p'};     
% exptext='h2000';
% 
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};
% expri2={'TWIN001B';'TWIN003B'};    
% expnam={ 'FLAT';'TOPO'};
% expmark={'s';'^'};     
% exptext='exp0103';

%----------different wind profile experiments----------------------------------------
  subx1=1; subx2=150; suby1=76; suby2=225;
  xsub=1:150;  ysub=76:225;

% expri1={'TWIN030Pr001qv062221';'TWIN031Pr001qv062221';'TWIN032Pr001qv062221'};
% expri2={'TWIN030B';'TWIN031B';'TWIN032B'};    
% expnam={ 'NS5_F';'NS5_T1000';'NS5_T500'};
% expmark={'s';'^';'o'};     
% exptext='NS5';

% expri1={'TWIN033Pr001qv062221';'TWIN034Pr001qv062221';'TWIN035Pr001qv062221'};
% expri2={'TWIN033B';'TWIN034B';'TWIN035B'};    
% expnam={ 'U05_F';'U05_T1000';'U05_T500'};
% expmark={'s';'^';'o'};     
% exptext='U05';

expri1={'TWIN036Pr001qv062221';'TWIN037Pr001qv062221';'TWIN038Pr001qv062221'};
expri2={'TWIN036B';'TWIN037B';'TWIN038B'};    
expnam={ 'U15_F';'U15_T1000';'U15_T500'};
expmark={'s';'^';'o'};     
exptext='U15';

% expri1={'TWIN039Pr001qv062221';'TWIN040Pr001qv062221';'TWIN041Pr001qv062221'};
% expri2={'TWIN039B';'TWIN040B';'TWIN041B'};    
% expnam={ 'U25_F';'U25_T1000';'U25_T500'};
% expmark={'s';'^';'o'};     
% exptext='U25';


%---one experiment for test code---
% expri1={'TWIN032Pr001qv062221'};   expri2={'TWIN032B'};     
% expnam={'NS5_TOPO'};  expmark={'^'};    exptext='NS5_TOPO';
%----------------------------------

cloudhyd=0.003;
%---
day=22;   hrs=[23 24 25 26 27];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
%---
nexp=size(expri1,1);  nhr=length(hrs);  nminu=length(minu);  ntime=nhr*nminu;
%---
loadfile=load('colormap/colormap_ncl.mat');  col=loadfile.colormap_ncl(15:8:end,:);

  cgr=zeros(ntime,nexp);
  %%
%---calculate---
ntii=0;
for ei=1:nexp  
  %---decide sub-domain to find max cloud area---
%   if contains(expri1{ei},'TWIN001')
%       subx1=151; subx2=300; suby1=51; suby2=200;
%       xsub=151:300;  ysub=51:200;
%   else    
%       subx1=1; subx2=150; suby1=51; suby2=200;
%       xsub=1:150;  ysub=51:200;
%   end    
  nti=0; 
  for ti=hrs       
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(day+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d');   
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d'); clear DTE
      if ei==1
          ntii=ntii+1;    lgnd{ntii}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];  
      end      
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
          
      %---cloud grid ratio and error over sub-domain
      hyd2D_sub =hyd2D(xsub,ysub); 
      cgr(nti,ei) = length(hyd2D_sub(hyd2D_sub>cloudhyd)) / (size(hyd2D_sub,1)*size(hyd2D_sub,2)) *100 ;      
      %---
      if cgr(nti,ei)>0          
        %---find max cloud area in the sub-domain---
        [nx, ny]=size(hyd2D); 
        rephyd=repmat(hyd2D,3,3);      
        BW = rephyd > cloudhyd;  
        stats = regionprops('table',BW,'Area','Centroid');     
        centers = stats.Centroid;      
        fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1); 
        [cgn, ~]=max(stats.Area(fin));   
        max_cldarea(nti,ei) = ((cgn/pi)^0.5)*2;
      end
      
      %---
      [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
      MDTE = DTE.KE + DTE.SH + DTE.LH;            
      CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   
      %----      
      error2D = sum(dPm.*MDTE(:,:,1:end-1),3) + DTE.Ps;  
        MDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
        CMDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm.*DTE.KE(:,:,1:end-1),3);     
       DiKE_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
       
      error2D = sum(dPm.*DTE.KE3D(:,:,1:end-1),3);     
       DiKE3D_m(nti,ei)=mean(mean(error2D(xsub,ysub)));
       
      error2D = sum(dPm.*DTE.SH(:,:,1:end-1),3);     
       DiSH_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm.*DTE.LH(:,:,1:end-1),3);     
        DiLH_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
       
      error2D = DTE.Ps;     
        DiPs_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 

    end % tmi
    disp([s_hr,s_min,' done'])
  end %ti    
  disp([expri2{ei},' done'])
end %ei

%%
%---x-axis: cloud grid ratio---
%
fignam0=['-cgr_',exptext,'_'];
ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH';'DiPs'};

% for ploti=1:size(ploterms,1)
for ploti=[2]
  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,fignam0];
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 900 600]);
  %---plot points---
  for ei=1:nexp
    for nti=1:ntime
         marker_size = 8 + max_cldarea(nti,ei) * 20/90;
        plot(cgr(nti,ei),DiffE_m(nti,ei),expmark{ei},'MarkerSize',marker_size,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2)
        hold on
    end
  end    
  %---colorbar for time legend----
  tickint=2;
  L1=( (1:tickint:ntime)*diff(caxis)/ntime )  +  min(caxis()) -  diff(caxis)/ntime/2;
  n=0; for i=1:tickint:ntime; n=n+1; llll{n}=lgnd{i}; end
  colorbar('YTick',L1,'YTickLabel',llll,'fontsize',13,'LineWidth',1.2);
  colormap(col(1:ntime,:))

  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2)  
  xlabel('Ratio (%)');   ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
  set(gca,'Xlim',[1e-2 1e2],'Ylim',[1e-3 1e1])

  %---plot legent for experiments---
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  for ei=1:nexp  
    plot(10^(log10(xlimit(1))+0.2) , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',13,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
    text(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',18,'FontName','Monospaced','Interpreter','none'); 
  end
 
  s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
  outfile=[outdir,'/',fignam,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%}
%%
%---x-axis: max cloud area---
fignam0=['-mca_',exptext,'_'];
ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH';'DiPs'};

 outdir='/mnt/e/figures/expri_twin';

% for ploti=1:size(ploterms,1)
for ploti=[2 ]

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,fignam0];
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 900 600]);
  %---plot points--- 
  for ei=1:nexp
    for nti=1:ntime
        plot(max_cldarea(nti,ei),DiffE_m(nti,ei),expmark{ei},'MarkerSize',13,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2)
        hold on
    end
  end  
  
  %---colorbar for time legend----  
   tickint=2;
  L1=( (1:tickint:ntime)*diff(caxis)/ntime )  +  min(caxis()) -  diff(caxis)/ntime/2;
  n=0; for i=1:tickint:ntime; n=n+1; llll{n}=lgnd{i}; end
  colorbar('YTick',L1,'YTickLabel',llll,'fontsize',13,'LineWidth',1.2);
  colormap(col(1:ntime,:))

  set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2)  
  xlabel('Max cloud area size (km)');   ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
     set(gca,'Ylim',[1e-3 2e1],'Xlim',[1 5e1])

  %---plot legent for experiments---
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  for ei=1:nexp  
    plot(10^(log10(xlimit(1))+0.2) , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',13,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
    text(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',18,'FontName','Monospaced','Interpreter','none'); 
  end
 
  s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
  outfile=[outdir,'/',fignam,num2str(day),'_',s_sth,s_edh,'_',num2str(nhr),'h',num2str(nminu),'m',num2str(minu(end))];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);

end
%}
