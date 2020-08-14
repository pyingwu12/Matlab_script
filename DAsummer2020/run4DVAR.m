function uest=run4DVAR(uest,yobs,KTwin,robs,sigma_f,L,dt,dx,gamma,xnu)

% yobs: Nobs*(KTmax/t_obsint) matrix
% uest: Ndim*KTmax matrix

global t_obsint Hmat

Ndim=size(uest,1);
KTmax=size(uest,2)-1;

%---obs operator, Hx=y
% Nobs=size(yobs,1);
% s_obsint = floor(Ndim / Nobs);
% Hmat=zeros(Nobs,Ndim); 
% for p=1:Nobs
% Hmat(p,(p-1)*s_obsint+1)=1;
% end

%=============DA================
% load(['true_obs_',num2str(Nobs),'_',num2str(t_obsint),'_',num2str(robs),'.mat']);
%---DA parameters
% KTwin = 150;                   % Assimilation window
% robs = 0.1;                    % obs error
% sigma_f=2;                     % background error
Niter = 8000;                  % Number of iterations
epsilon = 0.0005;             % mutiply to dJ/dx
ecri = 1.0e-6;                 % criteria of iterations

%---background error covariance
% L=2;  
B=zeros(Ndim,Ndim);
for i=1:Ndim
  for j=1:Ndim
    jj=j-i;
    if jj+Ndim/2>Ndim; jj=jj-Ndim; end
    if jj+Ndim/2<1; jj=jj+Ndim; end
    B(i,j)=sigma_f^2*exp(-abs(jj)./(2*L^2));
  end
end
B=B+eye(Ndim)*0.00001;
%B=sigma_f^2*eye(Ndim);
% figure; imagesc(B); colorbar

%---run DA
%uest=zeros(Ndim,KTmax+1);  uest(:,1)=uf(:,1);
disp('---DA START---')
for kt=1:KTwin:KTmax
%for kt=1:KTwin:KTwin*2
  for m=1:Niter
    Jcost = 0; 
 %---forward----------------------------------------     
    for k=1:KTwin     
      ktk=kt+k-1;
      if ktk>KTmax; break; end
      if k==1
       uest(:,ktk+1)=forward(uest(:,ktk),dt,dx,gamma,xnu);  
      else
       uest(:,ktk+1)=leapfrog(uest(:,ktk-1),uest(:,ktk),dt,dx,gamma,xnu);
      end     
      if mod(ktk,t_obsint)==0
        inno=yobs(:,fix(ktk/t_obsint)) - Hmat * uest(:,ktk+1);      
        Jcost=Jcost+(inno'*inno)/robs^2;        
        %Jcost_o(m,1)=(inno'*inno)/robs^2;      
      end    
    end  %k=1:KTwin
    
 %---adjoint---------------------------------------- 
    au2=zeros(Ndim,1); au0T=0; % adjoint variables
    for k=KTwin:-1:1       
      ktk=kt-1+k; 
      if ktk>KTmax; continue; end
      if mod(ktk,t_obsint)==0
        inno2=yobs(:,fix(ktk/t_obsint))- Hmat * uest(:,ktk+1);   
        au2 = au2 +  Hmat' * inno2 ./ robs^2;           
      end  %if mod  
      %-----------
      if k==1
        au2=forward_adj(au2,uest(:,ktk),dt,dx,gamma,xnu) ;  
      else
        [au0, au2]=leapfrog_adj(au2,uest(:,ktk),dt,dx,gamma,xnu);          
      end
      au2=au2+au0T;
      au0T=au0;      
    end  %k=1:KTwin
   
    delx=epsilon * (au2 - inv(B) * uest(:,kt)) ;   
    uest(:,kt)=uest(:,kt)+delx;
    
    if sum(delx.^2)<ecri; break;  end
  end %iterations
%   disp([num2str(kt),'th step done, ',num2str(m),' iter']);
  
 %---forcast from analysis---
  for k=1:KTwin         
    ktk=kt-1+k;
    if ktk>KTmax; break; end
    if k==1
     uest(:,ktk+1)=forward(uest(:,ktk),dt,dx,gamma,xnu);  
    else
     uest(:,ktk+1)=leapfrog(uest(:,ktk-1),uest(:,ktk),dt,dx,gamma,xnu);
    end 
  end 
  
end  %1:KTwin:KTmax-1  
disp('---DA DONE---')