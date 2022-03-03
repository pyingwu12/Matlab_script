%function uvw_sprd(hr,expri,wid,isoid)
%-------------------------------------------------------
% u,v,w spread of experi (DA cycle & forecasting time)
%     wid=1-U, 2-V, 3-W
%-------------------------------------------------------

clear

hr=0;   expri='largens';    wid=[1 2];   isoid=0;   % 0:model level. ~=0:constant-height
memsize=40;
%
if isoid==0; lev=10; else hgt_w=3000; end  % level or height for plot
%---DA or forecast time---
infilenam='wrfout';  minu='00';   type='wrfo';  dirnam='pert';

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';   % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];   outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri];    % path of the experiments
%indir=['/SAS009/pwin/expri_cctmorakot/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/morakot_shao/',expri];
%indir=['/SAS009/pwin/expri_morakotEC/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/morakot_EC/',expri];
%indir=['/SAS009/pwin/expri_whatsmore/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/what/',expri];
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[0.1 0.5 1 2 3 4 5 6 7];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_sprd.mat';  cmap=colormap_sprd([1 3 4 6 7 9 11 13 14 15],:);
%------
varinam={'U';'V';'W'};
%plon=[118.3 122.85];  plat=[21.2 25.8];
%plon=[117.5 122.5]; plat=[20.5 25.65];
%plon=[118.3 121.8];   plat=[21 24.3];
plon=[118.4 121.8]; plat=[20.65 24.35];
g=9.81;

%----
for ti=hr
%---set time and filename---    
  s_hr=num2str(ti,'%2.2d'); 
  for vi=wid
    filenam=[expri,'_',varinam{vi},'-sprd_'];  if vi==3; L=L*0.1; end 
    for mi=1:memsize
%---set filename---
      nen=num2str(mi,'%.3d');
      infile=[indir,'/',dirnam,nen,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      if mi==1
        varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
        varid  =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
        [nx ny]=size(x);   wind_en=zeros(nx,ny,memsize); 
        if isoid~=0
        varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
        varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
        varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
        end
      end
      varid  =netcdf.inqVarID(ncid,varinam{vi});     vari_stag =netcdf.getVar(ncid,varid);
      netcdf.close(ncid)
      switch (vi); 
        case 1;   vari_wind=(vari_stag(1:nx,:,:)+vari_stag(2:nx+1,:,:)).*0.5;
        case 2;   vari_wind=(vari_stag(:,1:ny,:)+vari_stag(:,2:ny+1,:)).*0.5; 
        case 3;   vari_wind=(vari_stag(:,:,1:nz)+vari_stag(:,:,2:nz+1)).*0.5; 
      end  
    %---interpolation to constant-height above surface
      if isoid~=0
        P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;      zg=double(PH)/g;   
        hgtiso=hgt_w;
        for i=1:nx
         for j=1:ny
         X=squeeze(zg(i,j,:));
         Y=squeeze(vari_wind(i,j,:));     wind_en(i,j,mi)=interp1(X,Y,hgtiso,'linear');
         end
        end        
        isotype=[num2str(hgt_w/1000),'km'];
      else
        wind_en(:,:,mi)=vari_wind(:,:,lev);
        isotype=['lev',num2str(lev)];
      end %if isoid~=0  
    end %member
%---calculate spread---
    A=reshape(wind_en,nx*ny,memsize);
    am=mean(A,2);     Am=repmat(am,1,memsize);
    Ap=A-Am;
    varae=sum(Ap.^2,2)./(memsize-1);
    sprd=reshape(sqrt(varae),nx,ny);
      %%
%--plot----
    plotvar=sprd;
    plotvar(plotvar==0)=NaN;
    pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
    figure('position',[100 100 600 500]) 
    m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
    [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
      %
    cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
    m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
    %m_coast('color','k');
    m_gshhs_h('color','k','LineWidth',0.8);    
     %
    mem=num2str(memsize);
    tit=[expri,'  ',varinam{vi},' spread  ',s_hr,minu,'z  (',type,' ',isotype,', mem',mem,')'];  
    title(tit,'fontsize',15)
    outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',isotype,'_m',mem];
    %print('-dpng',outfile,'-r400')       
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);  
    %
  end  % wid
end     % time

