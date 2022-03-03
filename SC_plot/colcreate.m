cols_tmp=jet(50);
for i=40:-1:1
    %cols(41-i,:)=cols_tmp(i+10,:);    
    cols(i,:)=cols_tmp(i,:);
end
cols(40,:)=[0.7 0.7 0.7];
colormap(cols);
