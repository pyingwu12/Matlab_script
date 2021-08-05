%------------------------------------------
% plot profile of each terms of moist DTE between two simulations
%------------------------------------------
close all
clear;  ccc=':';
%---
expri='TWIN013';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='23';  hr=0;  minu=[30];
%---
maxid=2; %0: define by <xp>, <yp>; 1:max of DTE; 2: max of hyd
xp=1;  yp=87;  %start grid
x_lim=[80 140]; % for maxid=0
len=299;   %length of the line (grid)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%
year='2018'; mon='06';  
dirmem='pert'; infilenam='wrfout'; dom='01';   grids=1; %grid_spacing(km)
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  
outdir=['/mnt/e/figures/expri_twin/',expri1(1:7)];
% outdir=['/mnt/e/figures/expri_twin/cloud_cross_section_DTEterms'];
titnam='DTE terms';  %fignam=[expri1(8:end),'_DTEterms_',];
fignam=[expri1,'_DTEterms_',];
%
g=9.81; 
zgi=10:50:10000;  ytick=1000:1000:zgi(end);
%---
LHcol=[0.494,0.184,0.556]; KEcol=[0.3,0.745,0.933]; ThEcol=[0.95,0.75,0.125]; 
dhydcol=[0.2 0.2 0.2];
hydcol=[0.85 0.85 0.9]; 
wdiffcol=[1 0.3 0.4];
terraincol=[0.466,0.574,0.188];

DTEcon=1; DTElw=3;
dhydcon=0.3; otherlw=2.5;
wdiffcon=0.5;
hydcon=0.1;

%
for ti=hr
  s_hr=num2str(ti,'%2.2d');
  for mi=minu        
    s_min=num2str(mi,'%2.2d');
    %---infile 1, perturbed state---
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = ncread(infile1,'QRAIN');  qr=double(qr);   
     qs = ncread(infile1,'QSNOW');  qs=double(qs);    
     qg = ncread(infile1,'QGRAUP'); qg=double(qg);
     qi = ncread(infile1,'QICE');   qi=double(qi);
     qc = ncread(infile1,'QCLOUD'); qc=double(qc);
     hyd1=(qr+qs+qg+qi+qc)*1e3; 
     
     w1.stag = ncread(infile1,'W'); 
     w1.unstag=(w1.stag(:,:,1:end-1)+w1.stag(:,:,2:end)).*0.5;  

    %---infile 2, based state---
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     hyd2 = (qr+qs+qg+qi+qc)*1e3; 
     
    u2.stag = ncread(infile2,'U');
      u2.unstag=(u2.stag(1:end-1,:,:)+u2.stag(2:end,:,:)).*0.5;
    w2.stag = ncread(infile2,'W'); 
      w2.unstag=(w2.stag(:,:,1:end-1)+w2.stag(:,:,2:end)).*0.5;  
    %---
    hgt = ncread(infile2,'HGT');
    ph = ncread(infile2,'PH');  phb = ncread(infile2,'PHB');        
    PH0=double(phb+ph);  PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   
    zg=double(PH)/g;     
    
    %---calculate DTE---
    [DTE, P]=cal_DTEterms(infile1,infile2);
    
    wdiff=w1.unstag-w2.unstag;
    
    %---find xp or yp for maximum hyd or DTE if necessary
    if maxid==1      % max DTE    
      A=sum(DTE.KE + DTE.SH + DTE.LH ,3);     [xx,yy]=find(A == max(A(:)));    
      if slopx>=slopy; yp=yy; else;  xp=xx; end
    elseif maxid==2  % max hyd
      A=sum(hyd2,3);     [xx,yy]=find(A == max(A(:)));   
      if slopx>=slopy; yp=yy; else;  xp=xx; end
    end    
 
    %---interpoltion--- 
    [nx, ny, ~]=size(qr);    [y, x]=meshgrid(1:ny,1:nx);  
    i=0;  xB=0; yB=0;
    while xB<x(xp,yp)+len && yB<y(xp,yp)+len
      i=i+1;
      indx=xp+slopx*(i-1);    indy=yp+slopy*(i-1);
      linex(i)=x(indx,indy);  xB=linex(i);     
      liney(i)=y(indx,indy);  yB=liney(i);       
      X=squeeze(zg(indx,indy,:));         
      KEprof(:,i)=interp1(X,squeeze(DTE.KE(indx,indy,:)),zgi,'linear');  
      ThEprof(:,i)=interp1(X,squeeze(DTE.SH(indx,indy,:)),zgi,'linear');     
      LHprof(:,i)=interp1(X,squeeze(DTE.LH(indx,indy,:)),zgi,'linear');  
      hyd1prof(:,i)=interp1(X,squeeze(hyd1(indx,indy,:)),zgi,'linear');  
      hyd2prof(:,i)=interp1(X,squeeze(hyd2(indx,indy,:)),zgi,'linear');  
      hgtprof(i)=hgt(indx,indy);            
%       w2.prof(:,i)=interp1(X,squeeze(w2.unstag(indx,indy,:)),zgi,'linear');  
%       u2.prof(:,i)=interp1(X,squeeze(u2.unstag(indx,indy,:)),zgi,'linear');  
      wdiffprof(:,i)=interp1(X,squeeze(wdiff(indx,indy,:)),zgi,'linear');  
    end     
    %%
