%-----------------
% find the time when max cloud area in the "sub-domain" larger than <plt_area>
%    and plot CMDTE and contour of hyd at different time
%---------------

close all
clear;    ccc=':';

expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'
        };

expri2={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'
        };  
%-----
cloudhyd=0.003; 
plt_area=[10 40 65];
%---
day=22;   hrs=[23 24 25 26 27 28];  minu=0:10:50; 

year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin/DTE_2D_for_paper';
titnam='CMDTE'; 
%
fload=load('colormap/colormap_dte.mat');
cmap=fload.colormap_dte; cmap(1,:)=[1 1 1];
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%  L=[0.5 2 4 6 8 10 15 20 25 35];
 L=[0.05 0.1 0.3 0.5 1 2 3 4 5 6];
%
nexp=size(expri1,1); 

%---plot
for ei=2:nexp
% for ei=1
  %---decide sub-domain to find max cloud area---
  if contains(expri1{ei},'TWIN001')
      subx1=151; subx2=300; suby1=51; suby2=200;
      xsub=151:300;  ysub=51:200;
  else    
      subx1=1; subx2=150; suby1=51; suby2=200;
      xsub=1:150;  ysub=51:200;
  end       
  %
  nti=0;  idx=0;  
  for ti=hrs       
    hr=ti;  s_date=num2str(day+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');  
    for tmi=minu
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
      
      %---cloud grid ratio and error over sub-domain
      hyd2D_sub =hyd2D(xsub,ysub); 
      cgr = length(hyd2D_sub(hyd2D_sub>cloudhyd)) / (size(hyd2D_sub,1)*size(hyd2D_sub,2)) *100 ;      
      %---
      if cgr > 0          
        %---find max cloud area in the sub-domain---
        [nx, ny]=size(hyd2D); 
        rephyd=repmat(hyd2D,3,3);      
        BW = rephyd > cloudhyd;  
        stats = regionprops('table',BW,'Area','Centroid');     
        centers = stats.Centroid;      
        fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1); 
        [cgn, ~]=max(stats.Area(fin));   
        max_cldarea = ((cgn/pi)^0.5)*2;
        
        if max_cldarea <= plt_area(1)
          continue
        elseif idx==0  &&  max_cldarea >  plt_area(1)     
          disp(['1: ',s_hr,s_min]);
          [~,CMDTE] = cal_DTE_2D(infile1,infile2) ; 
          hyd2D_plt{1} = hyd2D; 
          idx=idx+1; 
          %
          s_hrj=num2str(mod(hr+9,24),'%2.2d');  % start time string
          if hr+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
          s_hr1=s_hr; s_min1=s_min;
        elseif idx==1 && max_cldarea > plt_area(2) 
          disp(['2: ',s_hr,s_min]);
%           [~,CMDTE{2}] = cal_DTE_2D(infile1,infile2) ; 
          hyd2D_plt{2} = hyd2D;
          idx=idx+1; 
          time_tick2=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];
        elseif idx==2 && max_cldarea > plt_area(3) 
          disp(['3: ',s_hr,s_min]);
%           [~,CMDTE{3}] = cal_DTE_2D(infile1,infile2) ; 
          hyd2D_plt{3} = hyd2D;
          time_tick3=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT'];
           idx=idx+1; 
           break
        end
      end % if cgr > 0                          
    end % tmi
    if idx==3; break; end     
  end %ti    
  
  hgt = ncread(infile2,'HGT');  
  %
  fignam=[expri1{ei}(1:7),'_CMDTE-multiT_'];  
%%
  plotvar=CMDTE';   
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end      
  %---
  hf=figure('position',[100 80 800 700]); 
  [~, hp]=contourf(plotvar,L2,'linestyle','none');    
  if (max(max(hgt))~=0)
%       hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',3); 
    hold on; contour(hgt',[100 500 900],'color',[0.4 0.6 0.15],'linestyle','--','linewidth',3.5); 
  end
          
  hold on;          
   contour(hyd2D_plt{3}',[cloudhyd cloudhyd],'color',[0.7 0.7 0.7],'linewidth',3.5);    
   contour(hyd2D_plt{2}',[cloudhyd cloudhyd],'color',[0.4 0.4 0.4],'linewidth',3.5);  
   contour(hyd2D_plt{1}',[cloudhyd cloudhyd],'color',[0.1 0.1 0.1],'linewidth',3.5);    
% %         
   text(subx1+5,suby2-5,[s_hrj,s_min1,' LT'],'color',[0.1 0.1 0.1],'fontsize',13)
   text(subx1+5,suby2-12,time_tick2,'color',[0.4 0.4 0.4],'fontsize',13)
   text(subx1+5,suby2-19,time_tick3,'color',[0.7 0.7 0.7],'fontsize',13)
%    text(subx2-25,suby2-5,[s_hrj,s_min1,' LT'],'color',[0.1 0.1 0.1],'fontsize',13)
%    text(subx2-25,suby2-12,time_tick2,'color',[0.4 0.4 0.4],'fontsize',13)
%    text(subx2-25,suby2-19,time_tick3,'color',[0.7 0.7 0.7],'fontsize',13)

%
   set(gca,'fontsize',25,'LineWidth',2)           
   set(gca,'Xtick',[100 200 250],'Xticklabel',[100 200 250],'Ytick',0:50:300,'Yticklabel',0:50:300)
   set(gca,'xlim',[subx1-1 subx2],'ylim',[suby1-1 suby2])
   xlabel('(km)'); ylabel('(km)');
% 
   tit={expri1{ei},[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min1,' LT']}; 
   title(tit,'fontsize',20,'Interpreter','none')
%     
   %---colorbar---
   fi=find(L>pmin,1);
   L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
   hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',14,'LineWidth',1.2);
   colormap(cmap); title(hc,'J kg^-^1','fontsize',14);  drawnow;
   hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
   for idx = 1 : numel(hFills)
      hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
   end
   drawnow
%---        
   outfile=[outdir,'/',fignam,mon,s_date,'_',s_hr1,s_min1,'_cld',num2str(cloudhyd*1000)];
   print(hf,'-dpng',[outfile,'.png']) 
   system(['convert -trim ',outfile,'.png ',outfile,'.png']); 
   
  disp([expri2{ei},' done'])
  
end %ei
