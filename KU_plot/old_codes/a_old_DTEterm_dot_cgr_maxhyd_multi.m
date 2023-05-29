%function DTEterm_2_cloudratio_multi(plotidx,ploterm,rang)

% use "maximum of accumulated hydromemteors" to be the center of the range
%----------------
% x-aixs: cloud grid ratio; y-aixs: error; color: time
%---------------
% P.Y. Wu @ 2021.03

close all
clear;  plotidx='h1000'; ploterm='DTE'; rang=25;
ccc=':';


switch(plotidx)
   case('only03')
%     exptext='only3';
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};
expri2={'TWIN001B';'TWIN003B'};    
expnam={ 'FLAT';'TOPO'};
expmark={'s';'^'};

%    case('width50')
% % exptext='width50';
% expri1={'TWIN001Pr001qv062221';'TWIN017Pr001qv062221';'TWIN003Pr001qv062221';'TWIN018Pr001qv062221'};
% expri2={'TWIN001B';'TWIN017B';'TWIN003B';'TWIN018B'};    
% expnam={ 'FLAT';'H05V05';'TOPO';'H2V2'};
% expmark={'s';'o';'^';'p'};
   case('vol10')
% exptext='vol1';
expri1={'TWIN001Pr001qv062221';'TWIN013Pr001qv062221';'TWIN019Pr001qv062221';'TWIN003Pr001qv062221';'TWIN016Pr001qv062221'};
expri2={'TWIN001B';'TWIN013B';'TWIN019B';'TWIN003B';'TWIN016B'};    
expnam={ 'FLAT';'V10H05';'V10H075';'TOPO';'V10H20'};
expmark={'s';'*';'p';'^';'o'};

   case('vol10_THM')
expri1={'TWIN001Pr001THM062221';'TWIN013Pr001THM062221';'TWIN019Pr001THM062221';'TWIN003Pr001THM062221';'TWIN016Pr001THM062221'};
expri2={'TWIN001B';'TWIN013B';'TWIN019B';'TWIN003B';'TWIN016B'};    
expnam={ 'FLAT';'V10H05_THM';'V10H075_THM';'TOPO_THM';'V10H20_THM'};
expmark={'s';'*';'p';'^';'o'};

   case('h500')
% exptext='h500';
expri1={'TWIN001Pr001qv062221';'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221'};
expri2={'TWIN001B';'TWIN017B';'TWIN013B';'TWIN022B'};    
expnam={ 'FLAT';'V05H05';'V10H05';'V20H05'};
expmark={'s';'o';'^';'p'};
% % 
   case('h1000')
