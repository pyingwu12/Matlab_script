function qa_mean=TPWqx_cal_area_mean(expri,hm,vari,lonA,latA,asize)

%clear
%close all

%expri='e09'; vari='QVAPOR';

%hm=['00:00';'00:15';'00:30';'00:45';'01:00';'01:15';'01:30';'01:45';'02:00';'03:00';'04:00';'05:00';'06:00';'07:00'];
%hm=['00:30'];

%lonA=119; latA=21.5; asize=50;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir=['/SAS009/pwin/expri_largens/',expri]; 
%
num=size(hm,1);
g=9.81;


for ti=1:num;
  time=hm(ti,:);
  if str2double(time(1:2))<3
     for tyi=1:2     
       if tyi==1; type='fcst'; elseif tyi==2; type='anal'; end
       ni=2*(ti-1)+tyi;
       %---set filename---
       infile=[indir,'/output/',type,'mean_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
       %------read netcdf data--------
       ncid = netcdf.open(infile,'NC_NOWRITE');
       if ni==1
        varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=(lon);
        varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=(lat);
        varid =netcdf.inqDimID(ncid,'bottom_top'); [~, nz]=netcdf.inqDim(ncid,varid);
        %---difine px, py for th line---
        dis= ( (y-latA).^2 + (x-lonA).^2 );
        [mid mxI]=min(dis);   [~, py]=min(mid);   px=mxI(py); %------------------------> px,py
       end    
       varid  =netcdf.inqVarID(ncid,vari);      qx=netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[asize asize nz 1]);
       varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[asize asize nz 1]);
       varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[asize asize nz 1]); 
       %---integrate TPW---
       P=(pb+p);       dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
       tpw= dP.*( (qx(:,:,2:nz)+qx(:,:,1:nz-1)).*0.5 ) ;    
       TPW=sum(tpw,3)./g; 
         netcdf.close(ncid);
       qa_mean(ni)=mean(mean(TPW));
     end  % fcst / anal
  
  elseif str2double(time(1:2))>=3
     ni=ni+1;
     %---set filename---
     infile=[indir,'/','wrfout_d',dom,'_',year,'-',mon,'-',date,'_',time,':00'];
     %------read netcdf data--------
     ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,vari);      qx=netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[asize asize nz 1]);
     varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[asize asize nz 1]);
     varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid,[px-1 py-1 0 0],[asize asize nz 1]); 
     %---integrate TPW---
     P=(pb+p);      dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
     tpw= dP.*( (qx(:,:,2:nz)+qx(:,:,1:nz-1)).*0.5 ) ;    
     TPW=sum(tpw,3)./g;
       netcdf.close(ncid);
     qa_mean(ni)=mean(mean(TPW));
  end %if
end  %ti
%{
 xplot=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 11 12 13 14];
% 
 figure('position',[150 100 800 400])
 plot(xplot,qv_mean,'color','k','Linestyle','-','LineWidth',2);  hold on
%
%set(gca,'XLim',[0 num+1],'YLim',[17.1 17.6],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
 set(gca,'XLim',[0 num+1],'XTick',1:num,'XTickLabel',hm,'fontsize',13,'LineWidth',1)
% xlabel('Time','fontsize',14);   ylabel('dBZ','fontsize',14);
%legh=legend(hp,exp,'Location','BestOutside'); 
%set(legh,'fontsize',13)
% 
   tit=[expri1,'-',expri2,'  ',vari,'  ',hm(1,1:2),'z-',hm(num,1:2),'z '];
   title(tit,'fontsize',15)
%  outfile=[outdir,filenam,hm(1,1:2),hm(num,1:2),exptext];
%  set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%  system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%  system(['rm ',[outfile,'.pdf']]);
%}
