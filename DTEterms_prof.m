%------------------------------------------
% plot profile of each terms of moist DTE between two simulations
%------------------------------------------
% close all
clear;  ccc=':';
%---
expri='TWIN027';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='22';  hr=23;  minu=[30 40];

%---
maxid=2; %1:max of DTE; 2: max of hyd
xp=1;  yp=104;  %start grid
len=299;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%
year='2018'; mon='06';  
dirmem='pert'; infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  
outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
% titnam='moist DTE vertical weighted average';  
titnam='DTE terms';  fignam=[expri1(8:end),'_DTEterms_',];
%
g=9.81; 
% zgi=50:25:10000;    ytick=1000:1000:zgi(end); 
% zgi=[10:50:310 510:300:12000];   
zgi=[10:50:12000];  ytick=1000:2000:zgi(end);
%
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    qr = double(ncread(infile2,'QRAIN'));   
    qc = double(ncread(infile2,'QCLOUD'));
    qg = double(ncread(infile2,'QGRAUP'));  
    qs = double(ncread(infile2,'QSNOW'));
    qi = double(ncread(infile2,'QICE')); 
    hyd = (qr+qs+qg+qi+qc)*1e3; 
    hgt = ncread(infile2,'HGT');
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');        
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   
    zg=double(PH)/g;     
    %
    qr = ncread(infile1,'QRAIN');  qr=double(qr);   
    qs = ncread(infile1,'QSNOW');  qs=double(qs);    
    qg = ncread(infile1,'QGRAUP'); qg=double(qg);
    qi = ncread(infile1,'QICE');   qi=double(qi);
    qc = ncread(infile1,'QCLOUD'); qc=double(qc);
    hyd1=(qr+qs+qg+qi+qc)*1e3;     
    %
    [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2);
    %
    if maxid==1        
      A=sum(KE+ThE+LH,3);     [xx,yy]=find(A == max(A(:)));    yp=yy;
%     xp=xx;
    elseif maxid==2
      A=sum(hyd,3);     [xx,yy]=find(A == max(A(:)));    yp=yy;
%     xp=xx;
    end    

    u.stag = ncread(infile2,'U');
    v.stag = ncread(infile2,'V');     
    w.stag = ncread(infile2,'W'); 
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;  
    w.unstag=(w.stag(:,:,1:end-1)+w.stag(:,:,2:end)).*0.5;  
 
    %---interpoltion--- 
    [nx, ny, ~]=size(qr);
    [y, x]=meshgrid(1:ny,1:nx);  
    i=0;  xB=0; yB=0;
    while xB<x(xp,yp)+len && yB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  xB=linex(i);     
      liney(i)=y(indx,indy);  yB=liney(i);       
      X=squeeze(zg(indx,indy,:));         
      KEprof(:,i)=interp1(X,squeeze(KE(indx,indy,:)),zgi,'linear');  
      ThEprof(:,i)=interp1(X,squeeze(ThE(indx,indy,:)),zgi,'linear');     
      LHprof(:,i)=interp1(X,squeeze(LH(indx,indy,:)),zgi,'linear');  
      hydprof(:,i)=interp1(X,squeeze(hyd(indx,indy,:)),zgi,'linear');  
      hyd1prof(:,i)=interp1(X,squeeze(hyd1(indx,indy,:)),zgi,'linear');  
      hgtprof(i)=hgt(indx,indy);            
      w.prof(:,i)=interp1(X,squeeze(w.unstag(indx,indy,:)),zgi,'linear');  
      u.prof(:,i)=interp1(X,squeeze(u.unstag(indx,indy,:)),zgi,'linear');  
      
    end     

    