% exptext='h1000';
expri1={'TWIN001Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
expri2={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'};    
expnam={ 'FLAT';'V05H10';'V10H10';'V20H10'};
expmark={'s';'o';'^';'p'};

   case('h750')
% exptext='h750';
expri1={'TWIN001Pr001qv062221';'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221'};
expri2={'TWIN001B';'TWIN025B';'TWIN019B';'TWIN024B'};    
expnam={ 'FLAT';'V05H075';'V10H075';'V20H075'};
expmark={'s';'o';'^';'p'};

   case('h2000')
% exptext='h750';
expri1={'TWIN001Pr001qv062221';'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'};
expri2={'TWIN001B';'TWIN023B';'TWIN016B';'TWIN018B'};    
expnam={ 'FLAT';'V05H20';'V10H20';'V20H20'};
expmark={'s';'o';'^';'p'};

   case('vol05')
% expri1={'TWIN001Pr001qv062221';'TWIN017Pr001qv062221';'TWIN021Pr001qv062221';'TWIN023Pr001qv062221'};
% expri2={'TWIN001B';'TWIN017B';'TWIN021B';'TWIN023B'};    
% expnam={ 'FLAT';'H05V05';'H10V05';'H20V05'};
% expmark={'s';'o';'^';'p'};  
end

if exist('expri1','var')==0
   error('Please check the setting of <plotidx>') 
end

exptext=plotidx;
% rang=150;
% ploterm='DTE'; % KE, ThE, LH, or DTE
%----
hydlim1=1;  hydlim2=rang^2*pi*0.62;  cloudhyd=0.005;
%topo_locx=75; topo_locy=100;
%
stday=22;   hrs=[23 24 25 26 27];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
if strcmp(ploterm,'DTE')==1
  titnam='Cloud area ratio to DTE';  fignam=['cld-DTE_',exptext,'_'];
else
  titnam=['Cloud area ratio to ',ploterm,''''];  fignam=['cld-Diff',ploterm,'_',exptext,'_'];
end
%
nexp=size(expri1,1); 
loadfile=load('colormap/colormap_ncl.mat');  col=loadfile.colormap_ncl(15:8:end,:);

hf=figure('Position',[100 65 900 600]);
%---plot
for ei=1:nexp  
  npi=0; nti=0;
  cldgnum2=0;
  for ti=hrs 
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      hgt = ncread(infile2,'HGT');
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D = sum(qr+qc+qg+qs+qi,3);       
      
      if nti==1 && ei==1;  [nx, ny]=size(hyd2D);   end       
      %---calculate distance to the topography top or max hyd---
%       if max(max(hgt))<=0
         
         [maxval, maxloc]=max(hyd2D);  [~, ceny]=max(maxval);  cenx=maxloc(ceny);  % find maximum of hyd
%                  cenx=ceil(nx/2); ceny=ceil(ny/2);
%       else
%          [maxval, maxloc]=max(hgt);  [~, ceny]=max(maxval);  cenx=maxloc(ceny);
%       end
      [yi, xi]=meshgrid(1:ny,1:nx);
      yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
      yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
      xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
      xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
      dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5;
      cldgnum=length(find(hyd2D+1>cloudhyd+1 & dis2topo<=rang));  % cloud grid numbers in the specific range 
      
      if cldgnum<cldgnum2 && max(max(hgt))> 0
         break
      end
%---------------- 
%       if cldgnum > hydlim1 && cldgnum <= hydlim2   % only plot point between the decided range of cloud numbers
      if cldgnum > hydlim1 
        npi=npi+1;
        %---      
        [KE, ~, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2); 
        dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
        dPall = P.f2(:,:,end)-P.f2(:,:,1);
        dPm = dP./repmat(dPall,1,1,size(dP,3)); 
        %---
        if strcmp(ploterm,'DTE')==1
         DTE3D = KE + ThE + LH ;
         DiffE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + Ps;
        else
         eval(['DiffE2D = sum(dPm.*',ploterm,'(:,:,1:end-1),3);'])
        end
        DiffE_m=double(mean(DiffE2D(dis2topo<=rang)));         % Mean of DTE in the specific range
        cldgptg=cldgnum/length(dis2topo(dis2topo<=rang))*100;  % Ratio of cloud grids in the specific range
        %
        plot(cldgptg,DiffE_m,expmark{ei},'MarkerSize',10,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2);    hold on    
        %
        if npi==1
          text(10^(log10(cldgptg)+0.05),10^(log10(DiffE_m)-0.05),[num2str(mod(hr+9,24),'%2.2d'),s_min],'color',[0.3 0.3 0.3]...
                ,'HorizontalAlignment','center','VerticalAlignment','top','fontsize',13) ;
          plot(cldgptg,DiffE_m,expmark{ei},'MarkerSize',10,'MarkerFaceColor','none','MarkerEdgeColor',[0.3 0.3 0.3]); 
        end                
        cldgnum2=cldgnum;
%       elseif cldgnum > hydlim2          
%          break       
      end % if cnum > hydlim1 
    end % tmi
    if cldgnum<cldgnum2 && max(max(hgt))> 0
       break
    end
%      if cldgnum > hydlim2; break; end
    disp([s_hr,s_min,' done'])
  end %ti  
  disp([expri2{ei},' done'])
end %ei

%%
nti=0;
  for ti=hrs 
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    for tmi=minu
      nti=nti+1;  s_min=num2str(tmi,'%.2d');
      lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];

    end
  end
%%
%---colorbar for time legend----
nti=length(hrs)*length(minu); tickint=2;
L1=( (1:tickint:nti)*diff(caxis)/nti )  +  min(caxis()) -  diff(caxis)/nti/2;
n=0; for i=1:tickint:nti; n=n+1; llll{n}=lgnd{i}; end
colorbar('YTick',L1,'YTickLabel',llll,'fontsize',13,'LineWidth',1.2);
colormap(col(1:nti,:))

set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
%  set(gca,'Xlim',[5e-2 9e1],'Ylim',[1e-4 1e1]) % KE etc. r=25 km   
%  set(gca,'Xlim',[5e-2 9e1],'Ylim',[1e-3 3e1]) % DTE etc. r=25 km   
% set(gca,'Xlim',[1e-3 8e1],'Ylim',[1e-4 2e1])    % KE etc. r>25 km
% set(gca,'Xlim',[1e-3 8e1],'Ylim',[1e-3 3e1])   % DTE r>25km
set(gca,'Xlim',[5e-2 9e1],'Ylim',[1e-4 3e1])
%
xlabel('Ratio (%)'); 
ylabel(['Mean ',ploterm,''' (J kg^-^1)']);
title([titnam,'  (r= ',num2str(rang),' km)'],'fontsize',18)

%---plot legent for experiments---
xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
for ei=1:nexp  
  plot(10^(log10(xlimit(1))+0.2) , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',10,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
  text(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',18,'FontName','Consolas','Interpreter','none'); 
end

s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(length(hrs)),'hrs','min',num2str(minu(1)),num2str(minu(2)),'_r',num2str(rang)];
% print(hf,'-dpng',[outfile,'_2.png'])
% system(['convert -trim ',outfile,'_2.png ',outfile,'_2.png']);
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
