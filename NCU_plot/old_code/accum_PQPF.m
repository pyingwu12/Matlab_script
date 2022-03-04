%function accum_PQPF(sth,acch,expri,tresh)

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
load '/work/pwin/data/colormap_PQPF.mat';  cmap=colormap_PQPF; cmap(1,:)=[0.8 0.8 0.8];
%---setting---
memsize=40;
vari='PQPF';   
filenam=[expri,'_PQPF_'];   
expdir=['/work/pwin/plot_cal/Rain/',expri];
%---
for ti=sth;
   s_sth=num2str(ti);
   for ai=acch;
%---end time---    
     edh=ti+ai;
     if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
     infile=[expdir,'/obs_acci_',s_sth,s_edh,'.mat'];
     load (infile);
     infile=[expdir,'/acci_',s_sth,s_edh,'.mat'];
     load (infile);
     [yl xl]=size(acci{1});
     for tri=tresh;
        s_tresh=num2str(tri);
        number=zeros(yl,xl);   
        for k=1:yl
        for l=1:xl
         for i=1:memsize;
          if (acci{i}(k,l)>=tri );
          number(k,l)=number(k,l)+1;
          end
         end
        end
        end
        number=number*100/memsize;
        number(number==0)=NaN;
   %---------plot-----------------------------
        figure('position',[500 100 600 500])
        m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
        [c hp]=m_contourf(xi,yj,number,20);   set(hp,'linestyle','none'); hold on;
        m_contour(xi,yj,obsacci,[tri tri],'k--','LineWidth',1.1);
        m_grid('fontsize',12);
        m_gshhs_h('color','k');
        %m_coast('color','k');
        hc=colorbar;   colormap(cmap);    set(hc,'fontsize',13);  caxis([0 100])   
        tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z  (threshold : ',s_tresh,')'];
        title(tit,'fontsize',15)
        outfile=[expdir,'/',filenam,s_sth,s_edh,'_',s_tresh,'.png'];
        saveas(gca,outfile,'png');  
     end
   end   
end

end