%---plot---   

    if slopx>=slopy;    xtitle='X (km)';   xaxis=linex;    
    else;               xtitle='Y (km)';   xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end    

     %%
    [xi, zi]=meshgrid(xaxis,zgi);    
    [xwind, zwind]=meshgrid(xaxis(1:5:end),1:20:length(zgi)); 
    u.plot=u.prof(1:20:end,1:5:end);
    w.plot=w.prof(1:20:end,1:5:end);
    %%
    hf=figure('position',[100 75 900 600]); 
    contourf(xi,zi,hydprof,[0.1 0.1],'linestyle','none');  hold on
    colormap([0.85 0.85 0.9])
    
    %
    DTEcon=0.5;
    hL=contour(xi,zi,LHprof,[DTEcon DTEcon],'color',[0.494,0.184,0.556],'linewidth',1.5);    
    hK=contour(xi,zi,KEprof,[DTEcon DTEcon],'color',[0.3,0.745,0.933],'linewidth',1.5);     
    hT=contour(xi,zi,ThEprof,[DTEcon DTEcon],'color',[0.929,0.694,0.125],'linewidth',1.5);    

    hydcon=0.3;
    contour(xi,zi,hyd1prof-hydprof,[hydcon hydcon],'color',[0.1 0.1 0.1],'linewidth',1.3,'Linestyle','-'); 
    contour(xi,zi,hyd1prof-hydprof,[-hydcon -hydcon],'color',[0.1 0.1 0.1],'linewidth',1.3,'Linestyle','--'); 
    
    if (max(max(hgtprof))~=0)
     plot(hgtprof,'color',[0.466,0.574,0.188],'LineWidth',1.8)
    end
    
%     qscale=1;
%     h1 = quiver(xwind,zwind,u.plot,w.plot,0,'k') ; % the '0' turns off auto-scaling
%     hU = get(h1,'UData');   hV = get(h1,'VData') ;
%     set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.5);
% contour(xi,zi,w.prof,[2 2],'r')
% contour(xi,zi,w.prof,[-2 -2],'r','Linestyle','--')
    

    set(gca,'fontsize',16,'LineWidth',1.2)
%     set(gca,'Xlim',[16 116])
%     set(gca,'Xlim',[200 300])
   set(gca,'Xlim',[1 100],'Ylim',[0 9000])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Ytick',ytick,'Yticklabel',ytick./1000)
    xlabel(xtitle); ylabel('km')
    
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1;[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST']};     
    title(tit,'fontsize',18)  
    
%     line([10 16],[9000 9000],'color',[0.494,0.184,0.556],'linewidth',2); text(18,9000,'LH','fontsize',15)
%     line([10 16],[8500 8500],'color',[0.3,0.745,0.933],'linewidth',2); text(18,8500,'KE','fontsize',15)
%     line([10 16],[8000 8000],'color',[0.929,0.694,0.125],'linewidth',2); text(18,8000,'ThE','fontsize',15)         
xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');


legwid=56;
% %     rectangle('position',[xlimit(2)-legwid  ylimit(2)-4000 legwid-3 3500],'FaceColor','w')
%     line([xlimit(2)-51 xlimit(2)-44],[ylimit(2)-1000 ylimit(2)-1000],'color',[0.494,0.184,0.556],'linewidth',2); 
%        text(xlimit(2)-41,ylimit(2)-1000,'Diff. LH','fontsize',15)
%     line([xlimit(2)-51 xlimit(2)-44],[ylimit(2)-1500 ylimit(2)-1500],'color',[0.3,0.745,0.933],'linewidth',2); 
%        text(xlimit(2)-41,ylimit(2)-1500,'Diff. KE','fontsize',15)
%     line([xlimit(2)-51 xlimit(2)-44],[ylimit(2)-2000 ylimit(2)-2000],'color',[0.929,0.694,0.125],'linewidth',2); 
%        text(xlimit(2)-41,ylimit(2)-2000,'Diff. ThE','fontsize',15)       
% %     line([xlimit(2)-51 xlimit(2)-44],[ylimit(2)-2500 ylimit(2)-2500],'color',[0.1 0.1 0.1],'linewidth',2); 
% %        text(xlimit(2)-41,ylimit(2)-2500,'Diff. hyd.','fontsize',15)         
%     rectangle('position',[xlimit(2)-51 ylimit(2)-3100 6 200],'FaceColor',[0.85 0.85 0.9],'EdgeColor','none');
%        text(xlimit(2)-41,ylimit(2)-3000,'hyd.','fontsize',15) 
% %     rectangle('position',[xlimit-28 ylimit-6150 5 200],'FaceColor',[0.466,0.574,0.188],'EdgeColor','none'); text(xlimit-21,ylimit-6000,'terrain','fontsize',15)    
    

text(0.2*xlimit(1)+0.8*xlimit(2),ylimit(1)-0.1*(ylimit(2)-ylimit(1)),['xp=',num2str(xp),', yp=',num2str(yp)])


    drawnow;    
%     %---    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope)];
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);   

  end %tmi
end
