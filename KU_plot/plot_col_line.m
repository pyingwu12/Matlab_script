function plot_col_line(plotx,ploty,plotz,col,L,liwd)


hold on

for i=1:length(ploty)-1      
    
      
    if plotz(i)<=L(1)
        
      line([plotx(i) plotx(i+1)],[ploty(i) ploty(i+1)],'LineWidth',liwd,'color',col(1,:));  
      
    elseif plotz(i)>L(end)
        
      line([plotx(i) plotx(i+1)],[ploty(i) ploty(i+1)],'LineWidth',liwd,'color',col(end,:));   
      
    else
        
      for ci=1:length(L)-1
        if plotz(i)>L(ci) && plotz(i)<=L(ci+1)
         line([plotx(i) plotx(i+1)],[ploty(i) ploty(i+1)],'LineWidth',liwd,'color',col(ci+1,:));
        end
      end
      
    end
    
end