function X2=RK4(X0,dt,u0,v0,w0,u1,v1,w1,u,v,w,xi3d,yi3d,zg0,zg1,zg,minum)

  %---k1: calculate u, v, w at X0(x, y, z)---
  dis_x= xi3d-X0(1);  dis_y= yi3d-X0(2);  dis_z= zg0-X0(3);  
  dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
  [~, indx]=sort(dist(:)); 
  if dist(indx(1))==0
    k1 = [u0(indx(1)), v0(indx(1)), w0(indx(1))]; 
  else
    dist_w=1./dist;
    %---
    dist_w_temp=dist_w(indx(1:minum));      
%     u_temp=u0(indx(1:minum));    v_temp=v0(indx(1:minum));    w_temp=w0(indx(1:minum));
    %---inverse distance weighted mean---
    k1(1)=sum(u0(indx(1:minum)).*dist_w_temp)/sum(dist_w_temp);    
    k1(2)=sum(v0(indx(1:minum)).*dist_w_temp)/sum(dist_w_temp);
    k1(3)=sum(w0(indx(1:minum)).*dist_w_temp)/sum(dist_w_temp);    
  end
  X1 = X0' + dt * k1;
      
  %---k2: calculate u, v, w at X1(x, y, z)---
  dis_x= xi3d-X1(1);  dis_y= yi3d-X1(2);  dis_z= zg1-X1(3);  
  dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
  [~, indx]=sort(dist(:));    
  dist_w=1./dist;
  %---
  dist_w_temp=dist_w(indx(1:minum));      
%   u_temp=u1(indx(1:minum));    v_temp=v1(indx(1:minum));     w_temp=w1(indx(1:minum));
  %---inverse distance weighted mean of u, v, w---
  k2(1)=sum(u1(indx(1:minum)).*dist_w_temp)/sum(dist_w_temp);    
  k2(2)=sum(v1(indx(1:minum)).*dist_w_temp)/sum(dist_w_temp);
  k2(3)=sum(w1(indx(1:minum)).*dist_w_temp)/sum(dist_w_temp);    
  %
  X1_s = X0' + dt * k2;      
      
  %---k3: calculate u, v, w at X1_s(x, y, z)---
  dis_x= xi3d-X1_s(1);  dis_y= yi3d-X1_s(2);  dis_z= zg1-X1_s(3);  
  dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
  [~, indx]=sort(dist(:));    
  dist_w=1./dist;
  %---
  dist_w_temp=dist_w(indx(1:minum));      
  u_temp=u1(indx(1:minum));   v_temp=v1(indx(1:minum));   w_temp=w1(indx(1:minum));
  %---inverse distance weighted mean of u, v, w---
  k3(1)=sum(u_temp.*dist_w_temp)/sum(dist_w_temp);    
  k3(2)=sum(v_temp.*dist_w_temp)/sum(dist_w_temp);
  k3(3)=sum(w_temp.*dist_w_temp)/sum(dist_w_temp);    
      
  X2_s = X0' + 2* dt* k3;      

  %---k4: calculate u, v, w at X2_s(x, y, z)---
  dis_x= xi3d-X2_s(1);  dis_y= yi3d-X2_s(2);  dis_z= zg-X2_s(3); 
  dist= (dis_x.^2 + dis_y.^2 + dis_z.^2).^0.5;    
  [~, indx]=sort(dist(:));   dist_w=1./dist;
  %---
  dist_w_temp=dist_w(indx(1:minum));      
  u_temp=u(indx(1:minum));   v_temp=v(indx(1:minum));    w_temp=w(indx(1:minum));
  %---inverse distance weighted mean of u, v, w---
  k4(1)=sum(u_temp.*dist_w_temp)/sum(dist_w_temp);    
  k4(2)=sum(v_temp.*dist_w_temp)/sum(dist_w_temp);    
  k4(3)=sum(w_temp.*dist_w_temp)/sum(dist_w_temp);  
  %---
  X2 =  X0 + ( 2*dt/6*(k1 + 2*k2 + 2*k3 + k4) )'; 
      
      
      