%---plot---   
    if slopx>=slopy;    xtitle='X (km)';   xaxis=linex;    
    else;               xtitle='Y (km)';   xaxis=liney; 
    end   
    if slopx==0; slope='Inf'; else; slope=num2str(slopy/slopx,2); end         
    [xi, zi]=meshgrid(xaxis,zgi);    
    %---
    hf=figure('position',[100 75 900 600]);     
    contourf(xi,zi,hyd2prof,[hydcon hydcon],'linestyle','none');  hold on
    colormap(hydcol)
    
    contour(xi,zi,wdiffprof,[wdiffcon wdiffcon],'color',wdiffcol,'linewidth',otherlw)
    contour(xi,zi,wdiffprof,[-wdiffcon -wdiffcon],'color',wdiffcol,'Linestyle','--','linewidth',otherlw)  
    
    contour(xi,zi,hyd1prof-hyd2prof,[dhydcon dhydcon],'color',dhydcol,'linewidth',otherlw,'Linestyle','-'); 
    contour(xi,zi,hyd1prof-hyd2prof,[-dhydcon -dhydcon],'color',dhydcol,'linewidth',otherlw,'Linestyle','--');    
    %
    hL=contour(xi,zi,LHprof,[DTEcon DTEcon],'color',LHcol,'linewidth',DTElw);    
    hK=contour(xi,zi,KEprof,[DTEcon DTEcon],'color',KEcol,'linewidth',DTElw);     
    hT=contour(xi,zi,ThEprof,[DTEcon DTEcon],'color',ThEcol,'linewidth',DTElw);    
   
    if (max(max(hgtprof))~=0)
     plot(hgtprof,'color',terraincol,'LineWidth',DTElw+0.5)
    end      
   
    set(gca,'fontsize',16,'LineWidth',1.2)
%     if exist('xx','var')==1; set(gca,'Xlim',[xx-20 xx+40]);  else; set(gca,'Xlim',x_lim); end
    set(gca,'Xlim',[0 151])
%     set(gca,'Ylim',[0 5000])
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Ytick',ytick,'Yticklabel',ytick./1000)
    xlabel(xtitle); ylabel('Height (km)')
    
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1;[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST']};     
    title(tit,'fontsize',18)  
        
    %------LEGEND--------
    line_wid=4; font_size=15;
    
    xlimit=get(gca,'Xlim');  ylimit=get(gca,'Ylim');
    xdiff=xlimit(2)-xlimit(1);  ydiff=ylimit(2)-ylimit(1);

    shift_x=0.35;
    st_idx=shift_x*xlimit(1)+(1-shift_x)*xlimit(2); 
    ed_idx=(shift_x-0.04)*xlimit(1)+(1.04-shift_x)*xlimit(2); 
     
    st_idy=0.1*ylimit(1)+0.9*ylimit(2);

    line([st_idx, ed_idx],[st_idy, st_idy],'color',KEcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy+ydiff*0.01 ,['KE''= ',num2str(DTEcon),' J kg^-^1'],'fontsize',font_size)
       
    line([st_idx, ed_idx],[st_idy-ydiff*0.05,  st_idy-ydiff*0.05],'color',ThEcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-ydiff*0.05 ,'ThE''','fontsize',font_size)
       
    line([st_idx, ed_idx],[st_idy-ydiff*0.1,  st_idy-ydiff*0.1],'color',LHcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-ydiff*0.1,'LH''','fontsize',font_size)       
    % hyd diff
    line([st_idx, ed_idx],[st_idy-ydiff*0.15,  st_idy-ydiff*0.15],'color',dhydcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-ydiff*0.15,['hyd.''= ',char(177),num2str(dhydcon),' g kg^-^1'],'fontsize',font_size)  
    % w   
    line([st_idx, ed_idx],[st_idy-ydiff*0.21,  st_idy-ydiff*0.21],'color',wdiffcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-ydiff*0.21,['w''= ',char(177),num2str(wdiffcon,'%.1f'),' m s^-^1'],'fontsize',font_size)  
    % hyd
    rectangle('position',[st_idx, st_idy-ydiff*0.3, xdiff*0.04, ydiff*0.025],'FaceColor',hydcol,'EdgeColor','none');
       text(st_idx+0.05*xdiff, st_idy-ydiff*0.28, ['hyd.= ',num2str(hydcon),' g kg^-^1'],'fontsize',font_size) 
    %----------------------
    text(0.2*xlimit(1)+0.8*xlimit(2),ylimit(1)-0.1*(ylimit(2)-ylimit(1)),['xp=',num2str(xp),', yp=',num2str(yp)])    
    drawnow
    %---    
   
%     intz=10; intt=10;
%     windbarbM(xi(5:intz:end,2:intt:end),zi(5:intz:end,2:intt:end),...
%     u2.prof(5:intz:end,2:intt:end),w2.prof(5:intz:end,2:intt:end),0.5,10,[0.1 0.1 0.1],3)


    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min,'_x',num2str(xp),'y',num2str(yp),'s',num2str(slope)];
    print(hf,'-dpng',[outfile,'.png']) 
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);   

  end %tmi
end
