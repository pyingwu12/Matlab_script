%function uv_atVr(pradar,paza,tita)
%
clear
%
hr=0;  minu='00';   memsize=256;  pmi=0; %7 grid left from px, py

%expri='e02';     infilenam='fcst';    dirnam='cycle';  type=infilenam;
expri='largens';  infilenam='wrfout';  dirnam='pert';   type='wrfo';
%pradar=4;  pela=0.5;  paza=208;  tita='A'; pdis=83;  figtit='south of RCCG';
%pradar=3;  pela=0.5;  paza=208;  tita='B'; pdis=83;  figtit='south of RCKT';
%pradar=4;  pela=0.5;  paza=248;  tita='C'; pdis=83;  figtit='west of RCCG';
pradar=3;  pela=0.5;  paza=248;  tita='D'; pdis=83;  figtit='west of RCKT';
%pradar=3;  pela=0.5;  paza=193;  tita='B.2'; pdis=83;  figtit='south of RCKT p2';
%pradar=4;  pela=0.5;  paza=193;  tita='A.2'; pdis=83;  figtit='south of RCCG p2';
lev=0; 

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri]; 
indir2=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri]; 

%---set
%
voen=zeros(memsize,1); V=zeros(memsize,1);   U=zeros(memsize,1);
g=9.81;

%tic
%---
   ti=hr;
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');  
%---member
   for mi=1:memsize;
% ---filename----
      nen=num2str(mi,'%.3d');      
      infile1=[indir1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00_',nen]; 
      infile2=[indir2,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------obs space------
      %vari1=load(infile1);
      fid=fopen(infile1);
      vo=textscan(fid,'%f%f%f%f%f%f%f%f%f');      fclose(fid);
      fin=find(vo{2}==pela & vo{3}==paza & vo{4}==pdis & vo{1}==pradar);
      %fin=30424;
      if isempty(fin)==1;  error('Error: No this obs point, pleast check the setting of <pradar> etc.'); end
      voen(mi)=vo{8}(fin);            
      if voen(mi)==-9999; disp(['member ',nen,' obs is -9999']); voen(mi)=0;  end;       
%------model space----      
      ncid = netcdf.open(infile2,'NC_NOWRITE'); 
      if mi==1
         p_lon=vo{5}(fin); p_lat=vo{6}(fin); obs_hgt=vo{7}(fin); 
         varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
         varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
         if lev==0
           %---difine px, py for th line---
           dis= ( (y-p_lat).^2 + (x-p_lon).^2 );
           [mid mxI]=min(dis);    [~, py]=min(mid);    px=mxI(py); %------------------------> px,py
           %
           varid =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
           varid  =netcdf.inqVarID(ncid,'PH');   ph =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
           varid  =netcdf.inqVarID(ncid,'PHB');  phb =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[1 1 nz+1 1]);
           P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)./g;
           [~, lev]=min(abs(zg-obs_hgt));                          %------------------------> lev
          end
      end
%
      varid  =netcdf.inqVarID(ncid,'V');  vm =netcdf.getVar(ncid,varid,[px-1-pmi py-1 lev-1 0],[1 2 1 1]);  
      V(mi)=(vm(:,1)+vm(:,2)).*0.5;
      varid  =netcdf.inqVarID(ncid,'U');  vm =netcdf.getVar(ncid,varid,[px-1-pmi py-1 lev-1 0],[2 1 1 1]); 
      U(mi)=(vm(1,:)+vm(2,:)).*0.5;
    
      netcdf.close(ncid);
   end   %member

   vru=sin(paza/180*pi)*U*cos(pela/180*pi);
   vrv=cos(paza/180*pi)*V*cos(pela/180*pi);
%}
%---plot---
%{
   figure('position',[200 100 900 500])
    plot(vru,'b');hold on    
    plot(vrv,'r')
    plot(voen,'k')
    legend('u','v','vr')
    line([0 256],[mean(vru) mean(vru)],'color','b')
    line([0 256],[mean(vrv) mean(vrv)],'color','r')
    line([0 256],[mean(voen) mean(voen)],'color','k')
    line([0 256],[mean(U) mean(U)],'color','b','linestyle','--')
    line([0 256],[mean(V) mean(V)],'color','r','linestyle','--')
    set(gca,'Xlim',[0 memsize],'fontsize',13) 

   tit=['Vr-',num2str(pradar),'-',num2str(pela),'-',num2str(paza),'-',num2str(pdis),' and UV-P(',num2str(px-pmi),',',num2str(py),')']; 
   title(tit,'fontsize',15)
   outfile=[outdir,'/vruv','_',num2str(fin),'_',num2str(px),num2str(py),'_',type,'_','lev',num2str(lev)];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
  %} 
%===============================================            
%{
   figure('position',[200 200 860 480])
   plot(vru./voen,'color',[0.1 0.1 0.9],'linewidth',1); hold on
   plot(vrv./voen,'color',[0.9 0.1 0.1],'linewidth',1)
   %h=legend('U@Vr / Vr','V@Vr / Vr');
   %set(h,'position',[0.6 0.8 0.2 0.07],'box','off','Orientation','horizontal','fontsize',15)
   line([0 memsize],[mean(vru./voen) mean(vru./voen)],'color',[0.1 0.1 0.9],'linewidth',1)
   line([0 memsize],[mean(vrv./voen) mean(vrv./voen)],'color',[0.9 0.1 0.1],'linewidth',1)
   set(gca,'Xlim',[1 memsize],'fontsize',16,'YLim',[-1 2],'Ytick',[-0.5 0 .5 1 1.5],'Yticklabel',[-0.5 0 .5 1 1.5]*100)
   xlabel('Member No.','fontsize',18,'Position',[125 -1.25]); 
   ylabel('Ratio (%)','fontsize',18,'Position',[-11.5 0.5])

   %tit=['Ratio ',tita,': P(',num2str(px-pmi),',',num2str(py),')'];
   tit=figtit;
   title(tit,'fontsize',18,'Position',[125 2.01])
   outfile=[outdir,'/ratio','_',num2str(fin),'_',num2str(px),num2str(py),'_',type,'_','lev',num2str(lev)];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
    system(['convert -trim -density 300 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);
%}
