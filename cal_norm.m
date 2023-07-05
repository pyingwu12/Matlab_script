function total_norm=cal_norm(up1,up2,vp1,vp2,Tp1,Tp2,qvp1,qvp2,dPm)

  up_dot=up1.*up2; 
  vp_dot=vp1.*vp2;  
  Tp_dot=Tp1.*Tp2;  
  qvp_dot=qvp1.*qvp2; 
  
    norm3D=up_dot+vp_dot+Tp_dot+qvp_dot;
  
  
  norm2D= sum (dPm.*(norm3D(:,:,1:end-1)+norm3D(:,:,2:end))*0.5 ,3) ;
  

  total_norm=sum(norm2D(:));



end