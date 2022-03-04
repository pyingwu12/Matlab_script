function plot_corr(x,y,corr,L,cmap,lono,lato,fin)

pmin=double(min(min(corr)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
figure('position',[500 500 600 500]) 
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.5],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
[c hp]=m_contourf(x,y,corr,L2);   set(hp,'linestyle','none');  hold on; 

m_plot(lono(fin),lato(fin),'xk','MarkerSize',10,'LineWidth',2.3)
m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
%m_gshhs_h('color','k','LineWidth',1);
%m_coast('color','k');

cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
end