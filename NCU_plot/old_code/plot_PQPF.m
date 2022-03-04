
tresh=50;
s_sth='17'; s_edh='18'; min='00';  
expri='MRcycle01';
[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);

load (['obs_acci_',s_sth,min,'_',s_edh,min,'.mat'])
acci=wrfacci;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
load '/work/pwin/data/colormap_PQPF.mat';  cmap=colormap_PQPF;
%---setting---
vari='PQPF';   
filenam=[expri,'_PQPF_'];   
%---

%---read data---         
     [yl xl]=size(acci{1});
     for tri=tresh;
        s_tresh=num2str(tri);
        number=zeros(yl,xl);   
        for k=1:yl
        for l=1:xl
         for i=1:40;
          if (acci{i}(k,l)>=tri );
          number(k,l)=number(k,l)+1;
          end
         end
        end
        end
        number=number*100/40;
        number(number==0)=NaN;
   %---------plot-----------------------------
        figure('position',[500 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c hp]=m_contourf(xi,yj,number,20);   set(hp,'linestyle','none');
        m_grid('fontsize',12);
        m_gshhs_h('color','k');
        %m_coast('color','k');
        hc=colorbar;   colormap(cmap);    set(hc,'fontsize',13);  caxis([0 100])   
        tit=[expri,'  ',vari,'  ',s_sth,min,'z -',s_edh,min,'z','  (threshold : ',s_tresh,')'];
        title(tit,'fontsize',15)
        outfile=[filenam,s_sth,min,s_edh,min,'_',s_tresh,'.png'];
        saveas(gca,outfile,'png');  
     end
