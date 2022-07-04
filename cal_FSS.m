function fss=FSS(rain1,rain2,nnx,nny,thres)

[nx, ny]=size(rain1);

rain1(rain1<thres)=0; rain1(rain1>=thres)=1;  
rain2(rain2<thres)=0; rain2(rain2>=thres)=1;

o=zeros(nx,ny); m=zeros(nx,ny);

for i=1:nx
    for j=1:ny

   i2=i+nnx-1; if i2>nx; i2=i2-nx; end
   j2=j+nny-1; if j2>ny; j2=j2-ny; end

   o(i,j)=sum(rain1(i:i2,j:j2),'all')./(nnx*nny);
   m(i,j)=sum(rain2(i:i2,j:j2),'all')./(nnx*nny);

    end
end


MSE=sum((o-m).^2,'all')./(nx*ny);
MSE_ref=(sum(o.^2,'all')+sum(m.^2,'all'))./(nx*ny);

fss=1-(MSE./MSE_ref);