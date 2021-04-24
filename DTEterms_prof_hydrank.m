close all
clear;   ccc=':';
%---setting
expri='TWIN027';  expri1=[expri,'Pr001qv062221'];  expri2=[expri,'B']; 
s_date='22';  hr=23;  minu=50;
%---
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01'; 
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
titnam='hydro-rank-prof DTE terms';   fignam=[expri1(8:end),'_DTEterms_hydro-rank-prof_'];
%---
g=9.81;
zgi=10:50:9000;   ytick=1000:1000:zgi(end);
%---
terraincol=[0.466,0.574,0.188];

LHcol=[0.494,0.184,0.556]; KEcol=[0.3,0.745,0.933]; ThEcol=[0.95,0.75,0.125]; 
dhydcol=[0.2 0.2 0.2];
hydcol=[0.85 0.85 0.9]; 
wdiffcol=[1 0.3 0.4];

DTEcon=0.5; DTElw=3;
dhydcon=0.3; otherlw=2.5;
hydcon=0.1;
wcon=0.5;

%---
for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    s_min=num2str(mi,'%2.2d');
    %
    infile1=[indir,'/',expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = ncread(infile1,'QRAIN');  qr=double(qr);   
     qs = ncread(infile1,'QSNOW');  qs=double(qs);    
     qg = ncread(infile1,'QGRAUP'); qg=double(qg);
     qi = ncread(infile1,'QICE');   qi=double(qi);
     qc = ncread(infile1,'QCLOUD'); qc=double(qc);
     hyd1=(qr+qs+qg+qi+qc)*1e3; 
    w1.stag = ncread(infile1,'W'); 
    w1.unstag=(w1.stag(:,:,1:end-1)+w1.stag(:,:,2:end)).*0.5;  

    
    infile2=[indir,'/',expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
     qr = ncread(infile2,'QRAIN');  qr=double(qr);   
     qs = ncread(infile2,'QSNOW');  qs=double(qs);    
     qg = ncread(infile2,'QGRAUP'); qg=double(qg);
     qi = ncread(infile2,'QICE');   qi=double(qi);
     qc = ncread(infile2,'QCLOUD'); qc=double(qc);
     hyd2=(qr+qs+qg+qi+qc)*1e3; 
    w2.stag = ncread(infile2,'W'); 
    w2.unstag=(w2.stag(:,:,1:end-1)+w2.stag(:,:,2:end)).*0.5;  
 
    hgt = ncread(infile2,'HGT');
    ph = ncread(infile2,'PH'); phb = ncread(infile2,'PHB');    
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;          
    
    [nx, ny, nz]=size(hyd2);
    hyd2D=sum(hyd2,3);
    [~, hyd_rank]=sort(reshape(hyd2D,nx*ny,1),'descend'); 
    
    %
    [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2);
    %
    wdiff=w1.unstag-w2.unstag;
    %    
%     cloud_len=length(find(hyd_sort>0.1));
    cloud_len=300;
    
    KE_vector=reshape(KE,nx*ny,nz);
    ThE_vector=reshape(ThE,nx*ny,nz);
    LH_vector=reshape(LH,nx*ny,nz);
    hyd2_vector=reshape(hyd2,nx*ny,nz);
    hyd1_vector=reshape(hyd1,nx*ny,nz);
    
    wdiff_vector=reshape(wdiff,nx*ny,nz);
    zg_vector=reshape(zg,nx*ny,nz);
    hgt_vector=reshape(hgt,nx*ny,1);

    KE_cloud=KE_vector(hyd_rank(1:cloud_len),:);
    ThE_cloud=ThE_vector(hyd_rank(1:cloud_len),:);
    LH_cloud=LH_vector(hyd_rank(1:cloud_len),:);
    hyd2_cloud=hyd2_vector(hyd_rank(1:cloud_len),:);
    hyd1_cloud=hyd1_vector(hyd_rank(1:cloud_len),:);
    
    wdiff_cloud=wdiff_vector(hyd_rank(1:cloud_len),:);
    
    zg_cloud=zg_vector(hyd_rank(1:cloud_len),:);
    hgt_cloud=hgt_vector(hyd_rank(1:cloud_len));
    
%---interpoltion---
    
    for i=1:cloud_len
        X=squeeze(zg_cloud(i,:));    
        Y=squeeze(hyd2_cloud(i,:));     hyd2_iso(i,:)=interp1(X,Y,zgi,'linear');    
        Y=squeeze(hyd1_cloud(i,:));    hyd1_iso(i,:)=interp1(X,Y,zgi,'linear'); 
        Y=squeeze(LH_cloud(i,:));      LH_iso(i,:)=interp1(X,Y,zgi,'linear');  
        Y=squeeze(ThE_cloud(i,:));     ThE_iso(i,:)=interp1(X,Y,zgi,'linear');  
        Y=squeeze(KE_cloud(i,:));      KE_iso(i,:)=interp1(X,Y,zgi,'linear');   
        Y=squeeze(wdiff_cloud(i,:));      wdiff_iso(i,:)=interp1(X,Y,zgi,'linear'); 
    end
    
    %---
    [zi, xi]=meshgrid(zgi,1:cloud_len);
    %%
    %---plot---          
    hf=figure('position',[100 200 1200 500]);
    %---cloud shaded---
    contourf(xi,zi,hyd2_iso,[hydcon hydcon],'linestyle','none'); hold on  
    colormap(hydcol)
    %---
    contour(xi,zi,wdiff_iso,[wcon wcon],'color',wdiffcol,'linewidth',otherlw)
    contour(xi,zi,wdiff_iso,[-wcon -wcon],'color',wdiffcol,'Linestyle','--','linewidth',otherlw)  
    
    %---cloud diff---
    contour(xi,zi,hyd1_iso-hyd2_iso,[dhydcon dhydcon],'color',dhydcol,'linewidth',otherlw,'Linestyle','-'); 
    contour(xi,zi,hyd1_iso-hyd2_iso,[-dhydcon -dhydcon],'color',dhydcol,'linewidth',otherlw,'Linestyle','--'); 
    %---DTE contours---
%     DTEcon=0.02*max(max(LH_iso));
    contour(xi,zi,KE_iso,[DTEcon DTEcon],'color',KEcol,'linewidth',DTElw);     
    contour(xi,zi,ThE_iso,[DTEcon DTEcon],'color',ThEcol,'linewidth',DTElw);       
    contour(xi,zi,LH_iso,[DTEcon DTEcon],'color',LHcol,'linewidth',DTElw);   
    
    %---Terrain---
    if max(max(hgt))~=0
    hb=bar(hgt_cloud);    set(hb,'FaceColor',terraincol)
    end
%-------  
    set(gca,'fontsize',16,'LineWidth',1.2,'TickDir','out');       
    set(gca,'xlim',[1 100],'Ytick',ytick,'Yticklabel',ytick./1000)
    
    xlabel('Rank of vertical accumulated hydrometeor'); ylabel('Height (km)')
    s_hrj=num2str(mod(ti+9,24),'%2.2d');  % start time string
    if ti+9>24; s_datej=num2str(str2double(s_date)+fix((ti+9)/24)); else; s_datej=s_date; end
    tit={expri1;[titnam,'  ',mon,s_datej,'  ',s_hrj,s_min,' JST']};     
    title(tit,'fontsize',18)   
    
    xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
    %---cloud area dash line---
    cld_loc=find(sum(hyd2_cloud,2)<5,1);
    if cld_loc<=xlimit(2)
      line([cld_loc cld_loc],ylimit,'Linestyle','--','color','k','Linewidth',1.2)
    end
    
%----legend---    
    line_wid=4; font_size=15;
    xdiff=xlimit(2)-xlimit(1);  ydiff=ylimit(2)-ylimit(1);

    shift_x=0.27; % The smaller the value (0~1), the more right of legent 
    shift_y=0.07; 

    st_idx=shift_x*xlimit(1)+(1-shift_x)*xlimit(2); 
    ed_idx=(shift_x-0.035)*xlimit(1)+(1.035-shift_x)*xlimit(2); 

    st_idy=shift_y*ylimit(1)+(1-shift_y)*ylimit(2);

    y_int=0.07*ydiff;
    
    rectangle('position',[st_idx-xdiff*0.01, st_idy-y_int*6.90,  xdiff*(shift_x*1.02), y_int*7.84],'FaceColor','w','Linewidth',1.2)    
    line([st_idx, ed_idx],[st_idy, st_idy],'color',KEcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy+0.015*ydiff ,['KE''= ',num2str(DTEcon),' J kg^-^1'],'fontsize',font_size)       
    line([st_idx, ed_idx],[st_idy-y_int,  st_idy-y_int],'color',ThEcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-y_int ,'ThE''','fontsize',font_size)       
    line([st_idx, ed_idx],[st_idy-y_int*2,  st_idy-y_int*2],'color',LHcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-y_int*2,'LH''','fontsize',font_size)       
    line([st_idx, ed_idx],[st_idy-y_int*3,  st_idy-y_int*3],'color',dhydcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-y_int*3,['hyd.''= ',char(177),num2str(dhydcon),' g kg^-^1'],'fontsize',font_size)  
    line([st_idx, ed_idx],[st_idy-y_int*4.05,  st_idy-y_int*4.05],'color',wdiffcol,'linewidth',line_wid); 
       text(st_idx+0.05*xdiff, st_idy-y_int*4.05,['w''= ',char(177),num2str(wcon,'%.1f'),' m s^-^1'],'fontsize',font_size)  
       
    rectangle('position',[st_idx, st_idy-y_int*5.4, xdiff*0.035, ydiff*0.035],'FaceColor',hydcol,'EdgeColor','none');
       text(st_idx+0.05*xdiff, st_idy-y_int*5.2, ['hyd.= ',num2str(hydcon),' g kg^-^1'],'fontsize',font_size) 
    if max(max(hgt))~=0
    rectangle('position',[st_idx, st_idy-y_int*6.45, xdiff*0.035, ydiff*0.03],'FaceColor',terraincol,'EdgeColor','none');
       text(st_idx+0.05*xdiff, st_idy-y_int*6.35, 'Terrain','fontsize',font_size) 
    end
    
%     text(5,11000,['3-D accumulated hydrometeors: ',num2str( sum(sum(hyd2D)) ),' (g Kg^-^1)'] )

    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    %}
  end
end