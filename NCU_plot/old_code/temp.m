sth=17;
acch=1;  expri='DA1518vr';
plotid=2; textid=0; ctnid=0;
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  
cmap=colormap_rain;   
%---setting---
vari='accumulation rainfall';  
type1='mean';   type2='PM';    type3='PMmod';
filenam=[expri,'_accum_'];   
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=['ctn_',filenam]; end
%---
for ti=sth;
   s_sth=num2str(ti);
   for ai=acch;
%---set clim and end time---    
      if mod(ai,2)~=0; clim=[0 ai*75+25]; elseif ai>=6; clim=[0 400]; else clim=[0 ai*75]; end    % colorbar      
      if ctnid~=0; clim=[0 ctnid]; end       
      L=fix(clim(2)/17*(1:16));
      if clim(2)==250;      L=[ 5 10 20 30 40 50 60  70  85 100 120 140 160 180 200 230];
      elseif clim(2)==100;  L=[ 5 10 15 20 25 30 35  40  45  50  55  60  65  75  85  95];
      elseif clim(2)==300;  L=[10 20 30 40 55 70 90 110 120 140 160 180 200 220 250 280];  
      end
      %--- 
      edh=ti+ai;               % end time
      if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
      infile=['acci_',s_sth,s_edh,'_da.mat'];  %%%
      %load (infile);
      [meacci PM PMmod]=calPM(acci);
%---find maximum---      
      maxpm=max(max(PM));
      maxpmm=max(max(PMmod));
      [Y mxI]=max(meacci);
      [maxm myi]=max(Y);
      mxi=mxI(myi);      
%---plot---
%---mean---
      if plotid==1 || plotid==3 || plotid==5 || plotid==7
        figure('position',[500 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c1 h1]=m_contourf(xi,yj,meacci,L);   set(h1,'linestyle','none');
        m_grid('fontsize',12);
        m_gshhs_h('color','k');            
        colorbar;   cm1=colormap(cmap);   caxis(clim);
        hc=Recolor_contourf(h1,cm1,L,'vert');  set(hc,'fontsize',13)
        if textid~=0
          hold on
          m_text(xi(mxi,myi),yj(mxi,myi),num2str(round(maxm)),'color','k','fontsize',14)
        end
        tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type1,')'];
        title(tit,'fontsize',15)
        %outfile=[expdir,'/mean/',filenam,s_sth,s_edh,'_',type1,'.png'];
        %print('-dpng',outfile,'-r350')
      end
%---PM---   
      if plotid==2 || plotid==3 || plotid==6 || plotid==7
        figure('position',[500 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c2 h2]=m_contourf(xi,yj,PM,L);   set(h2,'linestyle','none');
        m_grid('fontsize',12);
        m_gshhs_h('color','k');
        colorbar;   cm2=colormap(cmap);   caxis(clim); 
        hc=Recolor_contourf(h2,cm2,L,'vert');   set(hc,'fontsize',13)
        if textid~=0
          hold on
          m_text(xi(mxi,myi),yj(mxi,myi),num2str(round(maxpm)),'color','k','fontsize',14)
        end
        tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type2,')'];
        title(tit,'fontsize',15)
        outfile=[filenam,s_sth,s_edh,'_',type2,'.png'];
        print('-dpng',outfile,'-r350')       
      end
%---PMmod---
      if plotid==4 || plotid==5 || plotid==6 || plotid==7
        figure('position',[500 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c3 h3]=m_contourf(xi,yj,PMmod,L);   set(h3,'linestyle','none');
        m_grid('fontsize',12);
        m_gshhs_h('color','k');
        colorbar;   cm3=colormap(cmap);   caxis(clim);
        hc=Recolor_contourf(h3,cm3,L,'vert');  set(hc,'fontsize',13)
        if textid~=0
          hold on
          m_text(xi(mxi,myi),yj(mxi,myi),num2str(round(maxpmm)),'color','k','fontsize',14)
        end
        tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type3,')'];
        title(tit,'fontsize',15)
        %outfile=[expdir,'/mean/',filenam,s_sth,s_edh,'_',type3,'.png'];
        %print('-dpng',outfile,'-r350')     
      end
   end
end  

%}
