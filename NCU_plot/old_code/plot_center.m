
%s_hr='15'; s_min='30';
expri='DA1518vr';
indir='/SAS002/pwin/expri_241/morakot_newda_1518_vr_900';
hm=['15:00';'15:30';'15:45';'16:00';'16:00';'16:30';'16:45';'17:00'];
num=size(hm,1);

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')

%----set---- 
type='fcst';
%----    

for ti=1:num
   time=hm(ti,:);
   s_hr=time(1:2); s_min=time(4:5);
   infile=[indir,'/output/',type,'mean_d03_2009-08-08_',s_hr,':',s_min,':00'];
%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
 varid  =netcdf.inqVarID(ncid,'LANDMASK');  %land or not
  landm =netcdf.getVar(ncid,varid) ;
  landm=double(landm);  
 
for i=1:40;       
   nen=num2str(i);
   if i<=9
    infile=[indir,'/cycle0',nen,'/',type,'_d03_2009-08-08_',s_hr,':',s_min,':00'];
   else
    infile=[indir,'/cycle',nen,'/',type,'_d03_2009-08-08_',s_hr,':',s_min,':00'];
   end
% ------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
% 
   varid  =netcdf.inqVarID(ncid,'PH');  % perturbation geopotential
    ph  =netcdf.getVar(ncid,varid);     
   varid  =netcdf.inqVarID(ncid,'PHB'); % base-state geopotential
    phb =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'T');   % perturbation potential temperature (theta-t0)
    the =netcdf.getVar(ncid,varid);
    the=permute(the,[3 2 1]);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   % Water vapor mixing ratio
    qv =netcdf.getVar(ncid,varid);  
    qv=permute(qv,[3 2 1]);
   varid  =netcdf.inqVarID(ncid,'P');   % perturbation pressure
    p  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');  % BASE STATE PRESSURE
    pb =netcdf.getVar(ncid,varid);     


pre=p+pb;  %pressure
pre=permute(pre,[3 2 1]); %change dimension


zg0=(ph+phb)/9.81;  
zg=0.5*(zg0(:,:,1:end-1)+zg0(:,:,2:end)); %height
zg=permute(zg,[3 2 1]);

temp=wrf_tk(pre,300.0+the,'K'); %temperature (theta is perturbation, so add 300) 

slp0=calc_slp(pre,zg,temp,qv);
slp{i}=double(permute(slp0,[2 1]));
disp(['member',num2str(i),' is OK'])

netcdf.close(ncid)
end


vari='TC center';   filenam=[expri,'_center_'];  
bestx=120.4;
besty=25.2;
 rang=1.7;
 xr=[fix(bestx)-rang fix(bestx)+rang]; yr=[fix(besty)-rang fix(besty)+rang];
 finr=find(x>=xr(1) & x<=xr(2) & y>=yr(1) & y<=yr(2)); 
 xg=x(finr); yg=y(finr);

fin=find(landm>0);
%
for i=1:40  
   slp{i}(fin)=NaN;
   slpi0(:,:,i)=slp{i};
   
   slpi=slp{i}(finr); 
   [mslp mI]=min(slpi);
   locx(i)=xg(mI);
   locy(i)=yg(mI);
   minslp(i)=mslp;   
end

 slpmean=mean(slpi0,3); 
  [Y mxI]=min(slpmean);
  [mslp myi]=min(Y);
  mxi=mxI(myi); 
  locx(41)=x(mxi,myi);
  locy(41)=y(mxi,myi);
  minslp(41)=mslp;
%}
%
%---------plot-----------------------------
figure('position',[500 100 600 500])
m_proj('Lambert','lon',[117.5 123.5],'lat',[21.65 27],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
h1=m_plot(locx(1:40),locy(1:40),'o','MarkerEdgeColor','none','MarkerFaceColor',[0 0 1],'MarkerSize',4); hold on
%h2=m_plot(bestx,besty,'+r');
m_plot(locx(41),locy(41),'xr');
m_grid('fontsize',12);
m_gshhs_h('color','k');
%m_coast('color','k');
  tit=[expri,'  ',vari,'  ',s_hr,s_min,'z (',type,')'];
  title(tit,'fontsize',15)
  outfile=[filenam,s_hr,s_min,'_',type,'.png'];
  saveas(gca,outfile,'png');  
end  